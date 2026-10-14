import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/bible_reference.dart';
import 'package:homiletics/services/bible_text.dart';

/// A tiny Bible file in the format tool/build_bibles.py writes.
Map<String, dynamic> sampleBibleJson({String code = 'web'}) => {
      'format': 1,
      'code': code,
      'name': 'World English Bible',
      'short': 'WEB',
      'language': 'en',
      'license': 'Public Domain',
      'copyright': 'Public Domain.',
      'source': 'https://ebible.org/engwebp/',
      'books': [
        {
          'id': 'ROM',
          'osis': 'Rom',
          'name': 'Romanos',
          'chapters': [
            {
              'c': 3,
              'v': [
                for (int v = 1; v <= 31; v++) [v, 'Romans three verse $v.'],
              ],
              'h': [
                [1, 'God’s Faithfulness'],
                [21, 'Righteousness Through Faith'],
              ],
              'p': [1, 9, 21],
            },
            {
              'c': 4,
              'v': [
                [1, 'Romans four verse one.'],
                [2, 'Romans four verse two.', 3],
                [4, 'Line one\nLine two'],
              ],
              'l': [4],
            },
          ],
        },
        {
          'id': 'PSA',
          'osis': 'Ps',
          'name': 'Psalms',
          'chapters': [
            {
              'c': 3,
              'v': [
                [1, 'LORD, how my adversaries have increased!'],
              ],
              'h': [
                [1, 'A Psalm by David.', 1],
              ],
            },
          ],
        },
      ],
    };

BibleText sampleBible() => BibleText.fromJson(sampleBibleJson());

void main() {
  test('decodes headings, breaks and combined verses', () {
    final BibleText text = BibleText.decodeGzip(
        gzip.encode(utf8.encode(jsonEncode(sampleBibleJson()))));
    expect(text.code, 'web');
    final BibleChapter rom3 = text.books['ROM']!.chapters[3]!;
    expect(rom3.verses.length, 31);
    expect(rom3.headings.first.text, 'God’s Faithfulness');
    expect(rom3.paragraphStarts, {1, 9, 21});
    final BibleChapter rom4 = text.books['ROM']!.chapters[4]!;
    expect(rom4.verses[1].end, 3);
    expect(rom4.verses[1].label, '2-3');
    expect(rom4.lineStarts, {4});
    expect(text.books['PSA']!.chapters[3]!.headings.single.description, isTrue);
  });

  test('rejects files that are not Bibles', () {
    expect(() => BibleText.decodeGzip(utf8.encode('not gzip')),
        throwsFormatException);
    expect(() => BibleText.decodeGzip(gzip.encode(utf8.encode('{"format":2}'))),
        throwsFormatException);
    expect(
        () => BibleText.decodeGzip(
            gzip.encode(utf8.encode('{"format":1,"books":[{"id":3}]}'))),
        throwsFormatException);
  });

  test('select picks the verses in range', () {
    final BibleText text = sampleBible();
    final chapters = text.select(BibleReference.parse('Romans 3:1-20')!)!;
    expect(chapters.length, 1);
    expect(chapters.single.verses.map((v) => v.number),
        List.generate(20, (i) => i + 1));
    expect(chapters.single.title, 'Romanos 3');

    final across = text.select(BibleReference.parse('Romans 3:30-4:2')!)!;
    expect(across.length, 2);
    expect(across[0].verses.map((v) => v.number), [30, 31]);
    // The combined 2-3 verse is included when either end is in range.
    expect(across[1].verses.map((v) => v.label), ['1', '2-3']);

    final whole = text.select(BibleReference.parse('Romans 4')!)!;
    expect(whole.single.verses.length, 3);

    final list = text.select(BibleReference.parse('Romans 3:1-2, 5')!)!;
    expect(list.length, 1);
    expect(list.single.verses.map((v) => v.number), [1, 2, 5]);
  });

  test('select returns null when anything is missing', () {
    final BibleText text = sampleBible();
    expect(text.select(BibleReference.parse('John 3')!), isNull);
    expect(text.select(BibleReference.parse('Romans 5')!), isNull);
    expect(text.select(BibleReference.parse('Romans 3; John 1')!), isNull);
    expect(text.select(BibleReference.parse('Romans 4:9-12')!), isNull);
  });

  test('book names from the text help parse localized references', () {
    final BibleText text = sampleBible();
    final ref =
        BibleReference.parse('Romanos 3:1-4', extraNames: text.bookNames);
    expect(ref, isNotNull);
    expect(text.select(ref!)!.single.verses.length, 4);
  });

  group('generated data/bibles files', () {
    for (final Translation t
        in Translation.all.where((t) => t.offlineAvailable)) {
      test('${t.code}.json.gz is complete and matches its translation', () {
        final File file = File('data/bibles/${t.code}.json.gz');
        expect(file.existsSync(), isTrue, reason: file.path);
        final int size = file.lengthSync();
        // Translation.offlineBytes is the size the picker promises.
        expect((size - t.offlineBytes!).abs(), lessThan(size ~/ 10),
            reason: 'update offlineBytes for ${t.code} to $size');
        final BibleText text = BibleText.decodeGzip(file.readAsBytesSync());
        expect(text.code, t.code);
        expect(text.copyright, isNotEmpty);
        expect(text.books.length, 66);
        for (final BibleBook b in kBibleBooks) {
          expect(text.books[b.id], isNotNull, reason: '${t.code} ${b.id}');
        }
        final rom = text.select(BibleReference.parse('Romans 3:21-26')!);
        expect(rom, isNotNull);
        expect(rom!.single.verses, isNotEmpty);
        expect(text.select(BibleReference.parse('Psalm 42-43')!), isNotNull);
        expect(text.select(BibleReference.parse('Joel')!), isNotNull);
      });
    }
  });
}
