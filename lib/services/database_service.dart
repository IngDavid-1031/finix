import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/finance_data.dart';
import 'bank_detector.dart';
import 'local/local_store.dart';

/// Datos del usuario: primero se guardan en la base interna del celular
/// (SQLite) y luego se sincronizan con Supabase en segundo plano.
///
/// - Sin internet todo sigue funcionando: los cambios quedan pendientes.
/// - Cuando vuelve la conexión se suben solos (cada 45 s, al guardar y al
///   volver a abrir la app) y se bajan los cambios hechos en otros equipos.
///
/// Tablas (ver supabase/schema.sql): profiles, transactions, goals, bills.
class DatabaseService {
  DatabaseService._();

  static SupabaseClient get _db => Supabase.instance.client;

  static LocalStore? _store;
  static String? _uid;

  /// Copia en memoria de la base interna: tabla → id → registro.
  static final Map<String, Map<String, LocalRecord>> _mirror = {
    for (final k in localKinds) k: {},
  };

  static final List<StreamSubscription<List<Map<String, dynamic>>>> _subs = [];
  static Timer? _timer;
  static AppLifecycleListener? _life;
  static bool _syncing = false;
  static bool _again = false;

  /// Cambia en cada bind/unbind para descartar trabajo de una sesión anterior.
  static int _session = 0;

  /// true con un usuario real; false en modo demo (solo memoria).
  static bool get _cloud => _uid != null;

