import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_store.dart';

Future<LocalStore> openLocalStore() async =>
    _WebStore(await SharedPreferences.getInstance());

/// En el navegador no hay SQLite: se guarda en el almacenamiento local.
class _WebStore implements LocalStore {
  final SharedPreferences prefs;
  _WebStore(this.prefs);

  String _key(String kind) => 'finix_local_v1_$kind';

  Map<String, dynamic> _read(String kind) {
    try {
      return (jsonDecode(prefs.getString(_key(kind)) ?? '{}') as Map)
          .cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(String kind, Map<String, dynamic> m) =>
      prefs.setString(_key(kind), jsonEncode(m));

  @override
  Future<List<LocalRecord>> load(String kind, String userId) async => [
    for (final e in _read(kind).entries)
      if ((e.value as Map)['user_id'] == userId)
        LocalRecord(
          kind: kind,
          id: e.key,
          userId: userId,
          data: ((e.value as Map)['data'] as Map).cast<String, dynamic>(),
          dirty: (e.value as Map)['dirty'] == true,
          deleted: (e.value as Map)['deleted'] == true,
        ),
  ];

  @override
  Future<void> putAll(List<LocalRecord> records) async {
    final byKind = <String, List<LocalRecord>>{};
    for (final r in records) {
      (byKind[r.kind] ??= []).add(r);
    }
    for (final e in byKind.entries) {
      final m = _read(e.key);
      for (final r in e.value) {
        m[r.id] = {
          'user_id': r.userId,
          'data': r.data,
          'dirty': r.dirty,
          'deleted': r.deleted,
        };
      }
      await _write(e.key, m);
    }
  }

  @override
  Future<void> removeAll(String kind, Iterable<String> ids) async {
    final m = _read(kind);
    for (final id in ids) {
      m.remove(id);
    }
    await _write(kind, m);
  }
}
