import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The single database file holding all user data.
///
/// Before this, each table lived in its own file (see
/// [kLegacyDatabaseFiles]), so deleting a homiletic and its rows could not be
/// atomic. Those files are copied in here once by [migrateLegacyDatabases].
const String kAppDatabaseFileName = 'homiletics_v2.db';

/// Schema version of [kAppDatabaseFileName], stored in SQLite's
/// `user_version`. Bump it and add a step to [_upgradeSchema] to change the
/// schema.
const int kAppDatabaseVersion = 1;

/// Suffix given to a legacy database file once its rows are safely in the
/// new database. The files are kept, never deleted.
const String kMigratedBackupSuffix = '.migrated-backup';

/// Each table and the separate file it used to live in.
const Map<String, String> kLegacyDatabaseFiles = {
  'homiletics': 'homiletics.db',
  'content_summaries': 'contentSummaries.db',
  'divisions': 'divisions.db',
  'applications': 'applications.db',
  'lectures': 'lectures.db',
  'word_studies': 'word_studies.db',
};

/// Tables that belong to a homiletic, via their `homiletic_id` column.
const List<String> kHomileticChildTables = [
  'content_summaries',
  'divisions',
  'applications',
];

/// Every column of every table, in order. These are exactly the columns of
/// the legacy tables (at their latest legacy versions).
const Map<String, List<String>> kTableColumns = {
  'homiletics': [
    'id',
    'passage',
    'subject_sentence',
    'aim',
    'updated_at',
    'fcf',
  ],
  'content_summaries': ['id', 'summary', 'passage', 'sort', 'homiletic_id'],
  'divisions': ['id', 'title', 'passage', 'sort', 'homiletic_id'],
  'applications': ['id', 'text', 'homiletic_id'],
  'lectures': [
    'id',
    'note',
    'passage',
    'time',
    'recording_path',
    'transcript',
    'formatted_transcript',
  ],
  'word_studies': [
    'id',
    'passage',
    'word',
    'definition',
    'other_usage',
    'contextual_meaning',
    'deeper_meaning',
    'application',
    'updated_at',
  ],
};

/// Value a column gets when an older legacy file predates it — the same
/// value the legacy `ALTER TABLE ... ADD COLUMN` upgrade would have given
/// existing rows (`fcf` was added with `DEFAULT ''`, the lecture columns with
/// no default).
const Map<String, Map<String, Object?>> _legacyAddedColumnDefaults = {
  'homiletics': {'fcf': ''},
  'lectures': {
    'recording_path': null,
    'transcript': null,
    'formatted_transcript': null,
  },
};

/// `storage_meta` key set (in the same transaction as the copied rows) once
/// the legacy files have been copied and verified.
const String kMigrationCompleteKey = 'legacy_migration_completed_at';

/// `storage_meta` key holding a JSON summary of what was migrated.
const String kMigrationReportKey = 'legacy_migration_report';

/// Schema of version 1. Children reference their homiletic and go with it.
const List<String> _schemaV1 = [
  '''
  CREATE TABLE homiletics (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    passage TEXT,
    subject_sentence TEXT,
    aim TEXT,
    updated_at TEXT,
    fcf TEXT DEFAULT ''
  )
  ''',
  '''
  CREATE TABLE content_summaries (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    summary TEXT,
    passage TEXT,
    sort INTEGER,
    homiletic_id INTEGER NOT NULL
      REFERENCES homiletics(id) ON DELETE CASCADE
  )
  ''',
  'CREATE INDEX idx_content_summaries_homiletic_id '
      'ON content_summaries(homiletic_id)',
  '''
  CREATE TABLE divisions (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    passage TEXT,
    sort INTEGER,
    homiletic_id INTEGER NOT NULL
      REFERENCES homiletics(id) ON DELETE CASCADE
  )
  ''',
  'CREATE INDEX idx_divisions_homiletic_id ON divisions(homiletic_id)',
  '''
  CREATE TABLE applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    text TEXT,
    homiletic_id INTEGER NOT NULL
      REFERENCES homiletics(id) ON DELETE CASCADE
  )
  ''',
  'CREATE INDEX idx_applications_homiletic_id ON applications(homiletic_id)',
  '''
  CREATE TABLE lectures (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    note TEXT,
    passage TEXT,
    time TEXT,
    recording_path TEXT,
    transcript TEXT,
    formatted_transcript TEXT
  )
  ''',
  '''
  CREATE TABLE word_studies (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    passage TEXT,
    word TEXT,
    definition TEXT,
    other_usage TEXT,
    contextual_meaning TEXT,
    deeper_meaning TEXT,
    application TEXT,
    updated_at TEXT
  )
  ''',
  '''
  CREATE TABLE storage_meta (
    key TEXT PRIMARY KEY NOT NULL,
    value TEXT
  )
  ''',
];

