import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/storage/study_text.dart';

void main() {
  final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

  test('homiletic text lists each filled section', () {
    final String text = homileticText(
      Homiletic(
          passage: 'Revelation 2:1–11',
          subjectSentence: 'Christ calls Ephesus back to first love.',
          aim: 'Christ sees our labor and our love.'),
      [
        ContentSummary(
            homileticId: 1, passage: '2:1', summary: 'Jesus walks among them.'),
        ContentSummary(homileticId: 1, passage: '', summary: ''),
      ],
      [Division(1, passage: '2:1–7', title: 'Ephesus is called to repent.')],
      [
        Application(homileticsId: 1, text: 'Where has my love cooled?'),
        Application(homileticsId: 1, text: '  '),
        Application(homileticsId: 1, text: 'What do I fear?'),
      ],
      en,
    );
    expect(
        text,
        'Homiletics · Revelation 2:1–11\n'
        '\n'
        'CONTENT\n'
        '2:1 — Jesus walks among them.\n'
        '\n'
        'DIVISIONS\n'
        '2:1–7 — Ephesus is called to repent.\n'
        '\n'
        'SUMMARY SENTENCE\n'
        'Christ calls Ephesus back to first love.\n'
        '\n'
        'AIM\n'
        'Cause the audience to learn that Christ sees our labor and our love.\n'
        '\n'
        'APPLICATION\n'
        '1. Where has my love cooled?\n'
        '2. What do I fear?');
  });

  test('an empty homiletic is just its title', () {
    expect(homileticText(Homiletic(), [], [], [], en),
        en.pdfHomileticLabel(en.pdfUntitledPassage));
  });

  test('word study text bullets other usage', () {
    final String text = wordStudyText(
        WordStudy(
            word: 'Lampstand',
            passage: 'Revelation 2:1–7',
            definition: 'A stand for a lamp.',
            otherUsage: 'Matthew 5:15\n\nHebrews 9:2'),
        en);
    expect(
        text,
        'Word study · Lampstand · Revelation 2:1–7\n'
        '\n'
        'DEFINITION\n'
        'A stand for a lamp.\n'
        '\n'
        'OTHER USAGE\n'
        '• Matthew 5:15\n'
        '• Hebrews 9:2');
  });
}
