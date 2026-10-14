import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/storage/app_database.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final DatabaseFactory factory = databaseFactoryFfiNoIsolate;

/// The legacy schemas, exactly as the old storage files created them.
const Map<String, String> legacySchema = {
  'homiletics': '''
    CREATE TABLE homiletics (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      passage TEXT, subject_sentence TEXT, aim TEXT, updated_at TEXT,
      fcf TEXT DEFAULT '')''',
  'content_summaries': '''
    CREATE TABLE content_summaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      summary TEXT, passage TEXT, sort INTEGER, homiletic_id INTEGER)''',
  'divisions': '''
    CREATE TABLE divisions (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT, passage TEXT, sort INTEGER, homiletic_id INTEGER)''',
  'applications': '''
    CREATE TABLE applications (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      text TEXT, homiletic_id INTEGER)''',
  'lectures': '''
    CREATE TABLE lectures (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      note TEXT, passage TEXT, time TEXT, recording_path TEXT,
      transcript TEXT, formatted_transcript TEXT)''',
  'word_studies': '''
    CREATE TABLE word_studies (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      passage TEXT, word TEXT, definition TEXT, other_usage TEXT,
      contextual_meaning TEXT, deeper_meaning TEXT, application TEXT,
      updated_at TEXT)''',
};

/// Legacy `user_version` of each file at its latest schema.
const Map<String, int> legacyVersion = {
  'homiletics': 2,
  'content_summaries': 1,
  'divisions': 1,
  'applications': 1,
  'lectures': 4,
  'word_studies': 1,
};

const String longTranscript =
    'In the beginning was the Word, and the Word was with God. ';

/// Realistic data: gaps in ids from deletes, orphans from the old
/// non-atomic delete, NULL and '' legacy values, unicode.
final Map<String, List<Map<String, Object?>>> fixture = {
  'homiletics': [
    {
      'id': 1,
      'passage': 'John 1:1-18',
      'subject_sentence': 'The Word became flesh and dwelt among us',
      'aim': 'To see Jesus as God made known',
      'updated_at': '2024-02-11T09:30:00.000',
      'fcf': 'We look for God elsewhere',
    },
    {
      'id': 2,
      'passage': 'Génesis 1',
      'subject_sentence': null,
      'aim': '',
      'updated_at': '',
      'fcf': null,
    },
    {
      'id': 5,
      'passage': '约翰福音 3:16',
      'subject_sentence': '神爱世人',
      'aim': 'Believe',
      'updated_at': '2025-06-01T18:00:00.123456',
      'fcf': '',
    },
  ],
  'content_summaries': [
    {
      'id': 1,
      'summary': 'The Word was God',
      'passage': '1-2',
      'sort': null,
      'homiletic_id': 1
    },
    {
      'id': 2,
      'summary': 'John testified',
      'passage': '6-8',
      'sort': 2,
      'homiletic_id': 1
    },
    {'id': 4, 'summary': null, 'passage': '', 'sort': null, 'homiletic_id': 2},
    // Orphans: homiletic 3 was deleted; one row never had a homiletic.
    {
      'id': 7,
      'summary': 'Orphaned summary',
      'passage': '1',
      'sort': null,
      'homiletic_id': 3
    },
    {
      'id': 8,
      'summary': 'No homiletic',
      'passage': '',
      'sort': null,
      'homiletic_id': null
    },
  ],
  'divisions': [
    {
      'id': 1,
      'title': 'The eternal Word',
      'passage': '1-5',
      'sort': 1,
      'homiletic_id': 1
    },
    {
      'id': 3,
      'title': 'God so loved',
      'passage': '16',
      'sort': null,
      'homiletic_id': 5
    },
    {
      'id': 9,
      'title': 'Orphaned division',
      'passage': '',
      'sort': null,
      'homiletic_id': 4
    },
  ],
  'applications': [
    {'id': 1, 'text': 'Read Genesis 1 aloud', 'homiletic_id': 2},
    {'id': 2, 'text': '', 'homiletic_id': 5},
    {'id': 3, 'text': 'Orphaned application', 'homiletic_id': 6},
    {'id': 4, 'text': 'Saved before its homiletic', 'homiletic_id': -1},
  ],
  'lectures': [
    {
      'id': 1,
      'note': 'Lecture on John 1',
      'passage': 'John 1:1-18',
      'time': '2024-02-12T19:00:00.000',
      'recording_path':
          '/var/mobile/Containers/Data/Application/ABC/Documents/lecture_1_5.m4a',
      'transcript': longTranscript * 200,
      'formatted_transcript': 'In the beginning was the Word.\n\nAnd the Word…',
    },
    {
      'id': 2,
      'note': null,
      'passage': null,
      'time': null,
      'recording_path': null,
      'transcript': null,
      'formatted_transcript': null,
    },
    {
      'id': 6,
      'note': '',
      'passage': '',
      'time': '',
      'recording_path': 'lecture_6_9.m4a',
      'transcript': '',
      'formatted_transcript': '',
    },
  ],
  'word_studies': [
    {
      'id': 1,
      'passage': 'John 1:1',
      'word': 'Logos',
      'definition': 'Word, reason',
      'other_usage': 'Genesis 1; Psalm 33:6',
      'contextual_meaning': 'God’s self-expression',
      'deeper_meaning': 'λόγος',
      'application': 'Listen to Him',
      'updated_at': '2024-02-13T08:00:00.000',
    },
    {
      'id': 2,
      'passage': null,
      'word': '',
      'definition': null,
      'other_usage': null,
      'contextual_meaning': '',
      'deeper_meaning': null,
      'application': null,
      'updated_at': null,
    },
  ],
};

