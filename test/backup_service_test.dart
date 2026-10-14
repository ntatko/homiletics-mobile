import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/services/backup_service.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A library on disk: a database plus the folder recordings live in.
class _Library {
  final Directory root;
  final AppStorage storage;

  _Library(this.root, this.storage);

  String get recordings => p.join(root.path, 'documents');

  static Future<_Library> open(String name) async {
    final Directory root = Directory.systemTemp.createTempSync('backup_$name');
    Directory(p.join(root.path, 'documents')).createSync();
    return _Library(
        root,
        await AppStorage.open(
            factory: databaseFactoryFfiNoIsolate, directory: root.path));
  }

  void use() {
    AppStorage.debugInstance = Future.value(storage);
    BackupService.recordingsDirectory = () async => recordings;
  }

  Future<void> dispose() async {
    await storage.close();
    root.deleteSync(recursive: true);
  }
}

Future<void> _seed(_Library library) async {
  library.use();
  final Homiletic h = Homiletic(
      passage: 'Romans 3:1-20',
      subjectSentence: 'God is faithful; all are guilty.',
      aim: 'the whole world is accountable to God.',
      fcf: 'We excuse our own sin.');
  await h.update();
  for (final (String v, String text) in [
    ('1-2', 'God entrusted the Jews with His words.'),
    ('3-4', 'Unfaithfulness can’t cancel His faithfulness.'),
  ]) {
    await (ContentSummary.blank(h.id)
          ..passage = v
          ..summary = text)
        .update();
  }
  await Division(h.id, passage: '1-8', title: 'God stays faithful').update();
  await Application(homileticsId: h.id, text: 'Where do I compare myself?')
      .update();
  await Homiletic(passage: 'Romans 4').update();

  File(p.join(library.recordings, 'lecture-1.m4a'))
      .writeAsBytesSync(List<int>.generate(4096, (i) => i % 251));
  await LectureNote(
          passage: 'Romans 3',
          note: '[{"insert":"[04:12] No one is righteous\\n"}]',
          recordingPath: 'lecture-1.m4a',
          transcript: 'Paul anticipates the objection.',
          formattedTranscript: 'Paul anticipates the objection.')
      .update();
  await LectureNote(passage: 'Romans 2', note: 'Plain note').update();

  await WordStudy(
          passage: 'Romans 3:10',
          word: 'Righteous',
          definition: 'Right with God',
          application: 'Rest in Christ')
      .update();
}

/// Everything the user wrote, in a form two libraries can be compared by.
Future<Map<String, dynamic>> _snapshot(_Library library) async {
  library.use();
  final List<Map<String, dynamic>> homiletics = [];
  for (final Homiletic h in await getAllHomiletics()) {
    homiletics.add({
      ...h.toJson()..remove('id'),
      'summaries': [
        for (final ContentSummary s in await getSummariesByHomileticId(h.id))
          [s.passage, s.summary]
      ],
      'divisions': [
        for (final Division d in await getDivisionsByHomileticId(h.id))
          [d.passage, d.title]
      ],
      'applications': [
        for (final Application a in await getApplicationsByHomileticId(h.id))
          a.text
      ],
    });
  }
  final List<Map<String, dynamic>> notes = [];
  for (final LectureNote n in await getLectureNotes()) {
    final Map<String, dynamic> json = n.toJson()..remove('id');
    final String? name = json.remove('recording_path') as String?;
    json['audio'] = name == null
        ? null
        : base64Encode(
            File(p.join(library.recordings, name)).readAsBytesSync());
    notes.add(json);
  }
  return {
    'homiletics': homiletics,
    'notes': notes,
    'word_studies': [
      for (final WordStudy w in await getAllWordStudies())
        w.toJson()..remove('id')
    ],
  };
}

