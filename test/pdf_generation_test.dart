import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/l10n/generated/app_localizations_en.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/pdf_font_service.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:pdf/pdf.dart';

/// Chinese strings for the handout, used while the app has no generated
/// Chinese localization (the real one wins once it exists).
class _ChinesePdfStrings extends AppLocalizationsEn {
  _ChinesePdfStrings() : super('zh');
  @override
  String get pdfOverlineHomiletics => '讲道学';
  @override
  String get pdfUntitledPassage => '未命名经文';
  @override
  String pdfHomileticLabel(String passage) => '讲道学 · $passage';
  @override
  String pdfPageOf(int current, int total) => '第 $current 页，共 $total 页';
  @override
  String get pdfFcfCaption => '堕落光景焦点';
  @override
  String get pdfAimLeadIn => '使听众明白：';
  @override
  String get stepContent => '内容';
  @override
  String get stepDivisions => '分段';
  @override
  String get stepSummary => '摘要句';
  @override
  String get stepFcf => 'FCF';
  @override
  String get stepAim => '目标';
  @override
  String get stepApplication => '应用';
}

/// Spanish strings for the word study handout, likewise.
class _SpanishPdfStrings extends AppLocalizationsEn {
  _SpanishPdfStrings() : super('es');
  @override
  String get pdfOverlineWordStudy => 'ESTUDIO DE PALABRA';
  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) =>
      'Estudio de palabra · $word · $passage';
  @override
  String pdfPageOf(int current, int total) => 'página $current de $total';
  @override
  String get pdfWordStudyDefinition => 'Definición';
  @override
  String get pdfWordStudyOtherUsage => 'Otros usos';
  @override
  String get pdfWordStudyContextualMeaning => 'Significado en el contexto';
  @override
  String get pdfWordStudyDeeperMeaning => 'Significado más profundo';
  @override
  String get pdfWordStudyApplication => 'Aplicación';
}

/// The generated strings for [locale], or [fallback] if there are none yet.
AppLocalizations _strings(Locale locale, AppLocalizations Function() fallback) {
  try {
    return lookupAppLocalizations(locale);
  } catch (_) {
    return fallback();
  }
}

