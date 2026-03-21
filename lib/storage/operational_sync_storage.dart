import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final Future<Database> operationalSyncDatabase =
    getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'operational_sync.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE sync_outbox (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_mutation_id TEXT NOT NULL UNIQUE,
          op_type TEXT NOT NULL,
          homiletic_uuid TEXT,
          payload_json TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
        ''');
      await db.execute('''
        CREATE TABLE sync_meta (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
        ''');
    },
  );
});

class SyncOutboxRow {
  SyncOutboxRow({
    required this.id,
    required this.clientMutationId,
    required this.opType,
    this.homileticUuid,
    required this.payloadJson,
  });

  final int id;
  final String clientMutationId;
  final String opType;
  final String? homileticUuid;
  final String payloadJson;
}

Future<int> getLastAppliedServerSeq() async {
  final db = await operationalSyncDatabase;
  final rows = await db.query(
    'sync_meta',
    where: 'key = ?',
    whereArgs: const ['last_applied_server_seq'],
  );
  if (rows.isEmpty) return 0;
  return int.tryParse(rows[0]['value'] as String) ?? 0;
}

Future<void> setLastAppliedServerSeq(int seq) async {
  final db = await operationalSyncDatabase;
  await db.insert(
    'sync_meta',
    {'key': 'last_applied_server_seq', 'value': seq.toString()},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

/// Replace any pending ops for this homiletic, then enqueue a [homiletic.put].
Future<void> coalesceEnqueueHomileticPut({
  required String homileticUuid,
  required Map<String, dynamic> itemPayload,
}) async {
  final db = await operationalSyncDatabase;
  await db.delete(
    'sync_outbox',
    where: 'homiletic_uuid = ?',
    whereArgs: [homileticUuid],
  );
  await db.insert('sync_outbox', {
    'client_mutation_id': _uuid.v4(),
    'op_type': 'homiletic.put',
    'homiletic_uuid': homileticUuid,
    'payload_json': jsonEncode({'item': itemPayload}),
    'created_at': DateTime.now().toUtc().toIso8601String(),
  });
}

/// Clear pending ops for homiletic, enqueue [homiletic.delete].
Future<void> coalesceEnqueueHomileticDelete(String homileticUuid) async {
  final db = await operationalSyncDatabase;
  await db.delete(
    'sync_outbox',
    where: 'homiletic_uuid = ?',
    whereArgs: [homileticUuid],
  );
  await db.insert('sync_outbox', {
    'client_mutation_id': _uuid.v4(),
    'op_type': 'homiletic.delete',
    'homiletic_uuid': homileticUuid,
    'payload_json': jsonEncode({'homiletic_uuid': homileticUuid}),
    'created_at': DateTime.now().toUtc().toIso8601String(),
  });
}

Future<List<SyncOutboxRow>> listOutboxOrdered() async {
  final db = await operationalSyncDatabase;
  final maps = await db.query('sync_outbox', orderBy: 'id ASC');
  return maps
      .map((m) => SyncOutboxRow(
            id: m['id'] as int,
            clientMutationId: m['client_mutation_id'] as String,
            opType: m['op_type'] as String,
            homileticUuid: m['homiletic_uuid'] as String?,
            payloadJson: m['payload_json'] as String,
          ))
      .toList();
}

Future<void> deleteOutboxRowsByIds(List<int> ids) async {
  if (ids.isEmpty) return;
  final db = await operationalSyncDatabase;
  final batch = db.batch();
  for (final id in ids) {
    batch.delete('sync_outbox', where: 'id = ?', whereArgs: [id]);
  }
  await batch.commit(noResult: true);
}

Future<bool> outboxIsEmpty() async {
  final db = await operationalSyncDatabase;
  final c = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM sync_outbox'),
      ) ??
      0;
  return c == 0;
}

const _kHadInitialMerge = 'had_initial_server_merge';

Future<bool> hadInitialServerMerge() async {
  final db = await operationalSyncDatabase;
  final rows = await db.query(
    'sync_meta',
    where: 'key = ?',
    whereArgs: [_kHadInitialMerge],
  );
  return rows.isNotEmpty && rows.first['value'] == '1';
}

Future<void> setHadInitialServerMerge() async {
  final db = await operationalSyncDatabase;
  await db.insert(
    'sync_meta',
    {'key': _kHadInitialMerge, 'value': '1'},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

/// Call on sign-in / sign-out so the next session pulls a fresh server view.
Future<void> resetReplicationMeta() async {
  final db = await operationalSyncDatabase;
  await db.delete(
    'sync_meta',
    where: 'key IN (?, ?)',
    whereArgs: ['last_applied_server_seq', _kHadInitialMerge],
  );
}
