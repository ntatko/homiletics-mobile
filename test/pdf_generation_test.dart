import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:pdf/pdf.dart';

/// Builds sample handouts. Set PDF_PREVIEW_DIR to also write them to disk,
/// e.g. `PDF_PREVIEW_DIR=/tmp/pdf flutter test test/pdf_generation_test.dart`.
void main() {
  late HomileticPdfFonts fonts;

  setUpAll(() async {
    fonts = await HomileticPdfFonts.load((String path) async {
      final Uint8List bytes = await File(path).readAsBytes();
      return ByteData.sublistView(bytes);
    });
  });

  /// Writes [bytes] to PDF_PREVIEW_DIR/[name] when that is set.
  Future<Uint8List> preview(Uint8List bytes, String? name) async {
    final String? dir = Platform.environment['PDF_PREVIEW_DIR'];
    if (dir != null && name != null) {
      await Directory(dir).create(recursive: true);
      await File('$dir/$name').writeAsBytes(bytes);
    }
    return bytes;
  }

  Future<Uint8List> render(
    Homiletic h,
    List<ContentSummary> s,
    List<Division> d,
    List<Application> a, {
    PdfPageFormat format = PdfPageFormat.letter,
    String? previewName,
  }) async {
    return preview(
        await buildHomileticsDocument(h, s, d, a, fonts: fonts, format: format)
            .save(),
        previewName);
  }

  Future<Uint8List> renderWordStudy(
    WordStudy study, {
    PdfPageFormat format = PdfPageFormat.letter,
    String? previewName,
  }) async {
    return preview(
        await buildWordStudyDocument(study, fonts: fonts, format: format)
            .save(),
        previewName);
  }

  int pageCount(Uint8List bytes) => RegExp(r'/Type\s*/Page[^s]')
      .allMatches(String.fromCharCodes(bytes))
      .length;

  test('builds the Revelation 2:1–11 sample handout', () async {
    final Homiletic h = Homiletic(
      passage: 'Revelation 2:1–11',
      updatedAt: DateTime(2026, 10, 13, 9, 30),
      subjectSentence:
          'Christ commends Ephesus’s toil but calls them back to first love, '
          'and promises suffering Smyrna the crown of life.',
      fcf: 'Like Ephesus, we can keep busy defending the truth while our love '
          'for Christ quietly cools — and, like Smyrna, we fear what suffering '
          'will cost us.',
      aim: 'the risen Christ, who walks among His churches, sees both our '
          'labor and our love, and calls us to remember, repent, and be '
          'faithful unto death.',
    );
    final List<ContentSummary> summaries = [
      ContentSummary(
          homileticId: 1,
          passage: '2:1',
          summary: 'Jesus, holding the seven stars and walking among the '
              'golden lampstands, addresses the church in Ephesus.'),
      ContentSummary(
          homileticId: 1,
          passage: '2:2–3',
          summary: 'He knows their works, toil, and patient endurance; they '
              'cannot bear evil men and have tested false apostles.'),
      ContentSummary(
          homileticId: 1,
          passage: '2:4–5',
          summary: '“But I have this against you, that you have abandoned the '
              'love you had at first.” Remember, repent, and do the works you '
              'did at first — or the lampstand will be removed.'),
      ContentSummary(
          homileticId: 1,
          passage: '2:6–7',
          summary: 'They hate the works of the Nicolaitans; to the one who '
              'conquers Jesus will grant to eat of the tree of life '
              '(ξύλον τῆς ζωῆς).'),
      ContentSummary(
          homileticId: 1,
          passage: '2:8–9',
          summary: List<String>.filled(
                  28,
                  'To Smyrna, the First and the Last, who died and came to '
                  'life, says He knows their tribulation and poverty — yet '
                  'they are rich — and the slander of those who say they are '
                  'Jews and are not, but are a synagogue of Satan. ')
              .join()
              .trim()),
      ContentSummary(
          homileticId: 1,
          passage: '2:10–11',
          summary: 'Do not fear what you are about to suffer; be faithful '
              'unto death, and I will give you the crown of life. The one who '
              'conquers will not be hurt by the second death.'),
    ];
    final List<Division> divisions = [
      Division(1,
          passage: '2:1–7',
          title: 'Christ calls loveless Ephesus to remember and repent.'),
      Division(1,
          passage: '2:8–11',
          title: 'Christ calls suffering Smyrna to be faithful unto death.'),
    ];
    final List<Application> applications = [
      Application(
          homileticsId: 1,
          text: 'Where has my service for Christ outpaced my love for Him?'),
      Application(
          homileticsId: 1,
          text: 'What would it look like this week to “do the works I did at '
              'first”?'),
      Application(
          homileticsId: 1,
          text: 'What suffering am I afraid of, and how does the promise of '
              'the crown of life speak to that fear?'),
    ];

    final Uint8List letter = await render(h, summaries, divisions, applications,
        previewName: 'homiletic_sample.pdf');
    expect(String.fromCharCodes(letter.sublist(0, 5)), '%PDF-');
    expect(pageCount(letter), greaterThan(1),
        reason: 'the long summary should push content onto a second page');

    final Uint8List a4 = await render(h, summaries, divisions, applications,
        format: PdfPageFormat.a4, previewName: 'homiletic_sample_a4.pdf');
    expect(pageCount(a4), greaterThan(1));
  });

  test('handles empty and pathological input without crashing', () async {
    final Uint8List empty = await render(Homiletic(), [], [], [],
        previewName: 'homiletic_empty.pdf');
    expect(pageCount(empty), 1);

    final Homiletic h = Homiletic(
      passage: 'Ἐν ἀρχῇ ἦν ὁ λόγος · בְּרֵאשִׁית · 太初有道 · Иоанна 1:1 ' * 3,
      aim: 'x' * 5000, // one unbreakable "word"
      fcf: 'Line\n' * 200,
    );
    final List<ContentSummary> many = [
      for (int i = 0; i < 400; i++)
        ContentSummary(
            homileticId: 1, passage: '1:${i + 1}', summary: 'Verse ${i + 1} 🙏')
    ];
    final Uint8List stress = await render(
        h, many, [Division(1, passage: '1:1')], [Application(homileticsId: 1)],
        previewName: 'homiletic_stress.pdf');
    expect(pageCount(stress), greaterThan(5));
  });

  test('splitForPages keeps every character and bounds piece size', () {
    final String text = 'Alpha beta. ' * 300 + 'z' * 2000;
    final List<String> pieces = splitForPages(text);
    expect(pieces.every((p) => p.length <= 600), isTrue);
    expect(pieces.join().replaceAll(RegExp(r'\s'), ''),
        text.replaceAll(RegExp(r'\s'), ''));
    expect(splitForPages('short'), ['short']);
  });

  test('builds the Lampstand word study handout', () async {
    final WordStudy study = WordStudy(
      word: 'Lampstand',
      passage: 'Revelation 2:1–7',
      updatedAt: DateTime(2026, 10, 13, 9, 30),
      definition: 'A stand that holds up an oil lamp so its light reaches the '
          'whole room; in the tabernacle, the seven-branched golden stand '
          'that lit the Holy Place.',
      otherUsage: 'Matthew 5:15\nHebrews 9:2\n\nRevelation 11:4',
      contextualMeaning: 'Jesus Himself explains the image: “the seven '
          'lampstands are the seven churches” (1:20). Ephesus is a lampstand '
          '— a church whose purpose is to hold up the light of Christ in its '
          'city. To have the lampstand removed (2:5) is to cease to be a '
          'church at all, however busy it remains.',
      deeperMeaning: 'The Greek λυχνία (luchnia) is the stand, not the lamp '
          '(λύχνος) itself: the church does not produce the light, it bears '
          'it. The image reaches back to the menorah of Exodus 25 and to '
          'Zechariah 4, where the lampstand burns by the Spirit — “not by '
          'might, nor by power.”\n\nChrist walks among the lampstands (2:1), '
          'tending them as a priest tends the lamps of the Holy Place.',
      application: 'My church’s orthodoxy and hard work matter, but they are '
          'not the light. This week I will ask where love for Christ has '
          'cooled in me, and return to the “first works” of prayer and '
          'delight in Him before I take on anything new.',
    );

    final Uint8List letter =
        await renderWordStudy(study, previewName: 'word_study_sample.pdf');
    expect(String.fromCharCodes(letter.sublist(0, 5)), '%PDF-');
    expect(pageCount(letter), 1);

    final Uint8List a4 = await renderWordStudy(study,
        format: PdfPageFormat.a4, previewName: 'word_study_sample_a4.pdf');
    expect(pageCount(a4), 1);
  });

  test('word study: empty and very long input', () async {
    final Uint8List empty =
        await renderWordStudy(WordStudy(), previewName: 'word_study_empty.pdf');
    expect(pageCount(empty), 1);

    final Uint8List onlyWord = await renderWordStudy(
        WordStudy(word: 'Hesed', passage: '   '),
        previewName: 'word_study_word_only.pdf');
    expect(pageCount(onlyWord), 1);

    const String paragraph = 'The lampstand bears a light it did not make; '
        'its whole worth lies in holding that light up where others can see '
        'it, and in staying near the One who trims and fills it. ';
    final WordStudy long = WordStudy(
      word: 'Lampstand',
      passage: 'Revelation 2:1–7',
      updatedAt: DateTime(2026, 10, 13),
      definition: paragraph * 12,
      otherUsage: [
        for (int i = 1; i <= 60; i++)
          'Exodus 25:${i % 40 + 1} — the golden lampstand, verse $i'
      ].join('\n'),
      contextualMeaning: '${paragraph * 20}\n\n${paragraph * 8}',
      deeperMeaning: 'λυχνία ' * 400,
      application: 'x' * 4000, // one unbreakable "word"
    );
    final Uint8List bytes =
        await renderWordStudy(long, previewName: 'word_study_long.pdf');
    expect(pageCount(bytes), greaterThan(4));
  });
}
