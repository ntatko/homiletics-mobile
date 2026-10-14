import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/passage_schedule.dart';

void main() {
  final Map<String, dynamic> feed =
      jsonDecode(File('data/suggested-passages.json').readAsStringSync());
  final Map<String, dynamic> studies =
      Map<String, dynamic>.from(feed['studies'] as Map);
  final List<PassageSchedule> weeks = [
    for (final Object? week in feed['data'] as List)
      PassageSchedule.fromJson(Map<String, dynamic>.from(week as Map),
          studies: studies),
  ];

  test('every week parses and keeps an English passage for lookups', () {
    expect(weeks, isNotEmpty);
    for (final PassageSchedule week in weeks) {
      expect(week.passage.trim(), isNotEmpty);
    }
  });

  test('every week is translated for every app language', () {
    // Run tool/localize_suggested_passages.py after adding weeks.
    for (final PassageSchedule week in weeks) {
      for (final Language language in Language.all) {
        if (language == Language.english) continue;
        expect(week.passageI18n[language.code], isNotNull,
            reason: '${week.passage} has no ${language.code} passage');
        expect(week.studyName(language), isNotNull,
            reason: '${week.study} has no name');
        if (week.lesson.contains('#')) {
          expect(week.lessonI18n[language.code], isNotNull,
              reason: '${week.lesson} has no ${language.code} title');
        }
      }
    }
  });

  test('display falls back to English fields', () {
    final PassageSchedule plain = PassageSchedule.fromJson({
      'passage': 'Romans 3:1-20',
      'rollout': '2026-10-12T12:00:00Z',
      'lesson': 'BSF Romans #4',
      'study': 'x',
    });
    expect(plain.displayPassage(Language.spanish), 'Romans 3:1-20');
    expect(plain.displayLesson(Language.chineseSimplified), 'BSF Romans #4');
    expect(plain.studyName(Language.french), isNull);
  });

  test('translated fields are used for the matching language', () {
    final PassageSchedule week =
        weeks.firstWhere((w) => w.passage == 'Romans 3:1-20');
    expect(week.displayPassage(Language.spanish), 'Romanos 3:1-20');
    expect(week.displayPassage(Language.chineseTraditional), '羅馬書 3:1-20');
    expect(week.displayPassage(Language.english), 'Romans 3:1-20');
    expect(week.studyName(Language.english), 'BSF Romans');
  });
}
