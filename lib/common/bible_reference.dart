/// Parses passage references ("Romans 3:1-20", "Daniel 1-2;6-7",
/// "Joel; 2 Peter 3") into book / chapter / verse ranges, for showing a
/// passage from an offline Bible text. Anything it can't read with
/// confidence parses to null, and the caller falls back to Bible Gateway.
library;

/// One of the 66 books: USFM code (the id used by the offline texts), OSIS
/// id, English name and chapter count (English versification).
class BibleBook {
  final String id;
  final String osis;
  final String name;
  final int chapters;

  const BibleBook(this.id, this.osis, this.name, this.chapters);

  bool get singleChapter => chapters == 1;

  /// Index in canonical order (Genesis = 0).
  int get index => kBibleBooks.indexOf(this);

  static BibleBook? byId(String id) => _byId[id.toUpperCase()];

  @override
  String toString() => name;
}

const List<BibleBook> kBibleBooks = [
  BibleBook('GEN', 'Gen', 'Genesis', 50),
  BibleBook('EXO', 'Exod', 'Exodus', 40),
  BibleBook('LEV', 'Lev', 'Leviticus', 27),
  BibleBook('NUM', 'Num', 'Numbers', 36),
  BibleBook('DEU', 'Deut', 'Deuteronomy', 34),
  BibleBook('JOS', 'Josh', 'Joshua', 24),
  BibleBook('JDG', 'Judg', 'Judges', 21),
  BibleBook('RUT', 'Ruth', 'Ruth', 4),
  BibleBook('1SA', '1Sam', '1 Samuel', 31),
  BibleBook('2SA', '2Sam', '2 Samuel', 24),
  BibleBook('1KI', '1Kgs', '1 Kings', 22),
  BibleBook('2KI', '2Kgs', '2 Kings', 25),
  BibleBook('1CH', '1Chr', '1 Chronicles', 29),
  BibleBook('2CH', '2Chr', '2 Chronicles', 36),
  BibleBook('EZR', 'Ezra', 'Ezra', 10),
  BibleBook('NEH', 'Neh', 'Nehemiah', 13),
  BibleBook('EST', 'Esth', 'Esther', 10),
  BibleBook('JOB', 'Job', 'Job', 42),
  BibleBook('PSA', 'Ps', 'Psalms', 150),
  BibleBook('PRO', 'Prov', 'Proverbs', 31),
  BibleBook('ECC', 'Eccl', 'Ecclesiastes', 12),
  BibleBook('SNG', 'Song', 'Song of Songs', 8),
  BibleBook('ISA', 'Isa', 'Isaiah', 66),
  BibleBook('JER', 'Jer', 'Jeremiah', 52),
  BibleBook('LAM', 'Lam', 'Lamentations', 5),
  BibleBook('EZK', 'Ezek', 'Ezekiel', 48),
  BibleBook('DAN', 'Dan', 'Daniel', 12),
  BibleBook('HOS', 'Hos', 'Hosea', 14),
  BibleBook('JOL', 'Joel', 'Joel', 3),
  BibleBook('AMO', 'Amos', 'Amos', 9),
  BibleBook('OBA', 'Obad', 'Obadiah', 1),
  BibleBook('JON', 'Jonah', 'Jonah', 4),
  BibleBook('MIC', 'Mic', 'Micah', 7),
  BibleBook('NAM', 'Nah', 'Nahum', 3),
  BibleBook('HAB', 'Hab', 'Habakkuk', 3),
  BibleBook('ZEP', 'Zeph', 'Zephaniah', 3),
  BibleBook('HAG', 'Hag', 'Haggai', 2),
  BibleBook('ZEC', 'Zech', 'Zechariah', 14),
  BibleBook('MAL', 'Mal', 'Malachi', 4),
  BibleBook('MAT', 'Matt', 'Matthew', 28),
  BibleBook('MRK', 'Mark', 'Mark', 16),
  BibleBook('LUK', 'Luke', 'Luke', 24),
  BibleBook('JHN', 'John', 'John', 21),
  BibleBook('ACT', 'Acts', 'Acts', 28),
  BibleBook('ROM', 'Rom', 'Romans', 16),
  BibleBook('1CO', '1Cor', '1 Corinthians', 16),
  BibleBook('2CO', '2Cor', '2 Corinthians', 13),
  BibleBook('GAL', 'Gal', 'Galatians', 6),
  BibleBook('EPH', 'Eph', 'Ephesians', 6),
  BibleBook('PHP', 'Phil', 'Philippians', 4),
  BibleBook('COL', 'Col', 'Colossians', 4),
  BibleBook('1TH', '1Thess', '1 Thessalonians', 5),
  BibleBook('2TH', '2Thess', '2 Thessalonians', 3),
  BibleBook('1TI', '1Tim', '1 Timothy', 6),
  BibleBook('2TI', '2Tim', '2 Timothy', 4),
  BibleBook('TIT', 'Titus', 'Titus', 3),
  BibleBook('PHM', 'Phlm', 'Philemon', 1),
  BibleBook('HEB', 'Heb', 'Hebrews', 13),
  BibleBook('JAS', 'Jas', 'James', 5),
  BibleBook('1PE', '1Pet', '1 Peter', 5),
  BibleBook('2PE', '2Pet', '2 Peter', 3),
  BibleBook('1JN', '1John', '1 John', 5),
  BibleBook('2JN', '2John', '2 John', 1),
  BibleBook('3JN', '3John', '3 John', 1),
  BibleBook('JUD', 'Jude', 'Jude', 1),
  BibleBook('REV', 'Rev', 'Revelation', 22),
];

