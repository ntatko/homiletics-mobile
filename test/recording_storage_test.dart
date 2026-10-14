import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/components/recording_section.dart';
import 'package:homiletics/l10n/generated/app_localizations.dart';
import 'package:homiletics/services/recording_storage_service.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Points the app documents directory at a temp folder.
class _FakePaths extends PathProviderPlatform {
  String documents;
  _FakePaths(this.documents);

  @override
  Future<String?> getApplicationDocumentsPath() async => documents;
  @override
  Future<String?> getTemporaryPath() async => documents;
  @override
  Future<String?> getApplicationSupportPath() async => documents;
}

final DateTime _now = DateTime(2026, 10, 14, 12);

String _fileName(int id, DateTime recordedAt, {String ext = 'm4a'}) =>
    'lecture_${id}_${recordedAt.millisecondsSinceEpoch}.$ext';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documents;
  AppStorage? storage;

  setUpAll(() async {
    final Directory hive =
        await Directory.systemTemp.createTemp('homiletics_storage_hive');
    Hive.init(hive.path);
    await Preferences.init();
  });

  setUp(() async {
    sqfliteFfiInit();
    documents = Directory.systemTemp.createTempSync('recording_storage_');
    PathProviderPlatform.instance = _FakePaths(documents.path);
    storage = await AppStorage.open(
        factory: databaseFactoryFfiNoIsolate,
        directory: p.join(documents.path, 'db'));
    AppStorage.debugInstance = Future.value(storage);
    // Each test's database restarts note ids at 1.
    await Hive.box('user').clear();
  });

  tearDown(() async {
    await storage?.close();
    AppStorage.debugInstance = null;
    documents.deleteSync(recursive: true);
  });

  /// A saved note with a recording of [bytes] made at [recordedAt].
  Future<LectureNote> noteWithRecording(DateTime recordedAt,
      {int bytes = 1000, String? transcript, String ext = 'm4a'}) async {
    final LectureNote note = LectureNote(
      passage: 'Romans 3',
      note: '[04:12] Paul lets the reader ask first',
      transcript: transcript,
      formattedTranscript: transcript == null ? null : 'Formatted: $transcript',
    );
    await note.update();
    final String name = _fileName(note.id, recordedAt, ext: ext);
    File(p.join(documents.path, name)).writeAsBytesSync(List.filled(bytes, 1));
    note.recordingPath = name;
    await note.update();
    return note;
  }

  group('helpers', () {
    test('recording time comes from the file name', () {
      final DateTime at = DateTime(2025, 3, 1, 9, 30);
      expect(
          RecordingStorageService.recordedAtFromFileName(_fileName(4, at)), at);
      expect(
          RecordingStorageService.recordedAtFromFileName(
              _fileName(4, at, ext: 'wav')),
          at);
      expect(
          RecordingStorageService.recordedAtFromFileName('notes.m4a'), isNull);
      expect(
          RecordingStorageService.recordedAtFromFileName(
              '${_fileName(4, at)}.wav'),
          isNull);
    });

    test('ages round-trip through their stored days', () {
      for (final RecordingAge age in RecordingAge.values) {
        expect(RecordingAge.fromDays(age.days), age);
      }
      expect(RecordingAge.fromDays(12), RecordingAge.threeMonths);
    });

    test('sizes', () {
      expect(formatStorageSize(0), '0.0 MB');
      expect(formatStorageSize(2000), '0.1 MB');
      expect(formatStorageSize(3 * 1024 * 1024 + 300000), '3.3 MB');
      expect(formatStorageSize(480 * 1024 * 1024), '480 MB');
      expect(formatStorageSize((1.25 * 1024 * 1024 * 1024).round()), '1.3 GB');
    });
  });

  group('scan', () {
    test('adds up recordings and picks the ones older than the age', () async {
      final LectureNote old = await noteWithRecording(
          _now.subtract(const Duration(days: 200)),
          bytes: 3000);
      final LectureNote recent = await noteWithRecording(
          _now.subtract(const Duration(days: 10)),
          bytes: 500);
      await LectureNote(passage: 'No audio').update();
      // A note pointing at a file that's gone isn't counted.
      final LectureNote missing =
          LectureNote(passage: 'Gone', recordingPath: _fileName(99, _now));
      await missing.update();

      final RecordingUsage usage =
          await RecordingStorageService.scan(now: _now);
      expect(usage.recordings.map((r) => r.note.id),
          unorderedEquals([old.id, recent.id]));
      expect(usage.recordingBytes, 3500);
      expect(
          usage.olderThan(RecordingAge.sixMonths, _now).single.note.id, old.id);
      expect(usage.olderThan(RecordingAge.oneYear, _now), isEmpty);
      expect(usage.olderThan(RecordingAge.oneMonth, _now), hasLength(1));
    });

    test('counts day-old unreferenced recording files as orphans', () async {
      await noteWithRecording(_now.subtract(const Duration(days: 5)));
      final File orphan = File(p.join(documents.path, _fileName(7, _now)))
        ..writeAsBytesSync(List.filled(800, 1))
        ..setLastModifiedSync(_now.subtract(const Duration(days: 2)));
      // Fresh: maybe a recording that's being saved right now.
      File(p.join(documents.path, _fileName(8, _now)))
        ..writeAsBytesSync(List.filled(800, 1))
        ..setLastModifiedSync(_now.subtract(const Duration(hours: 1)));
      // Not a recording.
      File(p.join(documents.path, 'notes.m4a'))
        ..writeAsBytesSync(List.filled(800, 1))
        ..setLastModifiedSync(_now.subtract(const Duration(days: 30)));

      final RecordingUsage usage =
          await RecordingStorageService.scan(now: _now);
      expect(usage.orphans.map((f) => f.path), [orphan.path]);
      expect(usage.orphanBytes, 800);
      expect(usage.totalBytes, 1800);
    });
  });

  group('remove', () {
    test('deletes only the audio; notes, transcripts and time are kept',
        () async {
      final LectureNote note = await noteWithRecording(
          _now.subtract(const Duration(days: 200)),
          bytes: 2048,
          transcript: 'What advantage has the Jew?');
      final DateTime? savedTime = (await getLectureNotes()).single.time;
      final String audio = (await note.recordingFilePath())!;
      final File conversion = File('$audio.wav')..writeAsStringSync('x');
      final File orphan = File(p.join(documents.path, _fileName(42, _now)))
        ..writeAsBytesSync(List.filled(100, 1))
        ..setLastModifiedSync(_now.subtract(const Duration(days: 3)));

      final RecordingUsage usage =
          await RecordingStorageService.scan(now: _now);
      final RecordingRemoval result = await RecordingStorageService.remove(
          usage.olderThan(RecordingAge.threeMonths, _now),
          orphans: usage.orphans,
          now: _now);

      expect(result.removed, 1);
      expect(result.bytes, 2148);
      expect(File(audio).existsSync(), isFalse);
      expect(conversion.existsSync(), isFalse);
      expect(orphan.existsSync(), isFalse);

      final LectureNote stored = (await getLectureNotes()).single;
      expect(stored.recordingPath, isNull);
      expect(stored.note, '[04:12] Paul lets the reader ask first');
      expect(stored.transcript, 'What advantage has the Jew?');
      expect(
          stored.formattedTranscript, 'Formatted: What advantage has the Jew?');
      expect(stored.time, savedTime);
      expect(Preferences.recordingRemovedAt(stored.id), _now);
      expect(RecordingStorageService.wasRemoved(stored), isTrue);

      // The removed note's own later saves don't bring the file name back.
      await stored.updateNote('[04:12] edited', null);
      expect((await getLectureNotes()).single.recordingPath, isNull);
    });

    test('removeRecordingFile on an open note keeps it removed', () async {
      final LectureNote note =
          await noteWithRecording(_now.subtract(const Duration(days: 60)));
      final String audio = (await note.recordingFilePath())!;
      await note.removeRecordingFile();
      expect(note.recordingPath, isNull);
      expect(File(audio).existsSync(), isFalse);
      await note.updateNote('changed', null);
      expect((await getLectureNotes()).single.recordingPath, isNull);
    });

    test('skips a note that is open in an editor', () async {
      final LectureNote note =
          await noteWithRecording(_now.subtract(const Duration(days: 400)));
      RecordingStorageService.openNoteIds.add(note.id);
      addTearDown(() => RecordingStorageService.openNoteIds.remove(note.id));
      final RecordingUsage usage =
          await RecordingStorageService.scan(now: _now);
      final RecordingRemoval result =
          await RecordingStorageService.remove(usage.recordings, now: _now);
      expect(result.removed, 0);
      expect(File((await note.recordingFilePath())!).existsSync(), isTrue);
      expect((await getLectureNotes()).single.recordingPath, isNotNull);
    });

    test('a note that never had a recording is not "removed"', () async {
      final LectureNote note = LectureNote(passage: 'Romans 4');
      await note.update();
      expect(RecordingStorageService.wasRemoved(note), isFalse);
    });

    test('recording again clears the removed state', () async {
      await noteWithRecording(_now.subtract(const Duration(days: 400)));
      final RecordingUsage usage =
          await RecordingStorageService.scan(now: _now);
      await RecordingStorageService.remove(usage.recordings, now: _now);
      final LectureNote note = (await getLectureNotes()).single;
      expect(RecordingStorageService.wasRemoved(note), isTrue);

      await note.updateRecordingPath(_fileName(note.id, _now));
      await Preferences.clearRecordingRemoved(note.id);
      expect(RecordingStorageService.wasRemoved(note), isFalse);
      expect(Preferences.recordingRemovedAt(note.id), isNull);
    });
  });

  group('automatic removal', () {
    test('off by default', () async {
      await noteWithRecording(_now.subtract(const Duration(days: 400)),
          transcript: 'text');
      expect(await RecordingStorageService.runAutomaticCleanupIfDue(now: _now),
          isNull);
      expect((await RecordingStorageService.scan(now: _now)).recordings,
          hasLength(1));
    });

    test('removes old transcribed recordings, once a day', () async {
      Preferences.autoRemoveRecordings = true;
      Preferences.recordingRemovalAgeDays = RecordingAge.sixMonths.days;
      final LectureNote transcribed = await noteWithRecording(
          _now.subtract(const Duration(days: 300)),
          transcript: 'text');
      final LectureNote untranscribed =
          await noteWithRecording(_now.subtract(const Duration(days: 300)));
      final LectureNote recent = await noteWithRecording(
          _now.subtract(const Duration(days: 20)),
          transcript: 'text');

      final RecordingRemoval? result =
          await RecordingStorageService.runAutomaticCleanupIfDue(now: _now);
      expect(result?.removed, 1);
      final Map<int, String?> paths = {
        for (final LectureNote n in await getLectureNotes())
          n.id: n.recordingPath
      };
      expect(paths[transcribed.id], isNull);
      expect(paths[untranscribed.id], isNotNull);
      expect(paths[recent.id], isNotNull);

      // Not again the same day.
      expect(
          await RecordingStorageService.runAutomaticCleanupIfDue(
              now: _now.add(const Duration(hours: 5))),
          isNull);
      expect(
          await RecordingStorageService.runAutomaticCleanupIfDue(
              now: _now.add(const Duration(days: 1, hours: 1))),
          isNotNull);
    });
  });

  group('editor', () {
    final List<String> channels = [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'com.llfbandit.record/messages',
    ];

    setUp(() {
      for (final String name in channels) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                MethodChannel(name), (MethodCall call) async => null);
      }
    });

    tearDown(() {
      for (final String name in channels) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannel(name), null);
      }
    });

    Widget app(LectureNote note) => MaterialApp(
          supportedLocales: [for (final l in Language.all) l.locale],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: buildAppTheme(Brightness.light),
          home: Scaffold(
            body: RecordingSection(
              note: note,
              notesToolbar: const SizedBox.shrink(),
              notesEditor: const SizedBox.shrink(),
            ),
          ),
        );

    testWidgets('a removed recording shows a calm note, not a player',
        (tester) async {
      final LectureNote note = await tester.runAsync(() async {
        await noteWithRecording(_now.subtract(const Duration(days: 400)));
        final RecordingUsage usage =
            await RecordingStorageService.scan(now: _now);
        await RecordingStorageService.remove(usage.recordings, now: _now);
        // What the editor gets when the note is opened afterwards.
        return (await getLectureNotes()).single;
      }) as LectureNote;

      await tester.pumpWidget(app(note));
      await tester.pump();

      expect(find.text('Recording removed to save space'), findsOneWidget);
      expect(find.text('Your notes and transcript are kept'), findsOneWidget);
      expect(find.byTooltip('Play recording'), findsNothing);
      expect(find.byTooltip('Record again'), findsOneWidget);

      await tester.tap(find.text('Transcript'));
      await tester.pump();
      expect(
          find.text(
              'The recording was removed to save space before it was transcribed.'),
          findsOneWidget);
    });

    testWidgets('a note that never had a recording still offers to record',
        (tester) async {
      final LectureNote note = await tester.runAsync(() async {
        final LectureNote note = LectureNote(passage: 'Romans 5');
        await note.update();
        return note;
      }) as LectureNote;

      await tester.pumpWidget(app(note));
      await tester.pump();

      expect(find.text('Recording removed to save space'), findsNothing);
      expect(find.byTooltip('Record lecture'), findsOneWidget);
    });
  });
}