/// Ids the old app had already handed out (so AUTOINCREMENT must not reuse
/// them).
const Map<String, int> fixtureSequence = {
  'homiletics': 6,
  'content_summaries': 8,
  'divisions': 9,
  'applications': 4,
  'lectures': 7,
  'word_studies': 2,
};

const Map<String, Set<int>> orphanIds = {
  'content_summaries': {7, 8},
  'divisions': {9},
  'applications': {3, 4},
};

List<Map<String, Object?>> expectedRows(String table) => [
      for (final row in fixture[table]!)
        if (!(orphanIds[table] ?? const {}).contains(row['id'])) row
    ];

/// Creates one legacy file for [table] with [rows]. [schema] / [version]
/// override the latest legacy schema to simulate an older file.
Future<void> createLegacyFile(
  String dir,
  String table,
  List<Map<String, Object?>> rows, {
  String? schema,
  int? version,
  int? sequence,
}) async {
  final Database db = await factory.openDatabase(
    p.join(dir, kLegacyDatabaseFiles[table]!),
    options: OpenDatabaseOptions(
      version: version ?? legacyVersion[table]!,
      onCreate: (db, _) => db.execute(schema ?? legacySchema[table]!),
    ),
  );
  for (final row in rows) {
    await db.insert(table, row);
  }
  if (sequence != null) {
    await db.update('sqlite_sequence', {'seq': sequence},
        where: 'name = ?', whereArgs: [table]);
  }
  await db.close();
}

Future<void> createAllLegacyFiles(String dir) async {
  for (final table in kLegacyDatabaseFiles.keys) {
    await createLegacyFile(dir, table, fixture[table]!,
        sequence: fixtureSequence[table]);
  }
}

Map<String, List<int>> snapshotFiles(String dir) => {
      for (final f in Directory(dir).listSync().whereType<File>())
        p.basename(f.path): f.readAsBytesSync()
    };

class Reports {
  final List<String> identifiers = [];
  final List<String> messages = [];
  Future<void> call(Object error, String identifier) async {
    identifiers.add(identifier);
    messages.add(error.toString());
  }
}

