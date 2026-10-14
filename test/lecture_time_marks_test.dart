import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/components/lecture/time_marks.dart';
import 'package:homiletics/theme/lecture_widgets.dart';

void main() {
  group('parseTimeMark', () {
    test('m:ss, mm:ss and minutes past an hour', () {
      expect(parseTimeMark('[0:05]'), const Duration(seconds: 5));
      expect(parseTimeMark('[14:02]'), const Duration(minutes: 14, seconds: 2));
      expect(
          parseTimeMark('[74:30]'), const Duration(minutes: 74, seconds: 30));
      expect(parseTimeMark('[120:00]'), const Duration(minutes: 120));
    });

    test('h:mm:ss', () {
      expect(parseTimeMark('[1:02:03]'),
          const Duration(hours: 1, minutes: 2, seconds: 3));
      expect(
          parseTimeMark('[00:14:02]'), const Duration(minutes: 14, seconds: 2));
    });

    test('rejects things that are not a single time mark', () {
      for (final String text in [
        '',
        '14:02',
        '[14:2]',
        '[14:60]',
        '[1:60:00]',
        '[1234:00]',
        '[:30]',
        '[14:02] ',
        '[ 14:02]',
        '[14.02]',
        '[1:02:03:04]',
        '[Genesis 1:1]',
        '[14:02][15:00]',
      ]) {
        expect(parseTimeMark(text), isNull, reason: text);
      }
    });

    test('round-trips the recording clock', () {
      for (final Duration d in const [
        Duration.zero,
        Duration(seconds: 59),
        Duration(minutes: 14, seconds: 2),
        Duration(hours: 1, minutes: 4, seconds: 9),
        Duration(hours: 2, minutes: 5),
      ]) {
        expect(parseTimeMark('[${formatClock(d)}]'), d, reason: '$d');
      }
    });
  });

  group('findTimeMarks', () {
    test('finds every mark with its range', () {
      const String text = '[0:10] Intro, then [14:02] the point (Rom 8:28).';
      expect(findTimeMarks(text), const [
        TimeMark(0, 6, Duration(seconds: 10)),
        TimeMark(19, 26, Duration(minutes: 14, seconds: 2)),
      ]);
    });

    test('ignores bible references and other brackets', () {
      expect(findTimeMarks('John 3:16 [note] [3:16 KJV] (12:30)'), isEmpty);
    });
  });

  group('timeMarkAt', () {
    const String text = 'Say [14:02] here';
    // "[" is at 4, "]" at 10, so the mark covers 4..11.

    test('inside the mark', () {
      for (int offset = 5; offset <= 10; offset++) {
        expect(timeMarkAt(text, offset)?.position,
            const Duration(minutes: 14, seconds: 2),
            reason: '$offset');
      }
    });

    test('not at the outer edges or elsewhere', () {
      for (final int offset in [0, 3, 4, 11, 12, text.length]) {
        expect(timeMarkAt(text, offset), isNull, reason: '$offset');
      }
    });

    test('picks the right one of several', () {
      const String two = '[0:30] a [1:00:00] b';
      expect(timeMarkAt(two, 2)?.position, const Duration(seconds: 30));
      expect(timeMarkAt(two, 12)?.position, const Duration(hours: 1));
      expect(timeMarkAt(two, 7), isNull);
    });
  });

  group('timeMarkInDocumentAt', () {
    test('plain-text marks in an existing Delta note', () {
      // Stored the way older notes (and the "+ Time mark" button) store
      // them: plain text, possibly next to other formatting and lists.
      final Document doc = Document.fromJson(jsonDecode('''[
        {"insert": "Title", "attributes": {"bold": true}},
        {"insert": "\\n"},
        {"insert": "[14:02] "},
        {"insert": "grace", "attributes": {"italic": true}},
        {"insert": "\\n"},
        {"insert": "point [1:05:00]"},
        {"insert": "\\n", "attributes": {"list": "bullet"}}
      ]''') as List);
      final String plain = doc.toPlainText();
      final int first = plain.indexOf('[14:02]');
      final int second = plain.indexOf('[1:05:00]');

      expect(timeMarkInDocumentAt(doc, first + 1)?.position,
          const Duration(minutes: 14, seconds: 2));
      expect(timeMarkInDocumentAt(doc, second + 3)?.position,
          const Duration(hours: 1, minutes: 5));
      expect(timeMarkInDocumentAt(doc, first), isNull);
      expect(timeMarkInDocumentAt(doc, 2), isNull);
      expect(timeMarkInDocumentAt(doc, -1), isNull);
      expect(timeMarkInDocumentAt(doc, doc.length), isNull);
    });

    test('a mark split across formatting runs is still found', () {
      final Document doc = Document()..insert(0, '[14:02] note');
      doc.format(1, 2, Attribute.bold);
      expect(timeMarkInDocumentAt(doc, 4)?.position,
          const Duration(minutes: 14, seconds: 2));
    });
  });

  group('timeMarkSpanBuilder', () {
    testWidgets('styles marks without changing the text', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(Builder(builder: (c) {
        context = c;
        return const SizedBox();
      }));
      const TextStyle base = TextStyle(fontSize: 16);
      const TextStyle mark = TextStyle(color: Color(0xFF0E5C61));
      final TextSpanBuilder builder = timeMarkSpanBuilder(mark);
      const String text = 'a [0:30] b [14:02]';
      final InlineSpan span =
          builder(context, Document().root, 0, text, base, null);

      expect(span.toPlainText(), text);
      final List<TextSpan> children =
          (span as TextSpan).children!.cast<TextSpan>();
      expect(children.map((s) => s.text), ['a ', '[0:30]', ' b ', '[14:02]']);
      expect(children[1].style?.color, mark.color);
      expect(children[1].style?.fontSize, 16);
      expect(children[0].style, isNull);

      final InlineSpan plain =
          builder(context, Document().root, 0, 'no marks', base, null);
      expect((plain as TextSpan).text, 'no marks');
      expect(plain.style, base);
    });
  });

  testWidgets('tapping a mark in a QuillEditor finds it, elsewhere does not',
      (tester) async {
    final QuillController controller = QuillController(
      document: Document()..insert(0, '[14:02] grace abounds'),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);
    final List<Duration> played = [];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      home: Scaffold(
        body: QuillEditor.basic(
          controller: controller,
          config: QuillEditorConfig(
            padding: EdgeInsets.zero,
            textSpanBuilder:
                timeMarkSpanBuilder(const TextStyle(color: Color(0xFF0E5C61))),
            onTapUp: (details, positionAt) {
              final TimeMark? mark = timeMarkInDocumentAt(controller.document,
                  positionAt(details.globalPosition).offset);
              if (mark == null) return false;
              played.add(mark.position);
              return true;
            },
          ),
        ),
      ),
    ));
    final Offset topLeft = tester.getTopLeft(find.byType(QuillEditor));
    // Ahem-style test font: every glyph is one em (14px) wide.
    await tester.tapAt(topLeft + const Offset(14 * 3.5, 7));
    await tester.pump(const Duration(milliseconds: 500));
    expect(played, [const Duration(minutes: 14, seconds: 2)]);

    await tester.tapAt(topLeft + const Offset(14 * 15.5, 7));
    await tester.pump(const Duration(milliseconds: 500));
    expect(played, hasLength(1));
  });
}