Future<void> _createSchema(Database db, int version) async {
  final Batch batch = db.batch();
  for (final String statement in _schemaV1) {
    batch.execute(statement);
  }
  await batch.commit(noResult: true);
  // Future versions: create v1, then run the upgrade steps up to [version].
  await _upgradeSchema(db, 1, version);
}

/// SQL to run to reach each schema version after 1, e.g.
/// `2: ['ALTER TABLE lectures ADD COLUMN ...']`.
const Map<int, List<String>> _upgradeSteps = {};

Future<void> _upgradeSchema(Database db, int oldVersion, int newVersion) async {
  for (int version = oldVersion + 1; version <= newVersion; version++) {
    final List<String>? steps = _upgradeSteps[version];
    if (steps == null) {
      throw StateError('No upgrade step to storage schema v$version');
    }
    for (final String statement in steps) {
      await db.execute(statement);
    }
  }
}

/// Opens (creating if needed) the single app database in [directory].
Future<Database> openAppDatabase(
    DatabaseFactory factory, String directory) async {
  return factory.openDatabase(
    p.join(directory, kAppDatabaseFileName),
    options: OpenDatabaseOptions(
      version: kAppDatabaseVersion,
      // Foreign keys are off by default in SQLite and must be enabled on
      // every connection.
      onConfigure: (Database db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    ),
  );
}

/// Whether the legacy rows have already been copied into [db].
Future<bool> isLegacyMigrationComplete(DatabaseExecutor db) async {
  final List<Map<String, Object?>> rows = await db.query('storage_meta',
      where: 'key = ?', whereArgs: [kMigrationCompleteKey]);
  return rows.isNotEmpty;
}

/// Reports an error; matches [sendError].
typedef StorageErrorReporter = Future<void> Function(
    Object error, String identifier);

/// What [migrateLegacyDatabases] did.
class LegacyMigrationResult {
  /// True if an earlier launch already finished the copy, so nothing was
  /// copied this time.
  final bool alreadyComplete;

  /// Rows copied, per table.
  final Map<String, int> copied;

  /// Child rows not copied because their homiletic no longer exists, per
  /// table. They are still in the backup files.
  final Map<String, int> orphansDropped;

  /// Legacy files renamed to `*.migrated-backup` this time.
  final List<String> backedUp;

  const LegacyMigrationResult({
    required this.alreadyComplete,
    this.copied = const {},
    this.orphansDropped = const {},
    this.backedUp = const [],
  });

  int get totalOrphansDropped =>
      orphansDropped.values.fold(0, (int a, int b) => a + b);
}

/// Thrown when copied data doesn't read back identical to its source. The
/// copy is rolled back and the legacy files are left alone.
class LegacyMigrationVerificationException implements Exception {
  final String message;
  LegacyMigrationVerificationException(this.message);
  @override
  String toString() => 'LegacyMigrationVerificationException: $message';
}

/// Rows read from one legacy file.
class _LegacyTable {
  final List<Map<String, Object?>> rows;
  final int sequence;
  _LegacyTable(this.rows, this.sequence);
}

/// Copies every row of the legacy per-table files in [directory] into
/// [target], then renames those files to `*.migrated-backup`.
///
/// - All rows are copied in ONE transaction on [target], keeping their ids
///   (so children still point at their homiletic) and timestamps.
/// - Children whose homiletic no longer exists (left behind by the old
///   non-atomic delete) are not copied — the user had deleted that
///   homiletic, and they would break the foreign key. The count is reported
///   as "storage migration orphans"; the rows stay in the backup files.
/// - Before committing, every copied row is read back and compared with its
///   source, and the foreign keys are checked. Only then, in the same
///   transaction, is [kMigrationCompleteKey] written.
/// - Only after the commit are the legacy files renamed (never deleted). A
///   failed rename is reported and retried on the next call.
///
/// If anything throws before the commit, nothing is written to [target] and
/// the legacy files are untouched, so the next call starts over cleanly.
///
/// [onProgress] is called after each chunk of rows is inserted (for tests,
/// which throw from it to simulate a failure mid-copy).
Future<LegacyMigrationResult> migrateLegacyDatabases(
  Database target, {
  required DatabaseFactory factory,
  required String directory,
  StorageErrorReporter report = sendError,
  void Function(String table, int rowsCopied)? onProgress,
}) async {
  if (await isLegacyMigrationComplete(target)) {
    final List<String> backedUp =
        await _backUpLegacyFiles(factory, directory, report);
    return LegacyMigrationResult(alreadyComplete: true, backedUp: backedUp);
  }

  // Read everything first, outside the write transaction.
  final Map<String, _LegacyTable> legacy = {};
  for (final MapEntry<String, String> entry in kLegacyDatabaseFiles.entries) {
    legacy[entry.key] = await _readLegacyTable(
        factory, p.join(directory, entry.value), entry.key);
  }

  final Set<Object?> homileticIds = {
    for (final Map<String, Object?> row in legacy['homiletics']!.rows) row['id']
  };
  final Map<String, List<Map<String, Object?>>> toCopy = {};
  final Map<String, int> orphans = {};
  for (final String table in kTableColumns.keys) {
    final List<Map<String, Object?>> rows = legacy[table]!.rows;
    if (kHomileticChildTables.contains(table)) {
      final List<Map<String, Object?>> kept = [
        for (final Map<String, Object?> row in rows)
          if (row['homiletic_id'] != null &&
              homileticIds.contains(row['homiletic_id']))
            row
      ];
      orphans[table] = rows.length - kept.length;
      toCopy[table] = kept;
    } else {
      toCopy[table] = rows;
    }
  }

  final String completedAt = DateTime.now().toUtc().toIso8601String();
  final Map<String, int> copied = {
    for (final String table in kTableColumns.keys) table: toCopy[table]!.length
  };

  await target.transaction((Transaction txn) async {
    // Nothing writes here before the flag is set, so these are empty unless
    // something odd happened; the legacy files are the source of truth
    // until then, so start from a clean slate.
    for (final String table in kTableColumns.keys.toList().reversed) {
      await txn.delete(table);
    }
    await txn.delete('sqlite_sequence');

    // Parents first, so the foreign keys hold row by row.
    for (final String table in kTableColumns.keys) {
      final List<Map<String, Object?>> rows = toCopy[table]!;
      const int chunkSize = 100;
      for (int start = 0; start < rows.length; start += chunkSize) {
        final Batch batch = txn.batch();
        for (final Map<String, Object?> row
            in rows.skip(start).take(chunkSize)) {
          // Default conflict handling (abort): a duplicate id must fail
          // loudly, never replace a row.
          batch.insert(table, row);
        }
        await batch.commit(noResult: true);
        onProgress?.call(table, (start + chunkSize).clamp(0, rows.length));
      }
      // Keep AUTOINCREMENT from handing out an id the user had before
      // (e.g. a deleted homiletic's id that orphans in the backup refer to).
      final int sequence = legacy[table]!.sequence;
      if (sequence > 0) {
        final int updated = await txn.rawUpdate(
            'UPDATE sqlite_sequence SET seq = MAX(seq, ?) WHERE name = ?',
            [sequence, table]);
        if (updated == 0) {
          await txn.insert('sqlite_sequence', {'name': table, 'seq': sequence});
        }
      }
    }

    await _verifyCopy(txn, toCopy);

    await txn.insert('storage_meta', {
      'key': kMigrationReportKey,
      'value': jsonEncode({
        'completed_at': completedAt,
        'copied': copied,
        'orphans_dropped': orphans,
      }),
    });
    await txn.insert(
        'storage_meta', {'key': kMigrationCompleteKey, 'value': completedAt});
  });

  final int orphanTotal = orphans.values.fold(0, (int a, int b) => a + b);
  if (orphanTotal > 0) {
    // Counts only — never row content.
    unawaited(report(
        'dropped $orphanTotal orphaned rows '
            '(${orphans.entries.where((e) => e.value > 0).map((e) => '${e.key}: ${e.value}').join(', ')})',
        'storage migration orphans'));
  }

  final List<String> backedUp =
      await _backUpLegacyFiles(factory, directory, report);
  return LegacyMigrationResult(
    alreadyComplete: false,
    copied: copied,
    orphansDropped: orphans,
    backedUp: backedUp,
  );
}

/// Reads all rows of [table] from the legacy file at [path] (none if the
/// file or table doesn't exist), filling in columns an older file predates.
Future<_LegacyTable> _readLegacyTable(
    DatabaseFactory factory, String path, String table) async {
  if (!await factory.databaseExists(path)) {
    return _LegacyTable(const [], 0);
  }
  // No version: opening must not run any create/upgrade step on the old
  // file. Not read-only, so a pending WAL can be read and checkpointed.
  final Database db = await factory.openDatabase(path,
      options: OpenDatabaseOptions(singleInstance: false));
  try {
    final List<Map<String, Object?>> tables = await db.query('sqlite_master',
        columns: ['name'],
        where: "type = 'table' AND name = ?",
        whereArgs: [table]);
    if (tables.isEmpty) return _LegacyTable(const [], 0);

    final List<String> known = kTableColumns[table]!;
    final Set<String> present = {
      for (final Map<String, Object?> c
          in await db.rawQuery('PRAGMA table_info($table)'))
        c['name'] as String
    };
    final Set<String> unknown = present.difference(known.toSet());
    if (unknown.isNotEmpty) {
      // Copying would silently lose these; better to keep the old files in
      // use until the migration knows about them.
      throw StateError('legacy $table has unknown columns: $unknown');
    }
    final Set<String> missing = known.toSet().difference(present);
    final Map<String, Object?> defaults =
        _legacyAddedColumnDefaults[table] ?? const {};
    final Set<String> unfillable = missing.difference(defaults.keys.toSet());
    if (unfillable.isNotEmpty) {
      throw StateError('legacy $table is missing columns: $unfillable');
    }

    final List<Map<String, Object?>> rows = [
      for (final Map<String, Object?> row
          in await db.query(table, orderBy: 'id'))
        {
          for (final String column in known)
            column: present.contains(column) ? row[column] : defaults[column]
        }
    ];

    int sequence = 0;
    final bool hasSequence = (await db.query('sqlite_master',
            where: "type = 'table' AND name = 'sqlite_sequence'"))
        .isNotEmpty;
    if (hasSequence) {
      final List<Map<String, Object?>> seq = await db.query('sqlite_sequence',
          columns: ['seq'], where: 'name = ?', whereArgs: [table]);
      if (seq.isNotEmpty) sequence = (seq.first['seq'] as int?) ?? 0;
    }
    return _LegacyTable(rows, sequence);
  } finally {
    await db.close();
  }
}

/// Reads back every copied row and checks it is identical to its source,
/// and that no foreign key is broken. Throws (rolling the copy back) if not.
Future<void> _verifyCopy(
    Transaction txn, Map<String, List<Map<String, Object?>>> expected) async {
  for (final MapEntry<String, List<Map<String, Object?>>> entry
      in expected.entries) {
    final String table = entry.key;
    final List<Map<String, Object?>> actual =
        await txn.query(table, orderBy: 'id');
    if (actual.length != entry.value.length) {
      throw LegacyMigrationVerificationException(
          '$table: expected ${entry.value.length} rows, found ${actual.length}');
    }
    for (int i = 0; i < actual.length; i++) {
      for (final String column in kTableColumns[table]!) {
        if (!_sameValue(actual[i][column], entry.value[i][column])) {
          throw LegacyMigrationVerificationException(
              '$table: row ${entry.value[i]['id']} column $column differs');
        }
      }
    }
  }
  final List<Map<String, Object?>> broken =
      await txn.rawQuery('PRAGMA foreign_key_check');
  if (broken.isNotEmpty) {
    throw LegacyMigrationVerificationException(
        '${broken.length} foreign key violations');
  }
}

bool _sameValue(Object? a, Object? b) {
  if (a is List && b is List) return listEquals(a, b);
  return a == b;
}

/// Renames any legacy files (and their journal/WAL side files) still in
/// [directory] to `*.migrated-backup`. Only call once the migration is
/// complete. Failures are reported, not thrown; the next launch retries.
Future<List<String>> _backUpLegacyFiles(DatabaseFactory factory,
    String directory, StorageErrorReporter report) async {
  final List<String> backedUp = [];
  for (final String name in kLegacyDatabaseFiles.values) {
    final String path = p.join(directory, name);
    try {
      if (!await File(path).exists()) continue;
      String backup = '$path$kMigratedBackupSuffix';
      if (await File(backup).exists()) {
        // Never overwrite an earlier backup.
        backup = '$path.${DateTime.now().millisecondsSinceEpoch}'
            '$kMigratedBackupSuffix';
      }
      // Side files first: if the main file is renamed, its journal must go
      // with it, or SQLite could apply it to the wrong database.
      for (final String suffix in const ['-wal', '-shm', '-journal']) {
        final File side = File('$path$suffix');
        if (await side.exists()) await side.rename('$backup$suffix');
      }
      await File(path).rename(backup);
      backedUp.add(name);
    } catch (error) {
      unawaited(report(error, 'storage migration backup rename'));
    }
  }
  return backedUp;
}
