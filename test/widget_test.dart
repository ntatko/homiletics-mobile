import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';

void main() {
  group('Homiletic', () {
    test('creates with default values', () {
      final homiletic = Homiletic();

      expect(homiletic.passage, '');
      expect(homiletic.subjectSentence, '');
      expect(homiletic.aim, '');
      expect(homiletic.fcf, '');
      expect(homiletic.id, -1);
      expect(homiletic.updatedAt, isNull);
    });

    test('creates with custom values', () {
      final now = DateTime.now();
      final homiletic = Homiletic(
        passage: 'John 3:16',
        subjectSentence: 'God loves the world',
        aim: 'To understand God\'s love',
        fcf: 'We often forget God\'s love',
        id: 42,
        updatedAt: now,
      );

      expect(homiletic.passage, 'John 3:16');
      expect(homiletic.subjectSentence, 'God loves the world');
      expect(homiletic.aim, 'To understand God\'s love');
      expect(homiletic.fcf, 'We often forget God\'s love');
      expect(homiletic.id, 42);
      expect(homiletic.updatedAt, now);
    });

    test('serializes to JSON correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final homiletic = Homiletic(
        passage: 'Romans 8:28',
        subjectSentence: 'All things work together',
        aim: 'Trust in God\'s plan',
        fcf: 'We worry about circumstances',
        id: 7,
        updatedAt: now,
      );

      final json = homiletic.toJson();

      expect(json['passage'], 'Romans 8:28');
      expect(json['subject_sentence'], 'All things work together');
      expect(json['aim'], 'Trust in God\'s plan');
      expect(json['fcf'], 'We worry about circumstances');
      expect(json['id'], 7);
      expect(json['updated_at'], now.toIso8601String());
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'passage': 'Psalm 23:1',
        'subject_sentence': 'The Lord is my shepherd',
        'aim': 'Rest in God\'s provision',
        'fcf': 'We strive for self-sufficiency',
        'id': '15',
        'updated_at': '2024-03-20T14:00:00.000',
      };

      final homiletic = Homiletic.fromJson(json);

      expect(homiletic.passage, 'Psalm 23:1');
      expect(homiletic.subjectSentence, 'The Lord is my shepherd');
      expect(homiletic.aim, 'Rest in God\'s provision');
      expect(homiletic.fcf, 'We strive for self-sufficiency');
      expect(homiletic.id, 15);
      expect(homiletic.updatedAt, DateTime(2024, 3, 20, 14, 0));
    });

    test('round-trips through JSON correctly', () {
      final now = DateTime(2024, 6, 1, 12, 0);
      final original = Homiletic(
        passage: 'Matthew 5:1-12',
        subjectSentence: 'Blessed are the meek',
        aim: 'Live with humility',
        fcf: 'Pride blinds us',
        id: 100,
        updatedAt: now,
      );

      final json = original.toJson();
      final restored = Homiletic.fromJson(json);

      expect(restored.passage, original.passage);
      expect(restored.subjectSentence, original.subjectSentence);
      expect(restored.aim, original.aim);
      expect(restored.fcf, original.fcf);
      expect(restored.id, original.id);
    });
  });

  group('ContentSummary', () {
    test('creates with required homileticId', () {
      final summary = ContentSummary(homileticId: 5);

      expect(summary.homileticId, 5);
      expect(summary.summary, '');
      expect(summary.passage, '');
      expect(summary.id, isNull);
    });

    test('creates with all values', () {
      final summary = ContentSummary(
        homileticId: 10,
        summary: 'Jesus teaches about love',
        passage: 'John 13:34-35',
        id: 42,
      );

      expect(summary.homileticId, 10);
      expect(summary.summary, 'Jesus teaches about love');
      expect(summary.passage, 'John 13:34-35');
      expect(summary.id, 42);
    });

    test('creates blank with homileticId', () {
      final summary = ContentSummary.blank(25);

      expect(summary.homileticId, 25);
      expect(summary.summary, '');
      expect(summary.passage, '');
      expect(summary.id, isNull);
    });

    test('serializes to JSON correctly', () {
      final summary = ContentSummary(
        homileticId: 3,
        summary: 'Paul explains grace',
        passage: 'Ephesians 2:8-9',
        id: 99,
      );

      final json = summary.toJson();

      expect(json['homiletic_id'], 3);
      expect(json['summary'], 'Paul explains grace');
      expect(json['passage'], 'Ephesians 2:8-9');
      expect(json['id'], 99);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'homiletic_id': 7,
        'summary': 'Faith without works is dead',
        'passage': 'James 2:17',
        'id': 55,
      };

      final summary = ContentSummary.fromJson(json);

      expect(summary.homileticId, 7);
      expect(summary.summary, 'Faith without works is dead');
      expect(summary.passage, 'James 2:17');
      expect(summary.id, 55);
    });

    test('round-trips through JSON correctly', () {
      final original = ContentSummary(
        homileticId: 12,
        summary: 'Original summary text',
        passage: 'Genesis 1:1',
        id: 88,
      );

      final json = original.toJson();
      final restored = ContentSummary.fromJson(json);

      expect(restored.homileticId, original.homileticId);
      expect(restored.summary, original.summary);
      expect(restored.passage, original.passage);
      expect(restored.id, original.id);
    });
  });

  group('Division', () {
    test('creates with required homileticId', () {
      final division = Division(8);

      expect(division.homileticId, 8);
      expect(division.title, '');
      expect(division.passage, '');
      expect(division.id, isNull);
    });

    test('creates with all values', () {
      final division = Division(
        15,
        title: 'The Call to Follow',
        passage: 'Mark 1:16-20',
        id: 33,
      );

      expect(division.homileticId, 15);
      expect(division.title, 'The Call to Follow');
      expect(division.passage, 'Mark 1:16-20');
      expect(division.id, 33);
    });

    test('creates blank with homileticId', () {
      final division = Division.blank(50);

      expect(division.homileticId, 50);
      expect(division.title, '');
      expect(division.passage, '');
      expect(division.id, isNull);
    });

    test('serializes to JSON correctly', () {
      final division = Division(
        20,
        title: 'The Sermon on the Mount',
        passage: 'Matthew 5-7',
        id: 77,
      );

      final json = division.toJson();

      expect(json['homiletic_id'], 20);
      expect(json['title'], 'The Sermon on the Mount');
      expect(json['passage'], 'Matthew 5-7');
      expect(json['id'], 77);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'homiletic_id': 30,
        'title': 'The Prodigal Son',
        'passage': 'Luke 15:11-32',
        'id': 44,
      };

      final division = Division.fromJson(json);

      expect(division.homileticId, 30);
      expect(division.title, 'The Prodigal Son');
      expect(division.passage, 'Luke 15:11-32');
      expect(division.id, 44);
    });

    test('round-trips through JSON correctly', () {
      final original = Division(
        25,
        title: 'Original division title',
        passage: 'Acts 2:1-13',
        id: 66,
      );

      final json = original.toJson();
      final restored = Division.fromJson(json);

      expect(restored.homileticId, original.homileticId);
      expect(restored.title, original.title);
      expect(restored.passage, original.passage);
      expect(restored.id, original.id);
    });
  });

  group('Application', () {
    test('creates with required homileticsId', () {
      final app = Application(homileticsId: 5);

      expect(app.homileticsId, 5);
      expect(app.text, '');
      expect(app.id, isNull);
    });

    test('creates with all values', () {
      final app = Application(
        homileticsId: 10,
        text: 'Pray daily for wisdom',
        id: 42,
      );

      expect(app.homileticsId, 10);
      expect(app.text, 'Pray daily for wisdom');
      expect(app.id, 42);
    });

    test('creates blank with homileticsId', () {
      final app = Application.blank(25);

      expect(app.homileticsId, 25);
      expect(app.text, '');
      expect(app.id, isNull);
    });

    test('serializes to JSON correctly', () {
      final app = Application(
        homileticsId: 3,
        text: 'Share the gospel with a friend',
        id: 99,
      );

      final json = app.toJson();

      expect(json['homiletic_id'], 3);
      expect(json['text'], 'Share the gospel with a friend');
      expect(json['id'], 99);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'homiletic_id': 7,
        'text': 'Memorize a verse this week',
        'id': 55,
      };

      final app = Application.fromJson(json);

      expect(app.homileticsId, 7);
      expect(app.text, 'Memorize a verse this week');
      expect(app.id, 55);
    });

    test('round-trips through JSON correctly', () {
      final original = Application(
        homileticsId: 12,
        text: 'Original application text',
        id: 88,
      );

      final json = original.toJson();
      final restored = Application.fromJson(json);

      expect(restored.homileticsId, original.homileticsId);
      expect(restored.text, original.text);
      expect(restored.id, original.id);
    });
  });
}