/// Builds sample handouts. Set PDF_PREVIEW_DIR to also write them to disk,
/// e.g. `PDF_PREVIEW_DIR=/tmp/pdf flutter test test/pdf_generation_test.dart`.
/// Set PDF_NOTO_DIR to a folder holding the downloaded Noto fonts (named as
/// in [PdfScriptFont.fileName]) to render Chinese and Arabic glyphs; without
/// it those cases check that the handout still builds, with boxes.
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
    AppLocalizations? strings,
    HomileticPdfFonts? withFonts,
  }) async {
    return preview(
        await buildHomileticsDocument(h, s, d, a,
                fonts: withFonts ?? fonts, format: format, strings: strings)
            .save(),
        previewName);
  }

  Future<Uint8List> renderWordStudy(
    WordStudy study, {
    PdfPageFormat format = PdfPageFormat.letter,
    String? previewName,
    AppLocalizations? strings,
    HomileticPdfFonts? withFonts,
  }) async {
    return preview(
        await buildWordStudyDocument(study,
                fonts: withFonts ?? fonts, format: format, strings: strings)
            .save(),
        previewName);
  }

  /// Reads script fonts from PDF_NOTO_DIR, or null when that isn't set.
  final String? notoDir = Platform.environment['PDF_NOTO_DIR'];
  Future<Uint8List> notoFromDisk(PdfScriptFont font) =>
      File('$notoDir/${font.fileName}').readAsBytes();
  bool hasNoto(PdfScriptFont font) =>
      notoDir != null && File('$notoDir/${font.fileName}').existsSync();

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

  test('English strings are unchanged', () {
    final AppLocalizations l = lookupAppLocalizations(const Locale('en'));
    expect(l.pdfPageOf(2, 3), 'page 2 of 3');
    expect(l.pdfHomileticLabel('John 1'), 'Homiletics · John 1');
    expect(l.pdfWordStudyLabelWithPassage('Logos', 'John 1:1'),
        'Word study · Logos · John 1:1');
  });

  test('scriptFontsFor picks fonts by script', () {
    expect(scriptFontsFor(['Revelation 2:1 · ξύλον · Иоанна']), isEmpty);
    expect(scriptFontsFor(['太初有道']), {PdfScriptFont.chineseSimplified});
    expect(scriptFontsFor(['太初有道'], preferTraditional: true),
        {PdfScriptFont.chineseTraditional});
    expect(scriptFontsFor(['في البدء كان الكلمة', '道']),
        {PdfScriptFont.chineseSimplified, PdfScriptFont.arabic});
  });

  final Homiletic chineseHomiletic = Homiletic(
    passage: '约翰福音 1:1–14',
    updatedAt: DateTime(2026, 10, 13, 9, 30),
    subjectSentence: '道成了肉身，住在我们中间，充充满满地有恩典有真理。',
    fcf: '我们常常像那些不认识祂的人一样，宁爱黑暗，倒不爱光。',
    aim: '永恒的道成为人，使凡接待祂的人有权柄作神的儿女。',
  );
  final List<ContentSummary> chineseSummaries = [
    ContentSummary(
        homileticId: 1, passage: '1:1–5', summary: '太初有道，道与神同在，道就是神。'),
    ContentSummary(
        homileticId: 1,
        passage: '1:6–13',
        summary: '有一个人，是从神那里差来的，名叫约翰。凡接待祂的，就是信祂名的人，'
                '祂就赐他们权柄，作神的儿女。' *
            6),
    ContentSummary(
        homileticId: 1,
        passage: '1:14',
        summary: '道成了肉身，住在我们中间。Mixed English 与 العربية text.'),
  ];
  final List<Division> chineseDivisions = [
    Division(1, passage: '1:1–5', title: '永恒的道'),
    Division(1, passage: '1:6–14', title: '道成肉身'),
  ];
  final List<Application> chineseApplications = [
    Application(homileticsId: 1, text: '我今天怎样接待基督，而不是拒绝祂？'),
  ];

  test('Chinese homiletic builds even without a CJK font (boxes)', () async {
    final AppLocalizations zh = _strings(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        _ChinesePdfStrings.new);
    final HomileticPdfFonts offline = await withScriptFallbacks(
        fonts,
        homileticPdfTexts(chineseHomiletic, chineseSummaries, chineseDivisions,
            chineseApplications, zh),
        load: (PdfScriptFont font) async =>
            throw const SocketException('offline'));
    expect(offline.fallback.length, fonts.fallback.length);
    final Uint8List bytes = await render(chineseHomiletic, chineseSummaries,
        chineseDivisions, chineseApplications,
        strings: zh, withFonts: offline);
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
  });

  test('Chinese homiletic renders with Noto Sans SC', () async {
    if (!hasNoto(PdfScriptFont.chineseSimplified)) {
      markTestSkipped('Set PDF_NOTO_DIR to a folder with '
          '${PdfScriptFont.chineseSimplified.fileName} to run this.');
      return;
    }
    final AppLocalizations zh = _strings(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        _ChinesePdfStrings.new);
    final HomileticPdfFonts withCjk = await withScriptFallbacks(
        fonts,
        homileticPdfTexts(chineseHomiletic, chineseSummaries, chineseDivisions,
            chineseApplications, zh),
        load: (PdfScriptFont font) async => hasNoto(font)
            ? notoFromDisk(font)
            : throw FileSystemException('missing', font.fileName));
    expect(withCjk.fallback.length, greaterThan(fonts.fallback.length));
    final Uint8List bytes = await render(chineseHomiletic, chineseSummaries,
        chineseDivisions, chineseApplications,
        strings: zh, withFonts: withCjk, previewName: 'homiletic_zh.pdf');
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
  });

  test('Spanish word study renders', () async {
    final AppLocalizations es =
        _strings(const Locale('es'), _SpanishPdfStrings.new);
    final WordStudy study = WordStudy(
      word: 'Candelero',
      passage: 'Apocalipsis 2:1–7',
      updatedAt: DateTime(2026, 10, 13, 9, 30),
      definition: 'Soporte que sostiene una lámpara de aceite para que su luz '
          'alcance toda la habitación; en el tabernáculo, el candelero de oro '
          'de siete brazos que iluminaba el Lugar Santo.',
      otherUsage: 'Mateo 5:15\nHebreos 9:2\nApocalipsis 11:4',
      contextualMeaning: 'Jesús mismo explica la imagen: «los siete '
          'candeleros son las siete iglesias» (1:20). ¿Qué significa que se '
          'quite el candelero? Dejar de ser iglesia, por ocupada que esté.',
      deeperMeaning: 'El griego λυχνία es el soporte, no la lámpara: la '
          'iglesia no produce la luz, la sostiene. (Chino: 灯台.)',
      application: 'Esta semana volveré a las «primeras obras» de oración y '
          'deleite en Él antes de emprender algo nuevo. Ñandú, pingüino.',
    );
    final HomileticPdfFonts withFonts = await withScriptFallbacks(
        fonts, wordStudyPdfTexts(study, es),
        load: (PdfScriptFont font) async => hasNoto(font)
            ? notoFromDisk(font)
            : throw FileSystemException('missing', font.fileName));
    final Uint8List bytes = await renderWordStudy(study,
        strings: es, withFonts: withFonts, previewName: 'word_study_es.pdf');
    expect(pageCount(bytes), 1);
  });

  test('Arabic text renders with Noto Naskh Arabic', () async {
    if (!hasNoto(PdfScriptFont.arabic)) {
      markTestSkipped('Set PDF_NOTO_DIR to a folder with '
          '${PdfScriptFont.arabic.fileName} to run this.');
      return;
    }
    final WordStudy study = WordStudy(
        word: 'الكلمة',
        passage: 'يوحنا 1:1',
        definition: 'في البدء كان الكلمة، والكلمة كان عند الله.');
    final HomileticPdfFonts withArabic = await withScriptFallbacks(fonts,
        wordStudyPdfTexts(study, lookupAppLocalizations(const Locale('en'))),
        load: notoFromDisk);
    expect(withArabic.fallback.length, fonts.fallback.length + 1);
    await renderWordStudy(study,
        withFonts: withArabic, previewName: 'word_study_ar.pdf');
  });
}
