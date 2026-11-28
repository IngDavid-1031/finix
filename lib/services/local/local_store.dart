import 'dart:math';

import 'local_store_web.dart'
    if (dart.library.io) 'local_store_sqlite.dart'
    as impl;

/// Tablas locales (mismos nombres que en Supabase).
const localKinds = ['transactions', 'goals', 'bills'];

/// Un registro guardado en el celular.
///
/// [dirty] = todavía no se ha subido a Supabase. [deleted] = se borró en el
/// celular y falta borrarlo en Supabase.
class LocalRecord {
  final String kind;
  final String id;
  final String userId;
  final Map<String, dynamic> data;
  final bool dirty;
  final bool deleted;

  const LocalRecord({
    required this.kind,
    required this.id,
    required this.userId,
    required this.data,
    this.dirty = false,
    this.deleted = false,
  });

  LocalRecord copyWith({
    Map<String, dynamic>? data,
    bool? dirty,
    bool? deleted,
  }) => LocalRecord(
    kind: kind,
    id: id,
    userId: userId,
    data: data ?? this.data,
    dirty: dirty ?? this.dirty,
    deleted: deleted ?? this.deleted,
  );
}

/// Base de datos interna: primero se guarda aquí y luego se sincroniza.
abstract class LocalStore {
  /// SQLite en Android/iOS; almacenamiento del navegador en web.
  static Future<LocalStore> open() => impl.openLocalStore();

  Future<List<LocalRecord>> load(String kind, String userId);
  Future<void> putAll(List<LocalRecord> records);
  Future<void> removeAll(String kind, Iterable<String> ids);
}

final _rnd = Random.secure();

/// UUID v4: el id se crea en el celular para poder guardar sin internet.
String newId() {
  final b = List<int>.generate(16, (_) => _rnd.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
