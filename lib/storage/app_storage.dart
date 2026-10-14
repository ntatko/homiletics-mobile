import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

/// Where the app's tables live for this run.
///
/// Normally that is the single [kAppDatabaseFileName] database. If the
/// one-time copy of the legacy per-table files into it fails, the app keeps
/// running on the legacy files exactly as before ([isUnified] is false) and
/// the copy is retried on the next launch — it never runs on an empty new
/// database while the user's data is still in the old files.
class AppStorage {
  AppStorage._unified(Database db)
      : _db = db,
        _factory = null,
        _directory = null;

  AppStorage._legacy(DatabaseFactory factory, String directory)
      : _db = null,
        _factory = factory,
        _directory = directory;

  final Database? _db;
  final DatabaseFactory? _factory;
  final String? _directory;
  final Map<String, Future<Database>> _legacyDbs = {};

  /// True when all tables are in the single database (foreign keys,
  /// cascading deletes and cross-table transactions available).
  bool get isUnified => _db != null;

  /// The database holding [table].
  Future<Database> databaseFor(String table) {
    final Database? db = _db;
    if (db != null) return Future<Database>.value(db);
    return _legacyDbs[table] ??=
        openLegacyDatabase(_factory!, _directory!, table);
  }

  /// Closes every open database (tests only).
  @visibleForTesting
  Future<void> close() async {
    await _db?.close();
    for (final Future<Database> db in _legacyDbs.values) {
      await (await db).close();
    }
    _legacyDbs.clear();
  }

  static Future<AppStorage>? _instance;

  /// The app's storage, opened (and migrated) on first use.
  static Future<AppStorage> get instance => _instance ??= _openDefault();

  /// The database holding [table] for this run.
  static Future<Database> database(String table) async =>
      (await instance).databaseFor(table);

  /// sqflite has no Windows or Linux implementation, so there the app uses
  /// sqflite_common_ffi's factory instead. Its default databases path is
  /// under the working directory (not writable for an installed app), so
  /// the databases go in the app support directory. Does nothing on other
  /// platforms. Call before [init] or anything else that opens a database.
  static Future<void> useFfiOnDesktop() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isLinux)) return;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final Directory support = await getApplicationSupportDirectory();
    final Directory databases = Directory(p.join(support.path, 'databases'));
    await databases.create(recursive: true);
    await databaseFactory.setDatabasesPath(databases.path);
  }

  /// Opens storage, running the one-time migration if needed. Call before
  /// `runApp` so the migration finishes before any screen reads data.
  /// Throws only if storage can't be used at all (see [open]).
  static Future<void> init() async {
    await instance;
  }

  /// Replaces the shared instance (tests only).
  @visibleForTesting
  static set debugInstance(Future<AppStorage>? storage) => _instance = storage;

  static Future<AppStorage> _openDefault() async => open(
        factory: databaseFactory,
        directory: await getDatabasesPath(),
      );

  /// Opens the single database in [directory] and migrates the legacy files
  /// into it.
  ///
  /// If that fails while the migration is known not to have completed, the
  /// error is reported as "storage migration failed" and the returned
  /// storage uses the legacy files; nothing is lost and the next launch
  /// retries. If it fails when the migration may already have completed
  /// (the new database exists but can't be read), falling back would show
  /// stale or empty legacy data and split new writes across files, so the
  /// error is rethrown instead.
  static Future<AppStorage> open({
    required DatabaseFactory factory,
    required String directory,
    StorageErrorReporter report = sendError,
    // For tests: see [migrateLegacyDatabases].
    void Function(String table, int rowsCopied)? onProgress,
  }) async {
    final String path = p.join(directory, kAppDatabaseFileName);
    // Known incomplete if the file is new; otherwise only once the flag has
    // been read and found missing.
    bool knownIncomplete = !await factory.databaseExists(path);
    Database? db;
    try {
      db = await openAppDatabase(factory, directory);
      if (!await isLegacyMigrationComplete(db)) knownIncomplete = true;
      await migrateLegacyDatabases(db,
          factory: factory,
          directory: directory,
          report: report,
          onProgress: onProgress);
      return AppStorage._unified(db);
    } catch (error) {
      unawaited(report(error, 'storage migration failed'));
      try {
        await db?.close();
      } catch (_) {}
      if (!knownIncomplete) rethrow;
      return AppStorage._legacy(factory, directory);
    }
  }
}

/// Opens the legacy per-table file for [table] with its original schema and
/// upgrade steps, as the app did before the single database. Only used
/// while the migration hasn't succeeded yet.
Future<Database> openLegacyDatabase(
    DatabaseFactory factory, String directory, String table) {
  final String path = p.join(directory, kLegacyDatabaseFiles[table]!);
  switch (table) {
    case 'homiletics':
      return factory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 2,
            onCreate: (db, version) => db.execute('''
              CREATE TABLE homiletics (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                passage TEXT,
                subject_sentence TEXT,
                aim TEXT,
                updated_at TEXT,
                fcf TEXT DEFAULT ''
              )
              '''),
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 2) {
                await db.execute(
                    "ALTER TABLE homiletics ADD COLUMN fcf TEXT DEFAULT ''");
              }
            },
          ));
    case 'content_summaries':
      return factory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) => db.execute('''
              CREATE TABLE content_summaries (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                summary TEXT,
                passage TEXT,
                sort INTEGER,
                homiletic_id INTEGER
              )
              '''),
          ));
    case 'divisions':
      return factory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) => db.execute('''
              CREATE TABLE divisions (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                title TEXT,
                passage TEXT,
                sort INTEGER,
                homiletic_id INTEGER
              )
              '''),
          ));
    case 'applications':
      return factory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) => db.execute('''
              CREATE TABLE applications (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                text TEXT,
                homiletic_id INTEGER
              )
              '''),
          ));
    case 'lectures':
      return factory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 4,
            onCreate: (db, version) => db.execute('''
              CREATE TABLE lectures (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                note TEXT,
                passage TEXT,
                time TEXT,
                recording_path TEXT,
                transcript TEXT,
                formatted_transcript TEXT
              )
              '''),
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 2) {
                await db.execute(
                    'ALTER TABLE lectures ADD COLUMN recording_path TEXT');
              }
              if (oldVersion < 3) {
                await db
                    .execute('ALTER TABLE lectures ADD COLUMN transcript TEXT');
              }
              if (oldVersion < 4) {
                await db.execute(
                    'ALTER TABLE lectures ADD COLUMN formatted_transcript TEXT');
              }
            },
          ));
    case 'word_studies':
      return factory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) => db.execute('''
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
              '''),
          ));
  }
  throw ArgumentError.value(table, 'table');
}