void main() {
  // Stubs HTTP, so sendError calls from storage functions never leave the
  // machine.
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory tmp;
  late String dir;
  late Reports reports;
  AppStorage? storage;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('storage_migration_');
    dir = tmp.path;
    reports = Reports();
  });

  tearDown(() async {
    await storage?.close();
    storage = null;
    AppStorage.debugInstance = null;
    tmp.deleteSync(recursive: true);
  });

  Future<AppStorage> openStorage(
      {void Function(String, int)? onProgress}) async {
    await storage?.close();
    storage = await AppStorage.open(
        factory: factory,
        directory: dir,
        report: reports.call,
        onProgress: onProgress);
    AppStorage.debugInstance = Future.value(storage);
    return storage!;
  }

  Future<Database> newDb() => storage!.databaseFor('homiletics');

  Future<void> expectAllMigrated() async {
    final Database db = await newDb();
    for (final table in kTableColumns.keys) {
      final rows = await db.query(table, orderBy: 'id');
      expect(rows, expectedRows(table), reason: table);
    }
  }

  test('copies every row, field and id, drops orphans, backs up old files',
      () async {
    await createAllLegacyFiles(dir);
    final AppStorage s = await openStorage();

    expect(s.isUnified, isTrue);
    await expectAllMigrated();

    final Database db = await newDb();
    expect(await isLegacyMigrationComplete(db), isTrue);
    expect((await db.rawQuery('PRAGMA foreign_keys')).first.values.first, 1);
    expect(await db.getVersion(), kAppDatabaseVersion);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);

    // Orphans reported by count only, never content.
    expect(reports.identifiers, ['storage migration orphans']);
    expect(reports.messages.single, contains('dropped 5 orphaned rows'));
    expect(reports.messages.single, isNot(contains('Orphaned')));

    // Old files are renamed, not deleted, and still hold every row
    // (orphans included).
    for (final entry in kLegacyDatabaseFiles.entries) {
      final String legacy = p.join(dir, entry.value);
      expect(File(legacy).existsSync(), isFalse, reason: entry.value);
      final String backup = '$legacy$kMigratedBackupSuffix';
      expect(File(backup).existsSync(), isTrue, reason: entry.value);
      final Database old = await factory.openDatabase(backup,
          options: OpenDatabaseOptions(readOnly: true, singleInstance: false));
      expect(await old.query(entry.key, orderBy: 'id'), fixture[entry.key]);
      await old.close();
    }

    // AUTOINCREMENT carries on past ids the old app had used.
    for (final entry in fixtureSequence.entries) {
      final seq = await db
          .query('sqlite_sequence', where: 'name = ?', whereArgs: [entry.key]);
      expect(seq.single['seq'], entry.value, reason: entry.key);
    }
    final int newId = await insertHomiletic(Homiletic(passage: 'Mark 1'));
    expect(newId, 7);

    // Models read the migrated rows as before.
    final List<Homiletic> homiletics = await getAllHomiletics();
    expect(homiletics.map((h) => h.id), [1, 2, 5, 7]);
    expect(homiletics.first.fcf, 'We look for God elsewhere');
    expect(homiletics.first.updatedAt, DateTime(2024, 2, 11, 9, 30));
    final List<LectureNote> notes = await getLectureNotes();
    expect(notes.first.recordingPath, 'lecture_1_5.m4a');
    expect(notes.first.transcript, longTranscript * 200);
    expect(notes[2].recordingPath, 'lecture_6_9.m4a');
    expect((await getSummariesByHomileticId(1)).map((c) => c.id), [1, 2]);
    expect((await getAllApplicationsWithPassages()).map((a) => a.id), [1, 2]);
    expect((await getAllWordStudies()).first.deeperMeaning, 'λόγος');
  });

  test('rerunning after success is a no-op', () async {
    await createAllLegacyFiles(dir);
    await openStorage();
    final Database db = await newDb();
    final List<Map<String, Object?>> meta = await db.query('storage_meta');

    final LegacyMigrationResult again = await migrateLegacyDatabases(db,
        factory: factory, directory: dir, report: reports.call);
    expect(again.alreadyComplete, isTrue);
    expect(again.backedUp, isEmpty);

    await openStorage();
    await expectAllMigrated();
    expect(await (await newDb()).query('storage_meta'), meta);
    expect(reports.identifiers, ['storage migration orphans']);
  });

  test('a failure mid-copy rolls back, leaves old files intact, and retries',
      () async {
    await createAllLegacyFiles(dir);
    final Map<String, List<int>> before = snapshotFiles(dir);

    final AppStorage failed = await openStorage(onProgress: (table, _) {
      if (table == 'lectures') throw StateError('simulated crash');
    });

    // Falls back to the old files instead of an empty new database.
    expect(failed.isUnified, isFalse);
    expect(reports.identifiers, ['storage migration failed']);
    final Map<String, List<int>> after = snapshotFiles(dir);
    for (final entry in before.entries) {
      expect(after[entry.key], entry.value, reason: entry.key);
    }
    expect(after.keys.where((k) => k.endsWith(kMigratedBackupSuffix)), isEmpty);

    // Nothing was committed to the new database.
    final Database fresh = await factory.openDatabase(
        p.join(dir, kAppDatabaseFileName),
        options: OpenDatabaseOptions(singleInstance: false));
    for (final table in kTableColumns.keys) {
      expect(await fresh.query(table), isEmpty, reason: table);
    }
    expect(await fresh.query('storage_meta'), isEmpty);
    await fresh.close();

    // The app keeps working on the old files, including new writes...
    expect((await getAllHomiletics()).map((h) => h.id), [1, 2, 5]);
    final Homiletic added = Homiletic(passage: 'Acts 2');
    await added.update();
    expect(added.id, 7);
    await Division.blank(added.id).updateText('Pentecost');

    // ...and the next launch migrates everything, those writes included.
    reports.identifiers.clear();
    final AppStorage retried = await openStorage();
    expect(retried.isUnified, isTrue);
    final Database db = await newDb();
    expect((await db.query('homiletics')).map((r) => r['id']), [1, 2, 5, 7]);
    final divisions = await db.query('divisions', orderBy: 'id');
    expect(divisions.map((r) => r['id']), [1, 3, 10]);
    expect(divisions.last['title'], 'Pentecost');
    expect(divisions.last['homiletic_id'], 7);
    expect(reports.identifiers, ['storage migration orphans']);
    for (final file in kLegacyDatabaseFiles.values) {
      expect(File(p.join(dir, file)).existsSync(), isFalse);
    }
  });

  test('migrates older legacy schemas (homiletics v1 without fcf, lectures v1)',
      () async {
    await createLegacyFile(
      dir,
      'homiletics',
      [
        {
          'id': 1,
          'passage': 'Romans 8',
          'subject_sentence': 'No condemnation',
          'aim': 'Rest',
          'updated_at': '2021-01-01T00:00:00.000'
        }
      ],
      schema: '''
        CREATE TABLE homiletics (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          passage TEXT, subject_sentence TEXT, aim TEXT, updated_at TEXT)''',
      version: 1,
    );
    await createLegacyFile(
      dir,
      'lectures',
      [
        {'id': 3, 'note': 'Old note', 'passage': 'Romans 8', 'time': ''}
      ],
      schema: '''
        CREATE TABLE lectures (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          note TEXT, passage TEXT, time TEXT)''',
      version: 1,
    );
    await createLegacyFile(dir, 'divisions', [
      {'id': 1, 'title': 'T', 'passage': '1', 'sort': null, 'homiletic_id': 1}
    ]);

    await openStorage();
    final Database db = await newDb();
    expect(await db.query('homiletics'), [
      {
        'id': 1,
        'passage': 'Romans 8',
        'subject_sentence': 'No condemnation',
        'aim': 'Rest',
        'updated_at': '2021-01-01T00:00:00.000',
        'fcf': '',
      }
    ]);
    expect(await db.query('lectures'), [
      {
        'id': 3,
        'note': 'Old note',
        'passage': 'Romans 8',
        'time': '',
        'recording_path': null,
        'transcript': null,
        'formatted_transcript': null,
      }
    ]);
    expect(await db.query('divisions'), hasLength(1));
    expect(reports.identifiers, isEmpty);
  });

  test('fresh install: no old files, empty database marked migrated', () async {
    final AppStorage s = await openStorage();
    expect(s.isUnified, isTrue);
    expect(await isLegacyMigrationComplete(await newDb()), isTrue);
    expect(reports.identifiers, isEmpty);
    expect(Directory(dir).listSync().map((e) => p.basename(e.path)),
        isNot(contains(endsWith(kMigratedBackupSuffix))));
  });

  test('an unknown legacy column keeps the old files in use', () async {
    await createLegacyFile(dir, 'word_studies', [
      {'id': 1, 'word': 'agape', 'mystery': 'x'}
    ], schema: '''
        CREATE TABLE word_studies (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          passage TEXT, word TEXT, definition TEXT, other_usage TEXT,
          contextual_meaning TEXT, deeper_meaning TEXT, application TEXT,
          updated_at TEXT, mystery TEXT)''');
    final AppStorage s = await openStorage();
    expect(s.isUnified, isFalse);
    expect(reports.messages.single, contains('unknown columns'));
    expect(File(p.join(dir, 'word_studies.db')).existsSync(), isTrue);
    expect((await getAllWordStudies()).single.word, 'agape');
  });

  test('a completed migration finishes renames left over from a failed one',
      () async {
    await createAllLegacyFiles(dir);
    await openStorage();
    // Simulate a rename that failed: the old file is still there.
    final String legacy = p.join(dir, 'homiletics.db');
    File('$legacy$kMigratedBackupSuffix').copySync(legacy);

    await openStorage();
    await expectAllMigrated();
    expect(File(legacy).existsSync(), isFalse);
    expect(File('$legacy$kMigratedBackupSuffix').existsSync(), isTrue);
    final others = Directory(dir)
        .listSync()
        .map((e) => p.basename(e.path))
        .where((n) =>
            n.startsWith('homiletics.db.') &&
            n.endsWith(kMigratedBackupSuffix) &&
            n != 'homiletics.db$kMigratedBackupSuffix');
    expect(others, hasLength(1));
  });

  test('an unreadable new database after migration is fatal, not a fallback',
      () async {
    await createAllLegacyFiles(dir);
    await openStorage();
    await storage!.close();
    storage = null;
    File(p.join(dir, kAppDatabaseFileName))
        .writeAsBytesSync(List<int>.filled(4096, 7));

    await expectLater(
        AppStorage.open(factory: factory, directory: dir, report: reports.call),
        throwsA(anything));
    expect(reports.identifiers.last, 'storage migration failed');
    // No empty legacy files were created in its place.
    expect(File(p.join(dir, 'homiletics.db')).existsSync(), isFalse);
  });

  group('cascade delete', () {
    test('deleting a homiletic row removes its children', () async {
      await createAllLegacyFiles(dir);
      await openStorage();
      final Database db = await newDb();
      await db.delete('homiletics', where: 'id = ?', whereArgs: [1]);
      for (final table in kHomileticChildTables) {
        expect(await db.query(table, where: 'homiletic_id = 1'), isEmpty,
            reason: table);
      }
      expect(
          await db.query('divisions', where: 'homiletic_id = 5'), hasLength(1));
    });

    test('Homiletic.delete removes it and its rows in one go', () async {
      await createAllLegacyFiles(dir);
      await openStorage();
      final Homiletic h = await getHomileticById(1);
      await h.delete();
      expect((await getAllHomiletics()).map((h) => h.id), [2, 5]);
      expect(await getSummariesByHomileticId(1), isEmpty);
      expect(await getDivisionsByHomileticId(1), isEmpty);
      expect((await getDivisionsByHomileticId(5)), hasLength(1));
      expect((await getSummariesByHomileticId(2)), hasLength(1));
      // No resurrection after delete.
      await h.updateAim('changed');
      expect((await getAllHomiletics()).map((h) => h.id), [2, 5]);
    });

    test('a child of a deleted homiletic cannot be saved', () async {
      await openStorage();
      final Homiletic h = Homiletic(passage: 'Ruth 1');
      await h.update();
      final Division d = Division.blank(h.id);
      await h.delete();
      await expectLater(d.updateText('late'), throwsException);
      expect(await getDivisionByText('late'), isEmpty);
    });

    test('Homiletic.delete on legacy storage still removes everything',
        () async {
      await createAllLegacyFiles(dir);
      await openStorage(onProgress: (_, __) => throw StateError('fail'));
      expect(storage!.isUnified, isFalse);
      await (await getHomileticById(1)).delete();
      expect(await getSummariesByHomileticId(1), isEmpty);
      expect(await getDivisionsByHomileticId(1), isEmpty);
      expect((await getAllHomiletics()).map((h) => h.id), [2, 5]);
    });
  });

  test('word studies and lecture notes round-trip through the models',
      () async {
    await openStorage();
    final WordStudy s = WordStudy(word: 'grace', passage: 'Eph 2:8');
    await s.update();
    final LectureNote n = LectureNote(note: 'n', passage: 'Eph 2');
    await n.update();
    await n.updateTranscript('t');
    expect((await getWordStudiesByText('grace')).single.id, s.id);
    expect((await getLectureNotesByText('t')).single.transcript, 't');
    await s.delete();
    expect(await getAllWordStudies(), isEmpty);
  });
}