final Map<String, BibleBook> _byId = {for (final b in kBibleBooks) b.id: b};

/// Extra English names and abbreviations (normalized: lower case, no
/// periods, a space after a leading number).
const Map<String, List<String>> _aliases = {
  'GEN': ['gen', 'ge', 'gn'],
  'EXO': ['exod', 'exo', 'ex', 'exodo'],
  'LEV': ['lev', 'le', 'lv'],
  'NUM': ['num', 'nu', 'nm', 'nb'],
  'DEU': ['deut', 'deu', 'dt', 'de'],
  'JOS': ['josh', 'jos', 'jsh'],
  'JDG': ['judg', 'jdg', 'jg', 'jdgs'],
  'RUT': ['ruth', 'rth', 'ru'],
  '1SA': ['1 sam', '1 sa', '1 sm', '1 samuel'],
  '2SA': ['2 sam', '2 sa', '2 sm', '2 samuel'],
  '1KI': ['1 kgs', '1 ki', '1 kin', '1 kings', '1 kg'],
  '2KI': ['2 kgs', '2 ki', '2 kin', '2 kings', '2 kg'],
  '1CH': ['1 chr', '1 ch', '1 chron', '1 chronicles'],
  '2CH': ['2 chr', '2 ch', '2 chron', '2 chronicles'],
  'EZR': ['ezra', 'ezr'],
  'NEH': ['neh', 'ne'],
  'EST': ['esth', 'est', 'es'],
  'JOB': ['job', 'jb'],
  'PSA': ['psalm', 'psalms', 'ps', 'psa', 'pss', 'psm', 'pslm'],
  'PRO': ['prov', 'pro', 'prv', 'pr'],
  'ECC': ['eccl', 'ecc', 'ec', 'eccles', 'qoh', 'qoheleth'],
  'SNG': [
    'song',
    'sos',
    'sng',
    'song of solomon',
    'song of songs',
    'canticles',
    'song of sol',
    'canticle of canticles'
  ],
  'ISA': ['isa', 'is'],
  'JER': ['jer', 'je', 'jr'],
  'LAM': ['lam', 'la'],
  'EZK': ['ezek', 'eze', 'ezk'],
  'DAN': ['dan', 'da', 'dn'],
  'HOS': ['hos', 'ho'],
  'JOL': ['joel', 'jl', 'jol'],
  'AMO': ['amos', 'am', 'amo'],
  'OBA': ['obad', 'ob', 'oba'],
  'JON': ['jonah', 'jon', 'jnh'],
  'MIC': ['mic', 'mc'],
  'NAM': ['nah', 'na', 'nam'],
  'HAB': ['hab', 'hb'],
  'ZEP': ['zeph', 'zep', 'zp'],
  'HAG': ['hag', 'hg'],
  'ZEC': ['zech', 'zec', 'zc'],
  'MAL': ['mal', 'ml'],
  'MAT': ['matt', 'mt', 'mat'],
  'MRK': ['mark', 'mk', 'mrk', 'mr'],
  'LUK': ['luke', 'lk', 'luk'],
  'JHN': ['john', 'jn', 'jhn', 'joh'],
  'ACT': ['acts', 'ac', 'act', 'acts of the apostles'],
  'ROM': ['rom', 'ro', 'rm'],
  '1CO': ['1 cor', '1 co', '1 corinthians'],
  '2CO': ['2 cor', '2 co', '2 corinthians'],
  'GAL': ['gal', 'ga'],
  'EPH': ['eph', 'ephes'],
  'PHP': ['phil', 'php', 'pp'],
  'COL': ['col'],
  '1TH': ['1 thess', '1 th', '1 thes', '1 thessalonians'],
  '2TH': ['2 thess', '2 th', '2 thes', '2 thessalonians'],
  '1TI': ['1 tim', '1 ti', '1 timothy'],
  '2TI': ['2 tim', '2 ti', '2 timothy'],
  'TIT': ['titus', 'tit'],
  'PHM': ['philem', 'phlm', 'phm', 'philemon'],
  'HEB': ['heb'],
  'JAS': ['jas', 'jm', 'jam', 'james'],
  '1PE': ['1 pet', '1 pe', '1 pt', '1 peter'],
  '2PE': ['2 pet', '2 pe', '2 pt', '2 peter'],
  '1JN': ['1 john', '1 jn', '1 jhn', '1 jo'],
  '2JN': ['2 john', '2 jn', '2 jhn', '2 jo'],
  '3JN': ['3 john', '3 jn', '3 jhn', '3 jo'],
  'JUD': ['jude', 'jud', 'jd'],
  'REV': ['rev', 're', 'rv', 'revelations', 'apocalypse', 'revelation of john'],
};

