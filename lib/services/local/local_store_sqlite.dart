import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local_store.dart';

Future<LocalStore> openLocalStore() async {
  final dir = await getDatabasesPath();
  final db = await openDatabase(
    '$dir/finix_local.db',
    version: 1,
    onCreate: (db, _) async {
      for (final t in localKinds) {
        await db.execute('''
          CREATE TABLE $t (
            id         TEXT PRIMARY KEY,
            user_id    TEXT NOT NULL,
            data       TEXT NOT NULL,
            dirty      INTEGER NOT NULL DEFAULT 0,
            deleted    INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX ${t}_user_idx ON $t (user_id)');
      }
    },
  );
  return _SqliteStore(db);
}

/// SQLite en el celular (archivo finix_local.db).
class _SqliteStore implements LocalStore {
  final Database db;
  _SqliteStore(this.db);

  @override
  Future<List<LocalRecord>> load(String kind, String userId) async {
    final rows = await db.query(
      kind,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return [
      for (final r in rows)
        LocalRecord(
          kind: kind,
          id: r['id'] as String,
          userId: r['user_id'] as String,
          data: (jsonDecode(r['data'] as String) as Map)
              .cast<String, dynamic>(),
          dirty: r['dirty'] == 1,
          deleted: r['deleted'] == 1,
        ),
    ];
  }

  @override
  Future<void> putAll(List<LocalRecord> records) async {
    if (records.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final r in records) {
      batch.insert(r.kind, {
        'id': r.id,
        'user_id': r.userId,
        'data': jsonEncode(r.data),
        'dirty': r.dirty ? 1 : 0,
        'deleted': r.deleted ? 1 : 0,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> removeAll(String kind, Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    final batch = db.batch();
    for (final id in list) {
      batch.delete(kind, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }
}