  /// Guarda/actualiza el perfil del usuario, carga sus datos locales y
  /// empieza a sincronizar con Supabase.
  static Future<void> bind(User user) async {
    unbind();
    final session = ++_session;
    final meta = user.userMetadata ?? {};
    final name = (meta['full_name'] ?? meta['name'] ?? '') as String;
    final avatar = (meta['avatar_url'] ?? meta['picture']) as String?;
    AppState.user.value = AppUser(
      id: user.id,
      name: name,
      email: user.email ?? '',
      avatarUrl: avatar,
    );
    if (!AppState.backendReady) return;
    _uid = user.id;

    // 1) Lo que ya está guardado en el celular aparece al instante.
    try {
      _store ??= await LocalStore.open();
      for (final k in localKinds) {
        final recs = await _store!.load(k, user.id);
        if (session != _session) return;
        _mirror[k] = {for (final r in recs) r.id: r};
      }
    } catch (e) {
      debugPrint('Base interna no disponible: $e');
    }
    if (session != _session) return;
    for (final k in localKinds) {
      _publish(k);
    }

    // 2) Cambios del servidor en tiempo real (otros equipos, la web…).
    for (final k in localKinds) {
      _subs.add(
        _db
            .from(k)
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .listen(
              (rows) => _applyServer(k, rows, session),
              onError: (Object e) => debugPrint('$k (sin conexión): $e'),
            ),
      );
    }

    // 3) Sincronización en segundo plano.
    _timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_hasPending) sync();
    });
    _life = AppLifecycleListener(onResume: () => sync(pull: true));
    unawaited(sync(pull: true));
    unawaited(_saveProfile(user, name, avatar, session));

    // Movimientos que Finix detectó del banco mientras la app estaba cerrada.
    await BankDetector.sync();
  }

  static void unbind() {
    _session++;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _timer?.cancel();
    _timer = null;
    _life?.dispose();
    _life = null;
    _uid = null;
    for (final k in localKinds) {
      _mirror[k] = {};
    }
    AppState.user.value = null;
    AppState.transactions.value = [];
    AppState.goals.value = [];
    AppState.bills.value = [];
  }

  /// Registra el inicio de sesión en la tabla profiles.
  static Future<void> _saveProfile(
    User user,
    String name,
    String? avatar,
    int session,
  ) async {
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
      if (session == _session &&
          name.isEmpty &&
          savedName != null &&
          savedName.isNotEmpty) {
        AppState.user.value = AppUser(
          id: user.id,
          name: savedName,
          email: user.email ?? '',
          avatarUrl: avatar,
        );
      }
    } catch (_) {
      // Sin internet o sin schema.sql: la app sigue funcionando.
    }
  }

  /* ── Base interna ── */

  static bool get _hasPending =>
      _mirror.values.any((m) => m.values.any((r) => r.dirty));

  /// Pasa la base interna a la pantalla.
  static void _publish(String kind) {
    final recs = _mirror[kind]!.values.where((r) => !r.deleted);
    switch (kind) {
      case 'transactions':
        AppState.transactions.value = [
          for (final r in recs) Txn.fromMap(r.data),
        ]..sort((a, b) => b.date.compareTo(a.date));
      case 'goals':
        final list = recs.toList()
          ..sort(
            (a, b) => (a.data['created_at'] as String? ?? '').compareTo(
              b.data['created_at'] as String? ?? '',
            ),
          );
        AppState.goals.value = [for (final r in list) Goal.fromMap(r.data)];
      case 'bills':
        AppState.bills.value = [for (final r in recs) Bill.fromMap(r.data)]
          ..sort((a, b) => a.dueDay.compareTo(b.dueDay));
    }
  }

  /// Guarda primero en el celular y luego intenta subirlo.
  static Future<void> _write(
    String kind,
    Map<String, dynamic> row, {
    bool deleted = false,
  }) async {
    final id = row['id'] as String;
    final cur = _mirror[kind]![id];
    final data = {...?cur?.data, ...row};
    data['created_at'] ??= DateTime.now().toUtc().toIso8601String();
    final rec = LocalRecord(
      kind: kind,
      id: id,
      userId: _uid!,
      data: data,
      dirty: true,
      deleted: deleted,
    );
    _mirror[kind]![id] = rec;
    _publish(kind);
    try {
      await _store?.putAll([rec]);
    } catch (e) {
      debugPrint('No se pudo guardar en la base interna: $e');
    }
    unawaited(sync());
  }

  /// Llegan los datos de Supabase: se mezclan con los locales sin pisar
  /// lo que todavía no se ha subido.
  static void _applyServer(
    String kind,
    List<Map<String, dynamic>> rows,
    int session,
  ) {
    if (session != _session || _uid == null) return;
    final m = _mirror[kind]!;
    final serverIds = <String>{};
    final put = <LocalRecord>[];
    for (final row in rows) {
      final id = row['id'] as String?;
      if (id == null) continue;
      serverIds.add(id);
      if (m[id]?.dirty ?? false) continue;
      final rec = LocalRecord(
        kind: kind,
        id: id,
        userId: _uid!,
        data: Map<String, dynamic>.of(row),
      );
      m[id] = rec;
      put.add(rec);
    }
    // Ya sincronizados que no están en el servidor = se borraron en otro equipo.
    final gone = [
      for (final r in m.values)
        if (!r.dirty && !serverIds.contains(r.id)) r.id,
    ];
    gone.forEach(m.remove);
    _publish(kind);
    unawaited(() async {
      try {
        await _store?.putAll(put);
        await _store?.removeAll(kind, gone);
      } catch (e) {
        debugPrint('Base interna: $e');
      }
    }());
  }

  /// Sube los cambios pendientes; con [pull] también baja los del servidor.
  static Future<void> sync({bool pull = false}) async {
    if (!_cloud) return;
    if (_syncing) {
      _again = true;
      return;
    }
    _syncing = true;
    final session = _session;
    try {
      do {
        _again = false;
        var offline = false;
        for (final kind in localKinds) {
          final pending = _mirror[kind]!.values.where((r) => r.dirty).toList();
          for (final rec in pending) {
            if (session != _session) return;
            try {
              if (rec.deleted) {
                await _db.from(kind).delete().eq('id', rec.id);
              } else {
                await _db.from(kind).upsert(rec.data);
              }
              // Solo se marca como subido si no cambió mientras tanto.
              if (session == _session &&
                  identical(_mirror[kind]![rec.id], rec)) {
                if (rec.deleted) {
                  _mirror[kind]!.remove(rec.id);
                  await _store?.removeAll(kind, [rec.id]);
                } else {
                  final clean = rec.copyWith(dirty: false);
                  _mirror[kind]![rec.id] = clean;
                  await _store?.putAll([clean]);
                }
              }
            } on PostgrestException catch (e) {
              // El servidor lo rechazó (p. ej. falta una tabla): se reintenta luego.
              debugPrint('sync $kind: ${e.message}');
            } catch (e) {
              offline = true; // sin internet: se reintenta más tarde
              break;
            }
          }
          if (offline) break;
        }
        if (!offline && pull) {
          pull = false;
          await _pull(session);
        }
      } while (_again && session == _session);
    } finally {
      _syncing = false;
    }
  }

  static Future<void> _pull(int session) async {
    for (final kind in localKinds) {
      try {
        final rows = await _db.from(kind).select().eq('user_id', _uid!);
        _applyServer(kind, rows, session);
      } catch (_) {
        return;
      }
    }
  }

  /* ── Movimientos ── */

  static Future<void> addTransaction(Txn t) async {
    if (!_cloud) {
      AppState.transactions.value = [t, ...AppState.transactions.value];
      return;
    }
    await _write(
      'transactions',
      (t.id == null ? t.withId(newId()) : t).toRow(),
    );
  }

  static Future<void> deleteTransaction(Txn t) async {
    if (!_cloud || t.id == null) {
      AppState.transactions.value = AppState.transactions.value
          .where((x) => !identical(x, t))
          .toList();
      return;
    }
    await _write('transactions', {'id': t.id}, deleted: true);
  }

  /* ── Metas ── */

  static Future<void> addGoal(Goal g) async {
    if (!_cloud) {
      AppState.goals.value = [...AppState.goals.value, g];
      return;
    }
    await _write('goals', (g.id == null ? g.copyWith(id: newId()) : g).toRow());
  }

  static Future<void> addToGoal(Goal g, int amount) async {
    final updated = g.copyWith(saved: g.saved + amount);
    if (!_cloud || g.id == null) {
      AppState.goals.value = [
        for (final x in AppState.goals.value) identical(x, g) ? updated : x,
      ];
      return;
    }
    await _write('goals', updated.toRow());
  }

  static Future<void> deleteGoal(Goal g) async {
    if (!_cloud || g.id == null) {
      AppState.goals.value = AppState.goals.value
          .where((x) => !identical(x, g))
          .toList();
      return;
    }
    await _write('goals', {'id': g.id}, deleted: true);
  }

  /* ── Pagos fijos ── */

  static void _putBillDemo(Bill b, {Bill? replacing}) {
    AppState.bills.value = [
      for (final x in AppState.bills.value)
        if (!identical(x, replacing)) x,
      b,
    ]..sort((a, c) => a.dueDay.compareTo(c.dueDay));
  }

  static Future<void> addBill(Bill b) async {
    if (!_cloud) return _putBillDemo(b);
    await _write('bills', (b.id == null ? b.copyWith(id: newId()) : b).toRow());
  }

  static Future<void> updateBill(Bill old, Bill updated) async {
    if (!_cloud || old.id == null) {
      return _putBillDemo(updated, replacing: old);
    }
    await _write('bills', updated.copyWith(id: old.id).toRow());
  }

  static Future<void> deleteBill(Bill b) async {
    if (!_cloud || b.id == null) {
      AppState.bills.value = AppState.bills.value
          .where((x) => !identical(x, b))
          .toList();
      return;
    }
    await _write('bills', {'id': b.id}, deleted: true);
  }

  /// Marca el mes pendiente como pagado y lo registra como gasto.
  static Future<void> payBill(Bill b) async {
    final due = b.nextDue;
    final now = DateTime.now();
    await addTransaction(
      Txn(
        title: b.title,
        category: b.category,
        amount: -b.amount,
        date: now,
        note: 'Pago fijo de ${monthNames[due.month - 1]} ${due.year}',
      ),
    );
    await updateBill(b, b.copyWith(paidMonth: Bill.monthKey(due)));
  }

  /// Deshace "pagado" de este mes (no borra el gasto registrado).
  static Future<void> unpayBill(Bill b) async {
    final now = DateTime.now();
    final prev = Bill.monthKey(DateTime(now.year, now.month - 1));
    final updated = Bill(
      id: b.id,
      title: b.title,
      amount: b.amount,
      dueDay: b.dueDay,
      emoji: b.emoji,
      category: b.category,
      remindDays: b.remindDays,
      paidMonth: prev,
    );
    await updateBill(b, updated);
  }
}
