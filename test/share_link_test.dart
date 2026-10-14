import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/services/share_link.dart';

void main() {
  final List<dynamic> vectors = jsonDecode(
          File('test/fixtures/share_link_vectors.json').readAsStringSync())
      as List<dynamic>;

  SharedStudy decodeOk(String input) {
    final ShareLinkResult result = ShareLink.decode(input);
    expect(result, isA<ShareLinkSuccess>(), reason: '$result for $input');
    return (result as ShareLinkSuccess).study;
  }

  group('test vectors', () {
    for (final dynamic raw in vectors) {
      final Map<String, dynamic> vector = raw as Map<String, dynamic>;
      final String name = vector['name'] as String;
      final String link = vector['link'] as String;
      final Map<String, dynamic>? envelope =
          vector['envelope'] as Map<String, dynamic>?;
      final String? expected = vector['expect'] as String?;

      if (envelope != null) {
        test('$name decodes to its envelope', () {
          expect(decodeOk(link).toEnvelope(), equals(envelope));
        });

        test('$name decodes from the custom scheme and as a bare payload', () {
          final String fragment = link.substring(link.indexOf('#') + 1);
          final String payload = fragment.substring(2);
          expect(decodeOk('homiletics://view#$fragment').toEnvelope(),
              equals(envelope));
          expect(decodeOk(payload).toEnvelope(), equals(envelope));
          expect(decodeOk('#$fragment').toEnvelope(), equals(envelope));
          expect(ShareLink.decodeUri(Uri.parse(link)), isA<ShareLinkSuccess>());
          expect(
              decodeOk('Have a look at my study: $link  (made in Homiletics)')
                  .toEnvelope(),
              equals(envelope));
        });

        test('$name re-encodes to an equivalent link', () {
          final String again = ShareLink.encodeStudy(decodeOk(link));
          expect(again, startsWith('https://homiletics.app/view#'));
          expect(again, isNot(contains('=' * 2)));
          expect(again.substring(again.indexOf('#') + 3), isNot(contains('=')));
          expect(decodeOk(again).toEnvelope(), equals(envelope));
        });

        test('$name payload of its envelope decodes back', () {
          final String payload = ShareLink.encodePayload(envelope);
          expect(ShareLink.decodePayload(payload), isA<ShareLinkSuccess>());
          expect(
              (ShareLink.decodePayload(payload) as ShareLinkSuccess)
                  .study
                  .toEnvelope(),
              equals(envelope));
        });
      } else if (expected == 'unsupported_version') {
        test('$name is reported as a newer version', () {
          final ShareLinkResult result = ShareLink.decode(link);
          expect(result, isA<ShareLinkUnsupportedVersion>());
          expect((result as ShareLinkUnsupportedVersion).version,
              greaterThan(ShareLink.version));
        });
      } else {
        test('$name is invalid', () {
          expect(ShareLink.decode(link), isA<ShareLinkInvalid>());
          expect(ShareLink.decodeUri(Uri.parse(link)), isA<ShareLinkInvalid>());
        });
      }
    }
  });

  group('invalid input', () {
    String payloadOf(Object? envelope) =>
        ShareLink.encodePayload(<String, dynamic>{'x': envelope});

    String rawPayload(String json) => base64Url
        .encode(ZLibEncoder(raw: true).convert(utf8.encode(json)))
        .replaceAll('=', '');

    test('rejects empty and unrelated text', () {
      expect(ShareLink.decode(''), isA<ShareLinkInvalid>());
      expect(ShareLink.decode('   '), isA<ShareLinkInvalid>());
      expect(ShareLink.decode('https://example.com/view#h=abc'),
          isA<ShareLinkInvalid>());
      expect(ShareLink.decode('hello world'), isA<ShareLinkInvalid>());
      expect(ShareLink.decode('https://homiletics.app/view'),
          isA<ShareLinkInvalid>());
    });

    test('rejects valid base64 that is not deflate / JSON', () {
      expect(ShareLink.decodePayload('AAAAAAAA'), isA<ShareLinkInvalid>());
      expect(ShareLink.decodePayload(rawPayload('not json')),
          isA<ShareLinkInvalid>());
      expect(ShareLink.decodePayload(payloadOf(1)), isA<ShareLinkInvalid>());
    });

    test('rejects the wrong shapes', () {
      for (final String json in [
        '[]',
        '"h"',
        '{"t":"h","d":{}}',
        '{"v":0,"t":"h","d":{}}',
        '{"v":"1","t":"h","d":{}}',
        '{"v":1.5,"t":"h","d":{}}',
        '{"v":1,"t":"x","d":{}}',
        '{"v":1,"t":"h"}',
        '{"v":1,"t":"h","d":[]}',
        '{"v":1,"t":"h","d":{"p":3}}',
        '{"v":1,"t":"h","d":{"c":"1-2"}}',
        '{"v":1,"t":"h","d":{"c":[["1-2"]]}}',
        '{"v":1,"t":"h","d":{"c":[["1-2","a","b"]]}}',
        '{"v":1,"t":"h","d":{"dv":[[1,"a"]]}}',
        '{"v":1,"t":"h","d":{"ap":"question"}}',
        '{"v":1,"t":"h","d":{"ap":["ok",2]}}',
        '{"v":1,"t":"h","d":{"tr":5}}',
        '{"v":1,"t":"w","d":{"wd":["x"]}}',
        '{"v":1,"t":"w","d":{"ap":["x"]}}',
      ]) {
        expect(
            ShareLink.decodePayload(rawPayload(json)), isA<ShareLinkInvalid>(),
            reason: json);
      }
    });

    test('rejects a fragment key that disagrees with the envelope', () {
      final String payload = rawPayload('{"v":1,"t":"w","d":{"wd":"grace"}}');
      expect(ShareLink.decode('https://homiletics.app/view#w=$payload'),
          isA<ShareLinkSuccess>());
      expect(ShareLink.decode('https://homiletics.app/view#h=$payload'),
          isA<ShareLinkInvalid>());
    });

    test('newer versions are unsupported whatever their shape', () {
      expect(ShareLink.decodePayload(rawPayload('{"v":2}')),
          isA<ShareLinkUnsupportedVersion>());
      expect(
          ShareLink.decodePayload(rawPayload('{"v":7,"t":"z","d":"anything"}')),
          isA<ShareLinkUnsupportedVersion>());
    });

    test('ignores unknown keys', () {
      final ShareLinkResult result = ShareLink.decodePayload(rawPayload(
          '{"v":1,"t":"h","x":true,"d":{"p":"John 3","zz":[1,2],"s":"Love."}}'));
      expect(result, isA<ShareLinkSuccess>());
      expect((result as ShareLinkSuccess).study.toEnvelope(), {
        'v': 1,
        't': 'h',
        'd': {'p': 'John 3', 's': 'Love.'},
      });
    });

    test('caps the decompressed size', () {
      // ~300 KB of JSON compresses to a few hundred bytes.
      final String big = '{"v":1,"t":"h","d":{"p":"${'a' * (300 * 1024)}"}}';
      final String payload = rawPayload(big);
      expect(payload.length, lessThan(2000));
      expect(ShareLink.decodePayload(payload), isA<ShareLinkInvalid>());

      // Just under the cap is fine.
      final String ok = '{"v":1,"t":"h","d":{"p":"${'a' * (250 * 1024)}"}}';
      expect(ShareLink.decodePayload(rawPayload(ok)), isA<ShareLinkSuccess>());
    });

    test('rejects truncated links', () {
      final String link = vectors.first['link'] as String;
      for (final int cut in [10, 40, 120]) {
        expect(ShareLink.decode(link.substring(0, link.length - cut)),
            isNot(isA<ShareLinkSuccess>()),
            reason: 'cut $cut');
      }
    });
  });

  group('encoding the app models', () {
    test('a homiletic round-trips with its rows, skipping empty ones', () {
      final Homiletic homiletic = Homiletic(
        passage: 'Romans 3:1-20',
        subjectSentence: 'God is faithful.',
        fcf: '',
        aim: 'the whole world is accountable to God.',
        updatedAt: DateTime.utc(2026, 10, 14, 12, 0, 0, 123),
      );
      final String link = ShareLink.encodeHomiletic(
        homiletic,
        summaries: [
          ContentSummary(homileticId: 1, passage: '1-2', summary: 'Words.'),
          ContentSummary(homileticId: 1),
          ContentSummary(homileticId: 1, passage: '3', summary: ''),
        ],
        divisions: [Division(1, passage: '1-8', title: 'Faithful.')],
        applications: [
          Application(homileticsId: 1, text: 'Where?'),
          Application(homileticsId: 1, text: '  '),
        ],
        translation: 'niv',
      );
      expect(decodeOk(link).toEnvelope(), {
        'v': 1,
        't': 'h',
        'd': {
          'p': 'Romans 3:1-20',
          'c': [
            ['1-2', 'Words.'],
            ['3', ''],
          ],
          'dv': [
            ['1-8', 'Faithful.'],
          ],
          's': 'God is faithful.',
          'a': 'the whole world is accountable to God.',
          'ap': ['Where?'],
          'tr': 'niv',
          'u': '2026-10-14T12:00:00Z',
        },
      });
    });

    test('a word study round-trips', () {
      final WordStudy study = WordStudy(
          passage: 'Romans 3:10',
          word: 'Righteous',
          otherUsage: 'Genesis 15:6\nRomans 1:17',
          deeperMeaning: 'Greek δίκαιος');
      final SharedStudy decoded =
          decodeOk(ShareLink.encodeWordStudy(study, translation: 'web'));
      expect(decoded, isA<SharedWordStudy>());
      final SharedWordStudy w = decoded as SharedWordStudy;
      expect(w.word, 'Righteous');
      expect(w.otherUsage, 'Genesis 15:6\nRomans 1:17');
      expect(w.deeperMeaning, 'Greek δίκαιος');
      expect(w.definition, '');
      expect(w.translation, 'web');
      expect(decoded.toData().containsKey('df'), isFalse);
    });

    test('an empty homiletic still makes a decodable link', () {
      final SharedStudy decoded =
          decodeOk(ShareLink.encodeHomiletic(Homiletic()));
      expect(decoded.toEnvelope(), {'v': 1, 't': 'h', 'd': {}});
    });
  });

  group('random round trips', () {
    final Random random = Random(42);
    const List<String> alphabet = [
      'a',
      'Z',
      '9',
      ' ',
      '\n',
      '"',
      '\\',
      '/',
      '#',
      '=',
      '&',
      '?',
      '%',
      'é',
      'ñ',
      'ü',
      'ß',
      'Ω',
      'ж',
      'א',
      'ع',
      '神',
      '祂',
      '圣',
      '言',
      '😀',
      '🙏',
      '👨‍👩‍👧',
      '​',
      '\t',
      '<',
      '>',
      '{',
      '}',
      '[',
      ']',
    ];
    String text(int maxLength) {
      final StringBuffer b = StringBuffer();
      final int n = random.nextInt(maxLength + 1);
      for (int i = 0; i < n; i++) {
        b.write(alphabet[random.nextInt(alphabet.length)]);
      }
      // Leading/trailing whitespace-only strings are dropped as empty.
      return b.toString().trim().isEmpty ? '' : b.toString();
    }

    List<SharedRow> rows() => [
          for (int i = 0; i < random.nextInt(6); i++)
            SharedRow(text(8), text(80)),
        ].where((r) => !r.isEmpty).toList();

    for (int i = 0; i < 60; i++) {
      test('random study #$i', () {
        final SharedStudy study = i.isEven
            ? SharedHomiletic(
                passage: text(30),
                contentSummaries: rows(),
                divisions: rows(),
                subjectSentence: text(120),
                fcf: text(120),
                aim: text(200),
                applications: [
                  for (int j = 0; j < random.nextInt(4); j++) text(100)
                ].where((s) => s.isNotEmpty).toList(),
                translation: random.nextBool() ? 'kjv' : null,
              )
            : SharedWordStudy(
                passage: text(30),
                word: text(20),
                definition: text(300),
                otherUsage: text(300),
                contextualMeaning: text(500),
                deeperMeaning: text(500),
                application: text(300),
              );
        final String link = ShareLink.encodeStudy(study);
        expect(decodeOk(link).toEnvelope(), equals(study.toEnvelope()));
      });
    }

    test('long text survives and compresses', () {
      final String long = List.generate(
          400,
          (i) => 'Verse $i: In the beginning was the Word — 太初有道。 '
              '🙏 ').join('\n');
      final SharedHomiletic study = SharedHomiletic(
          passage: 'John 1',
          subjectSentence: long,
          contentSummaries: [SharedRow('1-51', long)]);
      final String link = ShareLink.encodeStudy(study);
      expect(link.length, lessThan(utf8.encode(long).length));
      expect(decodeOk(link).toEnvelope(), equals(study.toEnvelope()));
    });
  });

  test('recognises share URIs', () {
    expect(ShareLink.isShareUri(Uri.parse('https://homiletics.app/view#h=x')),
        isTrue);
    expect(ShareLink.isShareUri(Uri.parse('homiletics://view#h=x')), isTrue);
    expect(ShareLink.isShareUri(Uri.parse('https://homiletics.app/#h=x')),
        isFalse);
    expect(
        ShareLink.isShareUri(Uri.parse('https://evil.app/view#h=x')), isFalse);
    expect(ShareLink.looksLikeShareLink('homiletics://view#w=abc'), isTrue);
    expect(ShareLink.looksLikeShareLink('John 3:16'), isFalse);
  });
}
