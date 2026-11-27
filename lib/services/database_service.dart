import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/finance_data.dart';
import 'bank_detector.dart';

/// Lectura y escritura de datos del usuario en Supabase.
///
/// Tablas (ver supabase/schema.sql): profiles, transactions, goals.
class DatabaseService {
  DatabaseService._();

  static SupabaseClient get _db => Supabase.instance.client;

  static StreamSubscription<List<Map<String, dynamic>>>? _txSub;
  static StreamSubscription<List<Map<String, dynamic>>>? _goalSub;

  static bool get _online =>
      AppState.backendReady && AppState.user.value?.id != 'demo';

  /// Guarda/actualiza el perfil del usuario y empieza a escuchar sus datos.
  static Future<void> bind(User user) async {
    unbind();
    final meta = user.userMetadata ?? {};
    final name = (meta['full_name'] ?? meta['name'] ?? '') as String;
    final avatar = (meta['avatar_url'] ?? meta['picture']) as String?;
    AppState.user.value = AppUser(
      id: user.id,
      name: name,
      email: user.email ?? '',
      avatarUrl: avatar,
    );

    _txSub = _db
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .listen(
          (rows) =>
              AppState.transactions.value = rows.map(Txn.fromMap).toList(),
        );

    _goalSub = _db
        .from('goals')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at')
        .listen(
          (rows) => AppState.goals.value = rows.map(Goal.fromMap).toList(),
        );

    // Registra el inicio de sesión en la tabla profiles.
    try {
      await _db.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': name.isEmpty ? null : name,
        'avatar_url': avatar,
        'provider': user.appMetadata['provider'],
        'last_login': DateTime.now().toUtc().toIso8601String(),
      });
      final profile = await _db
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      final savedName = profile?['full_name'] as String?;
      if (name.isEmpty && savedName != null && savedName.isNotEmpty) {
        AppState.user.value = AppUser(
          id: user.id,
          name: savedName,
          email: user.email ?? '',
          avatarUrl: avatar,
        );
      }
    } catch (_) {
      // Si falla (p. ej. aún no se ejecutó schema.sql) la app sigue funcionando.
    }

    // Movimientos que Finix detectó del banco mientras la app estaba cerrada.
    await BankDetector.sync();
  }

  static void unbind() {
    _txSub?.cancel();
    _goalSub?.cancel();
    _txSub = _goalSub = null;
    AppState.user.value = null;
    AppState.transactions.value = [];
    AppState.goals.value = [];
  }

  /* ── Movimientos ── */

  static Future<void> addTransaction(Txn t) async {
    if (!_online) {
      AppState.transactions.value = [t, ...AppState.transactions.value];
      return;
    }
    final row = await _db
        .from('transactions')
        .insert(t.toInsert())
        .select()
        .single();
    _upsertLocal(Txn.fromMap(row));
  }

  static Future<void> deleteTransaction(Txn t) async {
    AppState.transactions.value = AppState.transactions.value
        .where((x) => !identical(x, t))
        .toList();
    if (_online && t.id != null) {
      await _db.from('transactions').delete().eq('id', t.id!);
    }
  }

  static void _upsertLocal(Txn t) {
    final list = AppState.transactions.value.where((x) => x.id != t.id).toList()
      ..add(t);
    list.sort((a, b) => b.date.compareTo(a.date));
    AppState.transactions.value = list;
  }

  /* ── Metas ── */

  static Future<void> addGoal(Goal g) async {
    if (!_online) {
      AppState.goals.value = [...AppState.goals.value, g];
      return;
    }
    final row = await _db.from('goals').insert(g.toInsert()).select().single();
    AppState.goals.value = [
      ...AppState.goals.value.where((x) => x.id != row['id']),
      Goal.fromMap(row),
    ];
  }

  static Future<void> addToGoal(Goal g, int amount) async {
    final updated = g.copyWith(saved: g.saved + amount);
    AppState.goals.value = [
      for (final x in AppState.goals.value) identical(x, g) ? updated : x,
    ];
    if (_online && g.id != null) {
      await _db.from('goals').update({'saved': updated.saved}).eq('id', g.id!);
    }
  }

  static Future<void> deleteGoal(Goal g) async {
    AppState.goals.value = AppState.goals.value
        .where((x) => !identical(x, g))
        .toList();
    if (_online && g.id != null) {
      await _db.from('goals').delete().eq('id', g.id!);
    }
  }
}
