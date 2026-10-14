import 'package:flutter/painting.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Time marks are the "[14:02]" stamps the "+ Time mark" button types into
/// lecture notes. They stay plain text in the stored Delta: they're found
/// when the notes are drawn (to style them) and when they're tapped (to play
/// the recording from there), so notes written before marks were tappable,
/// and marks typed by hand, work the same way.

/// A time mark found in some text: [start]/[end] (exclusive) cover the
/// brackets too.
class TimeMark {
  final int start;
  final int end;
  final Duration position;

  const TimeMark(this.start, this.end, this.position);

  @override
  bool operator ==(Object other) =>
      other is TimeMark &&
      other.start == start &&
      other.end == end &&
      other.position == position;

  @override
  int get hashCode => Object.hash(start, end, position);

  @override
  String toString() => 'TimeMark($start, $end, $position)';
}

/// "[m:ss]", "[mm:ss]", "[mmm:ss]" (the recording clock keeps counting
/// minutes past an hour) and "[h:mm:ss]".
final RegExp _timeMarkPattern =
    RegExp(r'\[(?:(\d{1,2}):([0-5]\d):([0-5]\d)|(\d{1,3}):([0-5]\d))\]');

/// The position a single time mark like "[14:02]" stands for, or null if
/// [text] isn't exactly one time mark.
Duration? parseTimeMark(String text) {
  final List<TimeMark> marks = findTimeMarks(text);
  if (marks.length != 1 ||
      marks.single.start != 0 ||
      marks.single.end != text.length) {
    return null;
  }
  return marks.single.position;
}

/// Every time mark in [text], in order.
List<TimeMark> findTimeMarks(String text) {
  return [
    for (final RegExpMatch m in _timeMarkPattern.allMatches(text))
      TimeMark(
        m.start,
        m.end,
        m.group(1) != null
            ? Duration(
                hours: int.parse(m.group(1)!),
                minutes: int.parse(m.group(2)!),
                seconds: int.parse(m.group(3)!))
            : Duration(
                minutes: int.parse(m.group(4)!),
                seconds: int.parse(m.group(5)!)),
      ),
  ];
}

/// The time mark a tap at caret [offset] in [text] lands on. The caret
/// positions at a mark's outer edges don't count, so tapping just before
/// "[" or after "]" (or past the end of a line that ends with a mark) still
/// just places the cursor.
TimeMark? timeMarkAt(String text, int offset) {
  for (final TimeMark mark in findTimeMarks(text)) {
    if (offset > mark.start && offset < mark.end) return mark;
    if (mark.start >= offset) break;
  }
  return null;
}

/// The time mark at document [offset], looking only at the line there.
TimeMark? timeMarkInDocumentAt(Document document, int offset) {
  if (offset < 0 || offset >= document.length) return null;
  final query = document.queryChild(offset);
  final line = query.node;
  if (line == null) return null;
  return timeMarkAt(line.toPlainText(), query.offset);
}

/// A [TextSpanBuilder] for [QuillEditorConfig.textSpanBuilder] that draws
/// the time marks in each run of text with [markStyle] merged over the
/// run's own style. The text itself is unchanged, so editing and caret
/// offsets are unaffected.
TextSpanBuilder timeMarkSpanBuilder(TextStyle markStyle) {
  return (context, node, nodeOffset, text, style, recognizer) {
    final List<TimeMark> marks = findTimeMarks(text);
    if (marks.isEmpty) {
      return TextSpan(text: text, style: style, recognizer: recognizer);
    }
    final TextStyle merged = style?.merge(markStyle) ?? markStyle;
    final List<TextSpan> children = [];
    int at = 0;
    for (final TimeMark mark in marks) {
      if (mark.start > at) {
        children.add(TextSpan(
            text: text.substring(at, mark.start), recognizer: recognizer));
      }
      children.add(TextSpan(
          text: text.substring(mark.start, mark.end),
          style: merged,
          recognizer: recognizer));
      at = mark.end;
    }
    if (at < text.length) {
      children.add(TextSpan(text: text.substring(at), recognizer: recognizer));
    }
    return TextSpan(style: style, children: children);
  };
}