final Map<String, String> _englishNames = () {
  final Map<String, String> names = {};
  for (final BibleBook b in kBibleBooks) {
    names[normalizeBookName(b.name)] = b.id;
    names[normalizeBookName(b.osis)] = b.id;
    names[normalizeBookName(b.id)] = b.id;
  }
  _aliases.forEach((id, list) {
    for (final String alias in list) {
      names[normalizeBookName(alias)] = id;
    }
  });
  return names;
}();

final RegExp _ordinalWord = RegExp(
    r'^(first|1st|i|second|2nd|ii|third|3rd|iii)\s+',
    caseSensitive: false);
final RegExp _leadingDigit = RegExp(r'^([1-3])\s*(?=\D)');

/// Lower case, no periods, single spaces, "II Kings" / "2Kings" ->
/// "2 kings". Used for both the built-in names and [extraNames] keys.
String normalizeBookName(String name) {
  String s = name.toLowerCase().replaceAll('.', ' ').trim();
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  s = s.replaceFirstMapped(_ordinalWord, (m) {
    switch (m.group(1)!) {
      case 'first':
      case '1st':
      case 'i':
        return '1 ';
      case 'second':
      case '2nd':
      case 'ii':
        return '2 ';
      default:
        return '3 ';
    }
  });
  s = s.replaceFirstMapped(_leadingDigit, (m) => '${m.group(1)} ');
  return s.trim();
}

/// A contiguous stretch of one book. A null verse means "from the start of
/// [startChapter]" / "to the end of [endChapter]".
class VerseRange {
  final BibleBook book;
  final int startChapter;
  final int? startVerse;
  final int endChapter;
  final int? endVerse;

  const VerseRange(this.book, this.startChapter, this.startVerse,
      this.endChapter, this.endVerse);

  /// Whether chapter [c], verse [v] falls in this range.
  bool contains(int c, int v) {
    if (c < startChapter || c > endChapter) return false;
    if (c == startChapter && startVerse != null && v < startVerse!) {
      return false;
    }
    if (c == endChapter && endVerse != null && v > endVerse!) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is VerseRange &&
      other.book.id == book.id &&
      other.startChapter == startChapter &&
      other.startVerse == startVerse &&
      other.endChapter == endChapter &&
      other.endVerse == endVerse;

  @override
  int get hashCode =>
      Object.hash(book.id, startChapter, startVerse, endChapter, endVerse);

  @override
  String toString() {
    final String start =
        startVerse == null ? '$startChapter' : '$startChapter:$startVerse';
    final String end =
        endVerse == null ? '$endChapter' : '$endChapter:$endVerse';
    return '${book.id} $start-$end';
  }
}

class BibleReference {
  final List<VerseRange> ranges;

  const BibleReference(this.ranges);

  /// Whether the passage covers more than one chapter (or book), so a verse
  /// on its own ("4") would be ambiguous.
  bool get spansChapters {
    final Set<String> chapters = {};
    for (final VerseRange r in ranges) {
      for (int c = r.startChapter; c <= r.endChapter; c++) {
        chapters.add('${r.book.id} $c');
        if (chapters.length > 1) return true;
      }
    }
    return false;
  }

  /// Reads [text], or returns null when any part of it isn't a reference
  /// this parser understands. [extraNames] maps further book names
  /// (normalized with [normalizeBookName], e.g. a translation's own
  /// "romanos" / "罗马书") to USFM ids.
  static BibleReference? parse(String text,
      {Map<String, String> extraNames = const {}}) {
    final String input = text
        .replaceAll(RegExp(r'[–—−‐‑]'), '-')
        .replaceAll('；', ';')
        .replaceAll('，', ',')
        .replaceAll('：', ':')
        .trim();
    if (input.isEmpty) return null;
    final List<VerseRange> ranges = [];
    BibleBook? book;
    for (final String rawPart in input.split(';')) {
      final String part = rawPart.trim();
      if (part.isEmpty) continue;
      final _Split? split = _splitBook(part, extraNames);
      String rest;
      if (split != null) {
        book = split.book;
        rest = split.rest;
      } else if (book != null && RegExp(r'^\d').hasMatch(part)) {
        // "Daniel 1-2; 6-7": a bare number continues the previous book.
        rest = part;
      } else {
        return null;
      }
      final List<VerseRange>? parsed = _parseNumbers(book, rest);
      if (parsed == null) return null;
      ranges.addAll(parsed);
    }
    return ranges.isEmpty ? null : BibleReference(ranges);
  }