void main() {
  sqfliteFfiInit();

  late _Library source;
  late _Library target;
  late Directory out;

  setUp(() async {
    source = await _Library.open('source');
    target = await _Library.open('target');
    out = Directory.systemTemp.createTempSync('backup_out');
    await _seed(source);
  });

  tearDown(() async {
    AppStorage.debugInstance = null;
    await source.dispose();
    await target.dispose();
    out.deleteSync(recursive: true);
  });

  Future<File> backUp({bool recordings = true}) async {
    source.use();
    return BackupService.create(
        includeRecordings: recordings,
        appVersion: '3.0.0',
        directory: out,
        now: DateTime(2026, 10, 14, 9));
  }

  test('names the file by date and writes a manifest', () async {
    final File file = await backUp();
    expect(p.basename(file.path), 'Homiletics backup 2026-10-14.zip');
    final Archive zip = ZipDecoder().decodeBytes(file.readAsBytesSync());
    final Map<String, dynamic> manifest =
        jsonDecode(utf8.decode(zip.findFile('manifest.json')!.readBytes()!));
    expect(manifest['format'], 'homiletics-backup');
    expect(manifest['v'], 1);
    expect(manifest['app_version'], '3.0.0');
    expect(manifest['counts'], {
      'homiletics': 2,
      'lecture_notes': 2,
      'word_studies': 1,
      'recordings': 1,
    });
    expect(zip.findFile('recordings/lecture-1.m4a'), isNotNull);
  });

  test('round trip: a fresh library ends up identical, audio included',
      () async {
    final File file = await backUp();
    target.use();
    final BackupContents backup = await BackupService.read(file.path);
    expect(backup.homiletics, hasLength(2));
    expect(backup.lectureNotes, hasLength(2));
    expect(backup.wordStudies, hasLength(1));
    expect(backup.recordingCount, 1);

    final RestoreResult result = await BackupService.restore(backup);
    expect(result.added, 5);
    expect(result.skipped, 0);
    expect(await _snapshot(target), await _snapshot(source));
  });

  test('restoring twice adds nothing the second time', () async {
    final File file = await backUp();
    target.use();
    final BackupContents backup = await BackupService.read(file.path);
    await BackupService.restore(backup);
    final Map<String, dynamic> once = await _snapshot(target);

    target.use();
    final RestoreResult again = await BackupService.restore(backup);
    expect(again.added, 0);
    expect(again.skipped, 5);
    expect(await _snapshot(target), once);
    expect(Directory(target.recordings).listSync(), hasLength(1));
  });

  test('restoring onto the same library skips everything', () async {
    final File file = await backUp();
    source.use();
    final Map<String, dynamic> before = await _snapshot(source);
    source.use();
    final RestoreResult result =
        await BackupService.restore(await BackupService.read(file.path));
    expect(result.added, 0);
    expect(await _snapshot(source), before);
  });

  test('keeps existing studies and adds alongside them', () async {
    final File file = await backUp();
    target.use();
    await Homiletic(passage: 'John 1').update();
    final RestoreResult result =
        await BackupService.restore(await BackupService.read(file.path));
    expect(result.added, 5);
    target.use();
    expect((await getAllHomiletics()).map((h) => h.passage),
        containsAll(['John 1', 'Romans 3:1-20', 'Romans 4']));
  });

  test('a recording name already in use gets a new name', () async {
    final File file = await backUp();
    final File clash = File(p.join(target.recordings, 'lecture-1.m4a'))
      ..writeAsStringSync('someone else');
    target.use();
    await BackupService.restore(await BackupService.read(file.path));
    expect(clash.readAsStringSync(), 'someone else');
    target.use();
    final LectureNote restored = (await getLectureNotes())
        .firstWhere((n) => n.recordingPath != null);
    expect(restored.recordingPath, 'lecture-1-restored-1.m4a');
  });

  test('without recordings, notes come back without audio', () async {
    final File file = await backUp(recordings: false);
    target.use();
    final BackupContents backup = await BackupService.read(file.path);
    expect(backup.recordingCount, 0);
    await BackupService.restore(backup);
    target.use();
    final List<LectureNote> notes = await getLectureNotes();
    expect(notes.every((n) => n.recordingPath == null), isTrue);
    expect(notes.map((n) => n.transcript),
        contains('Paul anticipates the objection.'));
  });

  group('rejects', () {
    Future<BackupProblem?> problemWith(Archive archive) async {
      final File file = File(p.join(out.path, 'bad.zip'))
        ..writeAsBytesSync(ZipEncoder().encode(archive));
      try {
        await BackupService.read(file.path);
        return null;
      } on BackupException catch (e) {
        return e.problem;
      }
    }

    ArchiveFile manifest(Map<String, dynamic> json) =>
        ArchiveFile.string('manifest.json', jsonEncode(json));
    final ArchiveFile emptyData = ArchiveFile.string('data.json', '{}');

    test('a file that isn\'t a zip', () async {
      final File file = File(p.join(out.path, 'notes.zip'))
        ..writeAsStringSync('hello');
      expect(
          () => BackupService.read(file.path),
          throwsA(isA<BackupException>().having(
              (e) => e.problem, 'problem', BackupProblem.notABackup)));
    });

    test('a zip without a manifest', () async {
      expect(await problemWith(Archive()..add(emptyData)),
          BackupProblem.notABackup);
    });

    test('some other app\'s manifest', () async {
      expect(
          await problemWith(Archive()
            ..add(manifest({'format': 'other', 'v': 1}))
            ..add(emptyData)),
          BackupProblem.notABackup);
    });

    test('a newer format', () async {
      expect(
          await problemWith(Archive()
            ..add(manifest({'format': 'homiletics-backup', 'v': 2}))
            ..add(emptyData)),
          BackupProblem.newerVersion);
    });

    test('damaged data', () async {
      expect(
          await problemWith(Archive()
            ..add(manifest({'format': 'homiletics-backup', 'v': 1}))
            ..add(ArchiveFile.string('data.json', '{"homiletics": [1, 2'))),
          BackupProblem.damaged);
    });
  });
}
