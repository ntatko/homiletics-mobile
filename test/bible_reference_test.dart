import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/common/bible_reference.dart';

VerseRange _r(String book, int sc, int? sv, int ec, int? ev) =>
    VerseRange(BibleBook.byId(book)!, sc, sv, ec, ev);

List<VerseRange>? _parse(String s, {Map<String, String> extra = const {}}) =>
    BibleReference.parse(s, extraNames: extra)?.ranges;

void main() {
  group('book table', () {
    test('has 66 books with unique ids', () {
      expect(kBibleBooks.length, 66);
      expect(kBibleBooks.map((b) => b.id).toSet().length, 66);
      expect(BibleBook.byId('rom')!.name, 'Romans');
      expect(BibleBook.byId('JHN')!.chapters, 21);
    });
  });

  group('parses the passages the app uses', () {
    test('verse range', () {
      expect(_parse('Romans 3:1-20'), [_r('ROM', 3, 1, 3, 20)]);
    });
    test('single chapter', () {
      expect(_parse('Psalm 42'), [_r('PSA', 42, null, 42, null)]);
      expect(_parse('John 19'), [_r('JHN', 19, null, 19, null)]);
    });
    test('chapter range', () {
      expect(_parse('Psalm 42-43'), [_r('PSA', 42, null, 43, null)]);
      expect(_parse('1 Chronicles 28-29'), [_r('1CH', 28, null, 29, null)]);
    });
    test('bare chapters after a semicolon continue the book', () {
      expect(_parse('Daniel 1-2;6-7'), [
        _r('DAN', 1, null, 2, null),
        _r('DAN', 6, null, 7, null),
      ]);
      expect(_parse('Daniel 1-2; 6'), [
        _r('DAN', 1, null, 2, null),
        _r('DAN', 6, null, 6, null),
      ]);
    });
    test('several books', () {
      expect(_parse('Acts 2; Romans 11; Ephesians 4'), [
        _r('ACT', 2, null, 2, null),
        _r('ROM', 11, null, 11, null),
        _r('EPH', 4, null, 4, null),
      ]);
    });
    test('whole book', () {
      expect(_parse('Joel'), [_r('JOL', 1, null, 3, null)]);
      expect(_parse('Joel; 2 Peter 3'), [
        _r('JOL', 1, null, 3, null),
        _r('2PE', 3, null, 3, null),
      ]);
    });
    test('cross-chapter ranges', () {
      expect(_parse('John 3:16-4:2'), [_r('JHN', 3, 16, 4, 2)]);
      expect(_parse('Daniel 10:1-12:13'), [_r('DAN', 10, 1, 12, 13)]);
      expect(_parse('Revelation 2:12-3:6'), [_r('REV', 2, 12, 3, 6)]);
    });
    test('chapter to a verse of a later chapter', () {
      expect(_parse('Exodus 3-4:17'), [_r('EXO', 3, null, 4, 17)]);
    });
    test('single verse', () {
      expect(_parse('John 3:16'), [_r('JHN', 3, 16, 3, 16)]);
    });
    test('every suggested-passage shape', () {
      for (final s in [
        'Exodus 11:1-13:16',
        'Esther 3:1-7:10',
        'Haggai 1-2',
        'Malachi 1:1-4:6',
        'Nehemiah 6:15-8:18',
        'Revelation 22:6-21',
        'Romans 16',
        'Ezra 9-10',
        'Ezekiel 36:16-37:28',
        'Revelation 20:11-21:8',
      ]) {
        expect(_parse(s), isNotNull, reason: s);
      }
    });
  });

  test('every reference in data/suggested-passages.json parses', () {
    final Map<String, dynamic> doc =
        jsonDecode(File('data/suggested-passages.json').readAsStringSync());
    const words = {'Overview', 'Reflections', 'Summary'};
    for (final week in doc['data'] as List) {
      final String passage = week['passage'] as String;
      if (words.contains(passage.trim())) {
        expect(_parse(passage), isNull, reason: passage);
      } else {
        expect(_parse(passage), isNotNull, reason: passage);
      }
    }
  });

  group('comma lists', () {
    test('verses after a verse stay in that chapter', () {
      expect(_parse('Romans 3:1-4, 8, 10-12'), [
        _r('ROM', 3, 1, 3, 4),
        _r('ROM', 3, 8, 3, 8),
        _r('ROM', 3, 10, 3, 12),
      ]);
    });
    test('chapters after a chapter are chapters', () {
      expect(_parse('John 3, 5'), [
        _r('JHN', 3, null, 3, null),
        _r('JHN', 5, null, 5, null),
      ]);
    });
  });

  group('names and abbreviations', () {
    test('abbreviations, periods, case', () {
      expect(_parse('Rom 3:1'), [_r('ROM', 3, 1, 3, 1)]);
      expect(_parse('Rom. 3:1'), [_r('ROM', 3, 1, 3, 1)]);
      expect(_parse('rom 3:1'), [_r('ROM', 3, 1, 3, 1)]);
      expect(_parse('Gen 1'), [_r('GEN', 1, null, 1, null)]);
      expect(_parse('Ps 23'), [_r('PSA', 23, null, 23, null)]);
      expect(_parse('Psalms 23'), [_r('PSA', 23, null, 23, null)]);
      expect(_parse('Matt 5:3-12'), [_r('MAT', 5, 3, 5, 12)]);
      expect(_parse('Mk 1'), [_r('MRK', 1, null, 1, null)]);
      expect(_parse('Jn 1:1'), [_r('JHN', 1, 1, 1, 1)]);
      expect(_parse('Rev 1'), [_r('REV', 1, null, 1, null)]);
      expect(_parse('Revelations 1'), [_r('REV', 1, null, 1, null)]);
    });
    test('numbered books', () {
      expect(_parse('1 John 1'), [_r('1JN', 1, null, 1, null)]);
      expect(_parse('1John 1'), [_r('1JN', 1, null, 1, null)]);
      expect(_parse('I John 1'), [_r('1JN', 1, null, 1, null)]);
      expect(_parse('II Kings 2'), [_r('2KI', 2, null, 2, null)]);
      expect(_parse('2 Cor 5:17'), [_r('2CO', 5, 17, 5, 17)]);
      expect(_parse('First Corinthians 13'), [_r('1CO', 13, null, 13, null)]);
      expect(_parse('3 John'), [_r('3JN', 1, null, 1, null)]);
    });
    test('multi-word names', () {
      expect(_parse('Song of Songs 2'), [_r('SNG', 2, null, 2, null)]);
      expect(_parse('Song of Solomon 2:1-7'), [_r('SNG', 2, 1, 2, 7)]);
    });
    test('dashes and full-width punctuation', () {
      expect(_parse('Romans 3:1–20'), [_r('ROM', 3, 1, 3, 20)]);
      expect(_parse('Romans 3:1—20'), [_r('ROM', 3, 1, 3, 20)]);
      expect(_parse('Romans 3：1-20'), [_r('ROM', 3, 1, 3, 20)]);
      expect(_parse('Romans 3.16'), [_r('ROM', 3, 16, 3, 16)]);
      expect(_parse('Romans 3:16a'), [_r('ROM', 3, 16, 3, 16)]);
    });
    test('single-chapter books read numbers as verses', () {
      expect(_parse('Jude 3'), [_r('JUD', 1, 3, 1, 3)]);
      expect(_parse('Obadiah 1-4'), [_r('OBA', 1, 1, 1, 4)]);
      expect(_parse('Philemon 1'), [_r('PHM', 1, null, 1, null)]);
      expect(_parse('Jude 1:3-4'), [_r('JUD', 1, 3, 1, 4)]);
    });
    test('extra (translation) names', () {
      final extra = {
        normalizeBookName('Romanos'): 'ROM',
        normalizeBookName('约翰福音'): 'JHN',
        normalizeBookName('1 João'): '1JN',
      };
      expect(_parse('Romanos 3:1-20', extra: extra), [_r('ROM', 3, 1, 3, 20)]);
      expect(_parse('约翰福音 3:16', extra: extra), [_r('JHN', 3, 16, 3, 16)]);
      expect(_parse('约翰福音3:16', extra: extra), [_r('JHN', 3, 16, 3, 16)]);
      expect(_parse('约翰福音 19；20', extra: extra), [
        _r('JHN', 19, null, 19, null),
        _r('JHN', 20, null, 20, null),
      ]);
      expect(_parse('1 João 4', extra: extra), [_r('1JN', 4, null, 4, null)]);
      expect(_parse('Romanos 3'), isNull);
    });
  });

  group('rejects what it cannot read', () {
    test('unknown / not a reference', () {
      for (final s in [
        '',
        '   ',
        'Overview',
        'Reflections',
        'Summary',
        'Hezekiah 3',
        '3:16',
        'Romans 3:1-2-3',
        'Romans three',
        'Romans 3:',
        'Romans 3; Overview',
      ]) {
        expect(_parse(s), isNull, reason: s);
      }
    });
    test('out of range or backwards', () {
      expect(_parse('Romans 17'), isNull);
      expect(_parse('Romans 0'), isNull);
      expect(_parse('Romans 4-3'), isNull);
      expect(_parse('Romans 3:20-1'), isNull);
      expect(_parse('Joel 4'), isNull);
    });
  });

  group('ranges', () {
    test('contains', () {
      final r = _r('JHN', 3, 16, 4, 2);
      expect(r.contains(3, 15), isFalse);
      expect(r.contains(3, 16), isTrue);
      expect(r.contains(3, 36), isTrue);
      expect(r.contains(4, 2), isTrue);
      expect(r.contains(4, 3), isFalse);
      expect(_r('JHN', 3, null, 3, null).contains(3, 99), isTrue);
    });
    test('spansChapters', () {
      expect(BibleReference.parse('Romans 3:1-20')!.spansChapters, isFalse);
      expect(BibleReference.parse('Psalm 42')!.spansChapters, isFalse);
      expect(BibleReference.parse('Psalm 42-43')!.spansChapters, isTrue);
      expect(BibleReference.parse('John 3:16-4:2')!.spansChapters, isTrue);
      expect(BibleReference.parse('Joel')!.spansChapters, isTrue);
      expect(BibleReference.parse('Jude')!.spansChapters, isFalse);
    });
  });
}
