import 'dart:convert';
import 'dart:io';

import 'package:homiletics/common/bible_reference.dart';

/// One verse. [end] is set when the text combines several verses ("1-2").
/// "\n" inside [text] is a poetry line break.
class BibleVerse {
  final int number;
  final int? end;
  final String text;

  const BibleVerse(this.number, this.text, {this.end});

  /// "4" or "9-10".
  String get label => end == null ? '$number' : '$number-$end';
}

/// A heading shown before verse [beforeVerse]. [description] marks a psalm
/// title ("A Psalm by David.") rather than a section heading.
class BibleHeading {
  final int beforeVerse;
  final String text;
  final bool description;

  const BibleHeading(this.beforeVerse, this.text, {this.description = false});
}

class BibleChapter {
  final int number;
  final List<BibleVerse> verses;
  final List<BibleHeading> headings;

  /// Verses that start a new paragraph / a new (poetry) line.
  final Set<int> paragraphStarts;
  final Set<int> lineStarts;

  const BibleChapter({
    required this.number,
    required this.verses,
    this.headings = const [],
    this.paragraphStarts = const {},
    this.lineStarts = const {},
  });
}

class BibleTextBook {
  final String id;
  final String name;
  final Map<int, BibleChapter> chapters;

  const BibleTextBook(
      {required this.id, required this.name, required this.chapters});
}

/// What the verse panel shows for one chapter of a passage: the verses in
/// range, with the headings and breaks that fall among them.
class PassageChapter {
  final BibleTextBook book;
  final BibleChapter chapter;
  final List<BibleVerse> verses;

  const PassageChapter(this.book, this.chapter, this.verses);

  /// "Romans 3" in the translation's own language.
  String get title => '${book.name} ${chapter.number}';
}

/// A whole downloaded translation (data/bibles/<code>.json.gz).
class BibleText {
  static const int supportedFormat = 1;

  final String code;
  final String name;
  final String short;
  final String license;
  final String copyright;
  final Map<String, BibleTextBook> books;

  const BibleText({
    required this.code,
    required this.name,
    required this.short,
    required this.license,
    required this.copyright,
    required this.books,
  });

  /// Book names in this translation, normalized, for
  /// [BibleReference.parse]'s `extraNames` ("romanos" -> "ROM").
  Map<String, String> get bookNames => {
        for (final BibleTextBook b in books.values)
          normalizeBookName(b.name): b.id,
      };

  /// The chapters [reference] covers, in order, or null when any of it is
  /// missing from this text (the caller then falls back to the web view).
  List<PassageChapter>? select(BibleReference reference) {
    final List<PassageChapter> out = [];
    for (final VerseRange r in reference.ranges) {
      final BibleTextBook? book = books[r.book.id];
      if (book == null) return null;
      for (int c = r.startChapter; c <= r.endChapter; c++) {
        final BibleChapter? chapter = book.chapters[c];
        if (chapter == null) return null;
        final List<BibleVerse> verses = chapter.verses
            .where((v) =>
                r.contains(c, v.number) ||
                (v.end != null && r.contains(c, v.end!)))
            .toList();
        if (verses.isEmpty) return null;
        // Ranges that continue in the same chapter ("3:1-4, 8") join it.
        if (out.isNotEmpty &&
            identical(out.last.chapter, chapter) &&
            identical(out.last.book, book)) {
          final List<BibleVerse> merged = [
            ...out.last.verses,
            ...verses.where((v) => !out.last.verses.contains(v)),
          ];
          out[out.length - 1] = PassageChapter(book, chapter, merged);
        } else {
          out.add(PassageChapter(book, chapter, verses));
        }
      }
    }
    return out.isEmpty ? null : out;
  }

  /// Decodes the gzipped JSON. Throws [FormatException] when it isn't a
  /// usable Bible file. Heavy: run it off the UI isolate.
  static BibleText decodeGzip(List<int> bytes) {
    try {
      return fromJson(jsonDecode(utf8.decode(gzip.decode(bytes))));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Unreadable Bible file: $e');
    }
  }

  static BibleText fromJson(Object? json) {
    if (json is! Map || json['format'] != supportedFormat) {
      throw const FormatException('Unsupported Bible file');
    }
    final Object? rawBooks = json['books'];
    if (rawBooks is! List || rawBooks.isEmpty) {
      throw const FormatException('Bible file has no books');
    }
    final Map<String, BibleTextBook> books = {};
    for (final Object? b in rawBooks) {
      if (b is! Map) continue;
      final String id = b['id'] as String;
      final Map<int, BibleChapter> chapters = {};
      for (final Object? c in (b['chapters'] as List)) {
        final Map ch = c as Map;
        final int number = ch['c'] as int;
        final List<BibleVerse> verses = [
          for (final Object? v in ch['v'] as List)
            BibleVerse((v as List)[0] as int, v[1] as String,
                end: v.length > 2 ? v[2] as int : null),
        ];
        final List<BibleHeading> headings = [
          for (final Object? h in (ch['h'] as List?) ?? const [])
            BibleHeading((h as List)[0] as int, h[1] as String,
                description: h.length > 2 && h[2] == 1),
        ];
        chapters[number] = BibleChapter(
          number: number,
          verses: verses,
          headings: headings,
          paragraphStarts: {...((ch['p'] as List?) ?? const []).cast<int>()},
          lineStarts: {...((ch['l'] as List?) ?? const []).cast<int>()},
        );
      }
      books[id] = BibleTextBook(
          id: id, name: (b['name'] as String?) ?? id, chapters: chapters);
    }
    return BibleText(
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      short: json['short'] as String? ?? '',
      license: json['license'] as String? ?? '',
      copyright: json['copyright'] as String? ?? '',
      books: books,
    );
  }
}
