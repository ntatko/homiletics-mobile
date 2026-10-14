import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/classes/word_study.dart';

class _Saver with SerializedSave {}

void main() {
  group('SerializedSave', () {
    test('runs saves one at a time in call order', () async {
      final _Saver saver = _Saver();
      final List<String> log = [];
      final Completer<void> gate = Completer<void>();

      final Future<void> first = saver.serializeSave(() async {
        log.add('first start');
        await gate.future;
        log.add('first end');
      });
      final Future<void> second = saver.serializeSave(() async {
        log.add('second');
      });

      await Future<void>.delayed(Duration.zero);
      expect(log, ['first start']);
      gate.complete();
      await Future.wait([first, second]);
      expect(log, ['first start', 'first end', 'second']);
    });

    test('a failed save does not block later ones', () async {
      final _Saver saver = _Saver();
      final Future<void> failing =
          saver.serializeSave(() async => throw StateError('boom'));
      bool ran = false;
      final Future<void> next = saver.serializeSave(() async => ran = true);
      await expectLater(failing, throwsStateError);
      await next;
      expect(ran, isTrue);
    });

    test('saves queued after markDeleted are skipped', () async {
      final _Saver saver = _Saver();
      saver.markDeleted();
      bool ran = false;
      await saver.serializeSave(() async => ran = true);
      expect(ran, isFalse);
      expect(saver.isDeleted, isTrue);
    });

    test('matchesSaved compares against the remembered state', () {
      final _Saver saver = _Saver();
      expect(saver.matchesSaved({'a': 1}), isFalse);
      saver.rememberSaved({'a': 1});
      expect(saver.matchesSaved({'a': 1}), isTrue);
      expect(saver.matchesSaved({'a': 2}), isFalse);
    });
  });

  group('fromJson tolerates NULL columns', () {
    test('Homiletic', () {
      final Homiletic h = Homiletic.fromJson({
        'id': 3,
        'passage': null,
        'subject_sentence': null,
        'aim': null,
        'updated_at': '',
        'fcf': null,
      });
      expect(h.id, 3);
      expect(h.passage, '');
      expect(h.subjectSentence, '');
      expect(h.aim, '');
      expect(h.fcf, '');
      expect(h.updatedAt, isNull);
    });

    test('LectureNote', () {
      final LectureNote n = LectureNote.fromJson({
        'id': 1,
        'note': null,
        'passage': null,
        'time': null,
        'recording_path': null,
        'transcript': null,
        'formatted_transcript': null,
      });
      expect(n.note, '');
      expect(n.passage, '');
      expect(n.time, isNull);
      expect(n.recordingPath, isNull);
      expect(n.isDeleted, isFalse);
    });

    test('WordStudy', () {
      final WordStudy s = WordStudy.fromJson({'id': 2, 'updated_at': 'junk'});
      expect(s.word, '');
      expect(s.otherUsage, '');
      expect(s.updatedAt, isNull);
    });

    test('Division, ContentSummary, Application', () {
      final Division d = Division.fromJson({'id': 1, 'homiletic_id': 4});
      expect(d.title, '');
      expect(d.passage, '');
      final ContentSummary c =
          ContentSummary.fromJson({'id': 1, 'homiletic_id': 4});
      expect(c.summary, '');
      expect(c.passage, '');
      final Application a = Application.fromJson({'id': 1, 'homiletic_id': 4});
      expect(a.text, '');
    });
  });

  test('LectureNote.fromJson reduces an old absolute recording path to its file name',
      () {
    final LectureNote n = LectureNote.fromJson({
      'id': 1,
      'note': '',
      'passage': '',
      'time': '2024-01-01T00:00:00.000',
      'recording_path':
          '/var/mobile/Containers/Data/Application/ABC/Documents/lecture_1_5.m4a',
    });
    expect(n.recordingPath, 'lecture_1_5.m4a');

    final LectureNote m = LectureNote.fromJson(
        {'id': 2, 'recording_path': 'lecture_2_9.m4a', 'time': ''});
    expect(m.recordingPath, 'lecture_2_9.m4a');
  });

  test('LectureNote.updateNote and updateTranscript allow clearing with empty string',
      () async {
    // A deleted note doesn't touch the database, so this exercises only the
    // field handling.
    final LectureNote n =
        LectureNote(note: 'a', passage: 'John 1', transcript: 't');
    n.markDeleted();
    await n.updateNote('', null);
    await n.updateTranscript('');
    expect(n.note, '');
    expect(n.passage, 'John 1');
    expect(n.transcript, '');
  });
}