  /// Splits "1 John 3:16" into the book and "3:16".
  static _Split? _splitBook(String part, Map<String, String> extraNames) {
    // Book: an optional leading number, then everything up to the first
    // digit. "1 John 3", "Song of Songs 2", "约翰福音3:16", "Joel".
    final RegExpMatch? m =
        RegExp(r'^((?:[1-3]\s*)?[^\d]+?)\s*(\d.*)?$').firstMatch(part);
    if (m == null) return null;
    final String name = normalizeBookName(m.group(1)!);
    final String? id = extraNames[name] ?? _englishNames[name];
    if (id == null) return null;
    final BibleBook? book = BibleBook.byId(id);
    if (book == null) return null;
    return _Split(book, (m.group(2) ?? '').trim());
  }

  static final RegExp _cv = RegExp(r'^(\d+)[a-z]?(?:\s*[:.]\s*(\d+)[a-z]?)?$');

  /// "", "3", "3-4", "3:1-20", "3:16-4:2", "3:1-4, 8, 10-12", "1-2, 5".
  static List<VerseRange>? _parseNumbers(BibleBook book, String rest) {
    if (rest.isEmpty) {
      return [VerseRange(book, 1, null, book.chapters, null)];
    }
    final List<VerseRange> out = [];
    // Within a comma list, the chapter of the last verse-level item, so
    // "3:1-4, 8" reads 8 as a verse of chapter 3.
    int? verseChapter;
    for (final String rawItem in rest.split(',')) {
      final String item = rawItem.trim();
      if (item.isEmpty) return null;
      final List<String> ends = item.split('-');
      if (ends.length > 2) return null;
      final _Point? a = _point(ends[0].trim());
      final _Point? b = ends.length == 2 ? _point(ends[1].trim()) : null;
      if (a == null || (ends.length == 2 && b == null)) return null;

      int sc, ec;
      int? sv, ev;
      if (book.singleChapter &&
          a.verse == null &&
          (b == null || b.verse == null)) {
        // "Jude 3", "Obadiah 1-4": numbers are verses.
        sc = ec = 1;
        sv = a.first;
        ev = b?.first ?? a.first;
        if (a.first == 1 && b == null && rest.trim() == '1') {
          // "Jude 1" means the whole (one-chapter) book.
          sv = ev = null;
        }
      } else if (a.verse == null && verseChapter != null) {
        // A bare number after a verse in a comma list: a verse.
        sc = ec = verseChapter;
        sv = a.first;
        if (b == null) {
          ev = a.first;
        } else if (b.verse == null) {
          ev = b.first;
        } else {
          ec = b.first;
          ev = b.verse;
        }
      } else if (a.verse == null) {
        // Chapters: "3", "3-4", or "3-4:2".
        sc = a.first;
        sv = null;
        if (b == null) {
          ec = a.first;
          ev = null;
        } else if (b.verse == null) {
          ec = b.first;
          ev = null;
        } else {
          ec = b.first;
          ev = b.verse;
        }
      } else {
        sc = a.first;
        sv = a.verse;
        if (b == null) {
          ec = sc;
          ev = sv;
        } else if (b.verse == null) {
          // "3:1-20": the second number is a verse in the same chapter.
          ec = sc;
          ev = b.first;
        } else {
          ec = b.first;
          ev = b.verse;
        }
      }
      if (sc < 1 || ec < sc || ec > book.chapters) return null;
      if ((sv != null && sv < 1) || (ev != null && ev < 1)) return null;
      if (sc == ec && sv != null && ev != null && ev < sv) return null;
      out.add(VerseRange(book, sc, sv, ec, ev));
      verseChapter = ev != null ? ec : null;
    }
    return out;
  }

  static _Point? _point(String s) {
    final RegExpMatch? m = _cv.firstMatch(s);
    if (m == null) return null;
    return _Point(int.parse(m.group(1)!),
        m.group(2) == null ? null : int.parse(m.group(2)!));
  }

  @override
  String toString() => ranges.join('; ');
}

class _Split {
  final BibleBook book;
  final String rest;
  _Split(this.book, this.rest);
}

class _Point {
  final int first;
  final int? verse;
  _Point(this.first, this.verse);
}
