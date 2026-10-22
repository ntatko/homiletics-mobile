import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/pdf_font_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

export 'package:homiletics/services/pdf_font_service.dart' show PdfScriptFont;

/// The fonts a homiletic handout is set in: Newsreader for the passage,
/// headings and statements; Public Sans for labels and body text; and a
/// broad-coverage fallback (Ubuntu, which carries Greek and Cyrillic) for
/// characters neither family has. Anything still missing renders as a
/// placeholder box rather than failing.
class HomileticPdfFonts {
  final pw.Font serif;
  final pw.Font serifItalic;
  final pw.Font serifMedium;
  final pw.Font serifSemiBold;
  final pw.Font sans;
  final pw.Font sansItalic;
  final pw.Font sansMedium;
  final pw.Font sansSemiBold;
  final pw.Font sansBold;
  final List<pw.Font> fallback;

  const HomileticPdfFonts({
    required this.serif,
    required this.serifItalic,
    required this.serifMedium,
    required this.serifSemiBold,
    required this.sans,
    required this.sansItalic,
    required this.sansMedium,
    required this.sansSemiBold,
    required this.sansBold,
    this.fallback = const [],
  });

  /// These fonts with [extra] appended to [fallback].
  HomileticPdfFonts withFallback(List<pw.Font> extra) {
    if (extra.isEmpty) return this;
    return HomileticPdfFonts(
      serif: serif,
      serifItalic: serifItalic,
      serifMedium: serifMedium,
      serifSemiBold: serifSemiBold,
      sans: sans,
      sansItalic: sansItalic,
      sansMedium: sansMedium,
      sansSemiBold: sansSemiBold,
      sansBold: sansBold,
      fallback: [...fallback, ...extra],
    );
  }

  /// Loads the bundled fonts through [loadAsset], which receives an asset
  /// path such as `assets/fonts/Newsreader-Regular.ttf` (pass
  /// `rootBundle.load` in the app, or a file reader in tests).
  static Future<HomileticPdfFonts> load(
      Future<ByteData> Function(String path) loadAsset) async {
    Future<pw.Font> font(String name) async =>
        pw.Font.ttf(_padded(await loadAsset('assets/fonts/$name.ttf')));

    final List<pw.Font> fonts = await Future.wait([
      font('Newsreader-Regular'),
      font('Newsreader-Italic'),
      font('Newsreader-Medium'),
      font('Newsreader-SemiBold'),
      font('PublicSans-Regular'),
      font('PublicSans-Italic'),
      font('PublicSans-Medium'),
      font('PublicSans-SemiBold'),
      font('PublicSans-Bold'),
      font('Ubuntu-Regular'),
    ]);
    return HomileticPdfFonts(
      serif: fonts[0],
      serifItalic: fonts[1],
      serifMedium: fonts[2],
      serifSemiBold: fonts[3],
      sans: fonts[4],
      sansItalic: fonts[5],
      sansMedium: fonts[6],
      sansSemiBold: fonts[7],
      sansBold: fonts[8],
      fallback: [fonts[9]],
    );
  }
}

/// Returns [data] with a few zero bytes appended.
///
/// Also applied to the downloaded Noto fonts: they don't need it today, but
/// it costs one copy and guards against a future build of them laying out
/// their glyphs the same way.
///
/// The pdf package always embeds the glyph for U+0000 and reads a glyph
/// header (12 bytes) even when the glyph is empty. Public Sans and Ubuntu
/// map U+0000 to an empty glyph stored at the very end of the file, so that
/// read runs past the end and throws a RangeError on save. The padding turns
/// it into a harmless zero-contour glyph; TrueType readers ignore trailing
/// bytes.
ByteData _padded(ByteData data) {
  final Uint8List bytes = Uint8List(data.lengthInBytes + 32)
    ..setRange(0, data.lengthInBytes,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  return ByteData.sublistView(bytes);
}

Future<HomileticPdfFonts>? _bundledFonts;

/// The app's fonts, loaded once and reused for every export.
Future<HomileticPdfFonts> _loadBundledFonts() {
  return _bundledFonts ??=
      HomileticPdfFonts.load(rootBundle.load).catchError((Object error) {
    _bundledFonts = null; // Let the next export try again.
    throw error;
  });
}

/// Loads the bytes of a script font; [PdfFontService.load] in the app.
typedef ScriptFontLoader = Future<Uint8List> Function(PdfScriptFont font);

final Map<PdfScriptFont, Future<pw.Font?>> _scriptFonts = {};

Future<pw.Font?> _parseScriptFont(
    PdfScriptFont script, ScriptFontLoader load) async {
  try {
    final Uint8List bytes = await load(script);
    return pw.Font.ttf(_padded(ByteData.sublistView(bytes)));
  } catch (error) {
    debugPrint('PDF font ${script.family} unavailable: $error');
    return null;
  }
}

/// [fonts] plus fallbacks for any CJK or Arabic characters in [texts] (the
/// handout's content and its localized labels). Missing fonts are loaded
/// through [load] (by default downloaded once by [PdfFontService]); a font
/// that can't be had is skipped, so those characters print as boxes rather
/// than the export failing. Parsed fonts are kept for later exports when
/// [load] is the default.
Future<HomileticPdfFonts> withScriptFallbacks(
  HomileticPdfFonts fonts,
  Iterable<String> texts, {
  Locale? locale,
  ScriptFontLoader? load,
}) async {
  final Set<PdfScriptFont> needed = scriptFontsFor(texts,
      preferTraditional: locale?.languageCode == 'zh' &&
          (locale?.scriptCode == 'Hant' ||
              const {'TW', 'HK', 'MO'}.contains(locale?.countryCode)));
  if (needed.isEmpty) return fonts;

  Future<pw.Font?> get(PdfScriptFont script) {
    if (load != null) return _parseScriptFont(script, load);
    return _scriptFonts[script] ??=
        _parseScriptFont(script, PdfFontService.load).then((pw.Font? font) {
      if (font == null) {
        // Try again next time (the device may be back online), and drop a
        // stored file that didn't parse.
        _scriptFonts.remove(script);
        PdfFontService.delete(script).catchError((_) {});
      }
      return font;
    });
  }

  final List<pw.Font?> loaded = await Future.wait(needed.map(get));
  return fonts.withFallback(loaded.whereType<pw.Font>().toList());
}

/// English strings, for callers that don't pass any.
AppLocalizations get _english => lookupAppLocalizations(const Locale('en'));

/// The app's current interface language, falling back to English for a
/// language that has no generated strings yet.
(AppLocalizations, Locale) _appStrings() {
  final Locale locale = Preferences.effectiveLanguage.locale;
  try {
    return (lookupAppLocalizations(locale), locale);
  } catch (_) {
    return (_english, const Locale('en'));
  }
}

PdfColor _pdf(Color color) => PdfColor.fromInt(color.toARGB32());

/// Print-safe colors, taken from the light "Scripture Desk" palette.
class _Palette {
  static const AppColors _c = AppColors.light;
  static final PdfColor ink = _pdf(_c.ink);
  static final PdfColor muted = _pdf(_c.muted);
  static final PdfColor line = _pdf(_c.line);
  static final PdfColor lineStrong = _pdf(_c.lineStrong);
  static final PdfColor accent = _pdf(_c.accent);
  static final PdfColor onAccent = _pdf(_c.onAccent);
  static PdfColor step(StudyStep s) => _pdf(_c.stepColors[s.index]);
  static PdfColor tint(StudyStep s) => _pdf(_c.stepTints[s.index]);
}

bool _dateSymbolsLoaded = false;

/// The intl locale to format dates for [l]'s language: Traditional Chinese
/// uses Taiwan's conventions, and an unknown locale falls back to its
/// language, then English.
String _dateLocale(AppLocalizations l) {
  if (!_dateSymbolsLoaded) {
    // Fills intl's tables synchronously; the Future is already done.
    initializeDateFormatting();
    _dateSymbolsLoaded = true;
  }
  final String name = l.localeName;
  final String language = name.split(RegExp('[_-]')).first;
  final List<String> candidates = [
    if (language == 'zh' && name.contains('Hant')) 'zh_TW',
    name,
    language,
  ];
  for (final String candidate in candidates) {
    if (DateFormat.localeExists(candidate)) return candidate;
  }
  return 'en';
}

/// [date] as a long date ("October 13, 2026" in English).
String _formatDate(DateTime date, AppLocalizations l) =>
    DateFormat.yMMMMd(_dateLocale(l)).format(date.toLocal());

/// How a handout is set.
enum HandoutLayout {
  /// A printable page (Letter, A4, ...), set compactly.
  page,

  /// Square images for a social media feed: larger type on a 540pt square
  /// (1080px at 144 dpi), one image per page.
  square,
}

/// The square page that [HandoutLayout.square] images are laid out on.
const PdfPageFormat squareImageFormat = PdfPageFormat(540, 540);

/// The resolution [HandoutLayout.square] pages are rasterized at, making
/// them 1080px square.
const double squareImageDpi = 144;

final RegExp _token = RegExp(r'\S+\s*|\s+');
final RegExp _sentenceEnd = RegExp(r'[.!?;:”"]\s*$');

/// Splits [text] into pieces small enough that each fits on one page, so
/// that a very long entry paginates instead of overflowing. Breaks prefer
/// sentence ends and line breaks; a single enormous word is hard-split.
/// Runs in linear time.
List<String> splitForPages(String text,
    {int maxChars = 600, int maxLines = 10}) {
  if (text.length <= maxChars && '\n'.allMatches(text).length < maxLines) {
    return [text];
  }
  final List<String> pieces = [];
  final StringBuffer buffer = StringBuffer();
  int lines = 0;

  void flush() {
    final String piece = buffer.toString().trimRight();
    if (piece.isNotEmpty) pieces.add(piece);
    buffer.clear();
    lines = 0;
  }

  for (final Match match in _token.allMatches(text)) {
    String token = match[0]!;
    while (token.length > maxChars) {
      flush();
      pieces.add(token.substring(0, maxChars));
      token = token.substring(maxChars);
    }
    if (buffer.length + token.length > maxChars) flush();
    buffer.write(token);
    final int newlines = '\n'.allMatches(token).length;
    lines += newlines;
    final bool breakable = newlines > 0 || _sentenceEnd.hasMatch(token);
    if (lines >= maxLines || (breakable && buffer.length > maxChars * 0.5)) {
      flush();
    }
  }
  flush();
  return pieces.isEmpty ? [text.trim()] : pieces;
}

/// Lays out a homiletic as a printable handout. Pure: no platform channels,
/// so it can be built in tests with fonts read from disk.
pw.Document buildHomileticsDocument(
  Homiletic homiletic,
  List<ContentSummary> summaries,
  List<Division> divisions,
  List<Application> applications, {
  required HomileticPdfFonts fonts,
  PdfPageFormat? format,
  HandoutLayout layout = HandoutLayout.page,
  AppLocalizations? strings,
}) {
  final AppLocalizations l = strings ?? _english;
  final String passage = homiletic.passage.trim();
  final String title = passage.isEmpty ? l.pdfUntitledPassage : passage;
  final _Styles styles = _Styles(fonts, l, layout);
  final String label = l.pdfHomileticLabel(title);

  final pw.Document doc = pw.Document(
    title: label,
    creator: 'Homiletics',
    producer: 'Homiletics',
  );

  // The study's two halves, which are separate square images: the passage
  // (Content and Divisions), then the message (Summary to Application).
  final List<pw.Widget> passageHalf = [];
  final List<pw.Widget> messageHalf = [];

  final List<(String, String)> contentRows = [
    for (final ContentSummary s in summaries)
      if (s.summary.trim().isNotEmpty || s.passage.trim().isNotEmpty)
        (s.passage.trim(), s.summary.trim())
  ];
  if (contentRows.isNotEmpty) {
    passageHalf.addAll(_rowSection(StudyStep.content, 1, contentRows, styles));
  }

  final List<(String, String)> divisionRows = [
    for (final Division d in divisions)
      if (d.title.trim().isNotEmpty || d.passage.trim().isNotEmpty)
        (d.passage.trim(), d.title.trim())
  ];
  if (divisionRows.isNotEmpty) {
    passageHalf
        .addAll(_rowSection(StudyStep.divisions, 2, divisionRows, styles));
  }

  if (homiletic.subjectSentence.trim().isNotEmpty) {
    messageHalf.addAll(_statementSection(
        StudyStep.summary, 3, homiletic.subjectSentence.trim(), styles));
  }
  if (homiletic.fcf.trim().isNotEmpty) {
    messageHalf.addAll(_statementSection(
        StudyStep.fcf, 4, homiletic.fcf.trim(), styles,
        caption: l.pdfFcfCaption));
  }
  if (homiletic.aim.trim().isNotEmpty) {
    messageHalf.addAll(_statementSection(
        StudyStep.aim, 5, homiletic.aim.trim(), styles,
        leadIn: l.pdfAimLeadIn));
  }

  final List<String> questions = [
    for (final Application a in applications)
      if (a.text.trim().isNotEmpty) a.text.trim()
  ];
  if (questions.isNotEmpty) {
    messageHalf.addAll(_rowSection(
      StudyStep.application,
      6,
      [for (final (int i, String q) in questions.indexed) ('${i + 1}', q)],
      styles,
      labelWidth: styles.numberLabelWidth,
    ));
  }

  _addPages(
      doc,
      _header(l.pdfOverlineHomiletics, title, styles,
          updatedAt: homiletic.updatedAt),
      [passageHalf, messageHalf],
      _emptyNote(l.pdfEmptyHomiletic, styles),
      fonts,
      styles,
      format,
      label,
      title);
  return doc;
}

/// Lays out a word study as a printable handout, in the same style as
/// [buildHomileticsDocument]. Pure, like it.
pw.Document buildWordStudyDocument(
  WordStudy study, {
  required HomileticPdfFonts fonts,
  PdfPageFormat? format,
  HandoutLayout layout = HandoutLayout.page,
  AppLocalizations? strings,
}) {
  final AppLocalizations l = strings ?? _english;
  final String word = study.word.trim();
  final String passage = study.passage.trim();
  final String title = word.isEmpty ? l.pdfUntitledWord : word;
  final _Styles styles = _Styles(fonts, l, layout);
  final String label = passage.isEmpty
      ? l.pdfWordStudyLabel(title)
      : l.pdfWordStudyLabelWithPassage(title, passage);

  final pw.Document doc = pw.Document(
    title: label,
    creator: 'Homiletics',
    producer: 'Homiletics',
  );

  // The study's two halves, which are separate square images: the word
  // (Definition and Other usage), then what it means here.
  final List<pw.Widget> wordHalf = [];
  final List<pw.Widget> meaningHalf = [];

  void prose(List<pw.Widget> body, String title, StudyStep step, String text) {
    if (text.trim().isEmpty) return;
    body.addAll(_withHeading(
        _sectionHeading(step, title, styles, top: styles.wordStudyGap),
        _tintedBlocks(step, text.trim(), styles.body, styles)));
  }

  final String definition = study.definition.trim();
  final List<String> usages = [
    for (final String line in study.otherUsage.split('\n'))
      if (line.trim().isNotEmpty) line.trim()
  ];
  // Like the editor, short Definition and Other usage sit side by side;
  // anything longer is stacked so it can run across pages. A square image
  // is too narrow for two columns.
  final bool sideBySide = layout == HandoutLayout.page &&
      definition.isNotEmpty &&
      usages.isNotEmpty &&
      definition.length <= 420 &&
      '\n'.allMatches(definition).length < 6 &&
      usages.length <= 10 &&
      usages.every((String line) => line.length <= 70);
  if (sideBySide) {
    wordHalf.add(_definitionAndUsage(definition, usages, styles));
  } else {
    prose(
        wordHalf, l.pdfWordStudyDefinition, StudyStep.application, definition);
    if (usages.isNotEmpty) {
      wordHalf.addAll(_withHeading(
          _sectionHeading(StudyStep.summary, l.pdfWordStudyOtherUsage, styles,
              top: styles.wordStudyGap),
          _usageList(StudyStep.summary, usages, styles)));
    }
  }

  prose(meaningHalf, l.pdfWordStudyContextualMeaning, StudyStep.fcf,
      study.contextualMeaning);
  prose(meaningHalf, l.pdfWordStudyDeeperMeaning, StudyStep.divisions,
      study.deeperMeaning);
  prose(
      meaningHalf, l.pdfWordStudyApplication, StudyStep.aim, study.application);

  _addPages(
      doc,
      _header(l.pdfOverlineWordStudy, title, styles,
          subtitle: passage.isEmpty ? null : passage,
          updatedAt: study.updatedAt),
      [wordHalf, meaningHalf],
      _emptyNote(l.pdfEmptyWordStudy, styles),
      fonts,
      styles,
      format,
      label,
      title);
  return doc;
}

/// Adds a handout's pages to [doc]: [header], then the [halves] of the
/// study, or [emptyNote] when there's nothing in them.
///
/// A printed handout runs everything together across as many pages as it
/// takes. Square images put each half on its own image (the header with the
/// first) and shrink a half that doesn't fit, so every image in a feed is
/// complete; a half that's empty is left out.
void _addPages(
  pw.Document doc,
  pw.Widget header,
  List<List<pw.Widget>> halves,
  pw.Widget emptyNote,
  HomileticPdfFonts fonts,
  _Styles styles,
  PdfPageFormat? format,
  String footerLabel,
  String title,
) {
  final bool square = styles.layout == HandoutLayout.square;
  final pw.PageTheme theme = pw.PageTheme(
    pageFormat: format ?? (square ? squareImageFormat : PdfPageFormat.letter),
    margin: square
        ? const pw.EdgeInsets.fromLTRB(34, 30, 34, 20)
        : const pw.EdgeInsets.fromLTRB(42, 36, 42, 26),
    theme: pw.ThemeData.withFont(
      base: fonts.sans,
      bold: fonts.sansBold,
      italic: fonts.sansItalic,
      boldItalic: fonts.sansBold,
      fontFallback: fonts.fallback,
    ),
  );
  final List<List<pw.Widget>> filled = [
    for (final List<pw.Widget> half in halves)
      if (half.isNotEmpty) half
  ];
  if (filled.isEmpty) filled.add([emptyNote]);

  if (!square) {
    doc.addPage(pw.MultiPage(
      pageTheme: theme,
      maxPages: 500,
      footer: (pw.Context context) =>
          _footer(context.pageNumber, context.pagesCount, footerLabel, styles),
      build: (pw.Context context) =>
          [header, for (final List<pw.Widget> half in filled) ...half],
    ));
    return;
  }

  for (final (int i, List<pw.Widget> half) in filled.indexed) {
    final List<pw.Widget> children = [
      if (i == 0)
        header
      else
        // Later images repeat the title, so each stands on its own.
        pw.Text(title.toUpperCase(), style: styles.overline, maxLines: 1),
      ...half,
    ];
    doc.addPage(pw.Page(
      pageTheme: theme,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.LayoutBuilder(
              builder: (pw.Context context, pw.BoxConstraints? box) =>
                  pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.topLeft,
                child: pw.SizedBox(
                  width: box!.maxWidth,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
          _footer(i + 1, filled.length, footerLabel, styles),
        ],
      ),
    ));
  }
}

pw.Widget _emptyNote(String text, _Styles styles) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(top: styles.sectionTop),
    child: pw.Text(text, style: styles.statementLead),
  );
}

class _Styles {
  factory _Styles(
      HomileticPdfFonts f, AppLocalizations strings, HandoutLayout layout) {
    final bool square = layout == HandoutLayout.square;
    // Type sizes: [s] picks the page size or the square image's.
    double s(double page, double image) => square ? image : page;
    return _Styles._(
      strings: strings,
      layout: layout,
      overline: pw.TextStyle(
          font: f.sansSemiBold,
          fontSize: s(7.5, 9),
          letterSpacing: 1.6,
          color: _Palette.accent),
      passage: pw.TextStyle(
          font: f.serifMedium,
          fontSize: s(22, 26),
          lineSpacing: 1.5,
          color: _Palette.ink),
      date: pw.TextStyle(
          font: f.sans, fontSize: s(8.5, 10), color: _Palette.muted),
      number: pw.TextStyle(
          font: f.sansBold, fontSize: s(7.5, 9.5), color: _Palette.onAccent),
      sectionTitle: pw.TextStyle(
          font: f.serifSemiBold, fontSize: s(13, 16), color: _Palette.ink),
      caption: pw.TextStyle(
          font: f.serifItalic, fontSize: s(9.5, 11.5), color: _Palette.muted),
      rowLabel: pw.TextStyle(font: f.serifSemiBold, fontSize: s(10, 13)),
      rowText: pw.TextStyle(
          font: f.sans,
          fontSize: s(10, 13),
          lineSpacing: s(2.5, 3.5),
          color: _Palette.ink),
      body: pw.TextStyle(
          font: f.sans,
          fontSize: s(10.25, 13),
          lineSpacing: s(2.5, 3.5),
          color: _Palette.ink),
      reference: pw.TextStyle(
          font: f.sansSemiBold, fontSize: s(10.25, 13), color: _Palette.ink),
      subtitle: pw.TextStyle(
          font: f.serifItalic, fontSize: s(11, 14), color: _Palette.muted),
      statement: pw.TextStyle(
          font: f.serif,
          fontSize: s(11.5, 15),
          lineSpacing: s(3, 4),
          color: _Palette.ink),
      statementLead: pw.TextStyle(
          font: f.serifItalic,
          fontSize: s(11.5, 15),
          lineSpacing: s(3, 4),
          color: _Palette.muted),
      footer: pw.TextStyle(
          font: f.sans, fontSize: s(7.5, 9.5), color: _Palette.muted),
      sectionTop: s(14, 16),
      wordStudyGap: s(12, 14),
      markerSize: s(16, 20),
      rowPadding: s(4, 5),
      labelWidth: s(56, 66),
      numberLabelWidth: s(18, 22),
      tintPadding: square
          ? const pw.EdgeInsets.fromLTRB(12, 9, 12, 10)
          : const pw.EdgeInsets.fromLTRB(10, 6, 10, 7),
      maxPieceChars: square ? 420 : 600,
    );
  }

  const _Styles._({
    required this.strings,
    required this.layout,
    required this.overline,
    required this.passage,
    required this.date,
    required this.number,
    required this.sectionTitle,
    required this.caption,
    required this.rowLabel,
    required this.rowText,
    required this.body,
    required this.reference,
    required this.subtitle,
    required this.statement,
    required this.statementLead,
    required this.footer,
    required this.sectionTop,
    required this.wordStudyGap,
    required this.markerSize,
    required this.rowPadding,
    required this.labelWidth,
    required this.numberLabelWidth,
    required this.tintPadding,
    required this.maxPieceChars,
  });

  /// The handout's language.
  final AppLocalizations strings;
  final HandoutLayout layout;

  final pw.TextStyle overline;
  final pw.TextStyle passage;
  final pw.TextStyle date;
  final pw.TextStyle number;
  final pw.TextStyle sectionTitle;
  final pw.TextStyle caption;
  final pw.TextStyle rowLabel;
  final pw.TextStyle rowText;
  final pw.TextStyle body;
  final pw.TextStyle reference;
  final pw.TextStyle subtitle;
  final pw.TextStyle statement;
  final pw.TextStyle statementLead;
  final pw.TextStyle footer;

  /// Space above a homiletic section heading.
  final double sectionTop;

  /// Space above a word study section heading.
  final double wordStudyGap;

  /// The diameter of a homiletic step's numbered circle.
  final double markerSize;

  /// Space above and below each row's text.
  final double rowPadding;

  /// The label column of a row section (passage references).
  final double labelWidth;

  /// The label column of the numbered application questions.
  final double numberLabelWidth;

  /// Padding inside a tinted block.
  final pw.EdgeInsets tintPadding;

  /// The longest piece [splitForPages] cuts long text into.
  final int maxPieceChars;

  /// [text] in pieces that each fit on one page.
  List<String> split(String text) =>
      splitForPages(text, maxChars: maxPieceChars);
}

/// The title block: a small accent [overline], the [title] large in serif
/// with the date across from it, then a rule with the [subtitle] (if any)
/// beneath it.
pw.Widget _header(String overline, String title, _Styles styles,
    {String? subtitle, DateTime? updatedAt}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(overline, style: styles.overline),
      pw.SizedBox(height: 3),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(child: pw.Text(title, style: styles.passage)),
          if (updatedAt != null) ...[
            pw.SizedBox(width: 12),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(_formatDate(updatedAt, styles.strings),
                  style: styles.date),
            ),
          ],
        ],
      ),
      pw.SizedBox(height: 6),
      pw.Container(height: 0.75, color: _Palette.lineStrong),
      if (subtitle != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(subtitle, style: styles.subtitle),
      ],
    ],
  );
}

/// The numbered circle that marks a homiletic step.
pw.Widget _numberMarker(StudyStep step, int number, _Styles styles) {
  return pw.Container(
    width: styles.markerSize,
    height: styles.markerSize,
    alignment: pw.Alignment.center,
    decoration:
        pw.BoxDecoration(color: _Palette.step(step), shape: pw.BoxShape.circle),
    child: pw.Text('$number', style: styles.number),
  );
}

/// The small rounded square that marks a word study section.
pw.Widget _squareMarker(StudyStep step) {
  return pw.Container(
    width: 9,
    height: 9,
    margin: const pw.EdgeInsets.only(left: 1, right: 1, top: 1),
    decoration: pw.BoxDecoration(
        color: _Palette.step(step),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
  );
}

/// A section heading: [step]'s marker (a numbered circle when [number] is
/// given, otherwise a small square) and [title] (default: the step's
/// localized name).
pw.Widget _sectionHeading(StudyStep step, String? title, _Styles styles,
    {int? number, String? caption, double? top}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(top: top ?? styles.sectionTop, bottom: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (number != null)
          _numberMarker(step, number, styles)
        else
          _squareMarker(step),
        pw.SizedBox(width: number != null ? 9 : 8),
        pw.Text(title ?? step.localizedLabel(styles.strings),
            style: styles.sectionTitle),
        if (caption != null) ...[
          pw.SizedBox(width: 8),
          pw.Text(caption, style: styles.caption),
        ],
      ],
    ),
  );
}

/// A section heading glued to its first row. A bare Column can span pages in
/// a MultiPage, which would strand the heading at the bottom of a page.
pw.Widget _keepTogether(pw.Widget heading, pw.Widget first) {
  return pw.Inseparable(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [heading, first],
    ),
  );
}

/// [blocks] with [heading] glued to the first of them.
List<pw.Widget> _withHeading(pw.Widget heading, List<pw.Widget> blocks) {
  if (blocks.isEmpty) return [heading];
  return [_keepTogether(heading, blocks.first), ...blocks.skip(1)];
}

/// A numbered section of (label, text) rows: a fixed label column in the
/// step color and wrapping body text, separated by hairlines. Each row is
/// split into page-sized pieces; the heading travels with the first piece.
List<pw.Widget> _rowSection(
  StudyStep step,
  int number,
  List<(String, String)> rows,
  _Styles styles, {
  double? labelWidth,
}) {
  final pw.TextStyle labelStyle =
      styles.rowLabel.copyWith(color: _Palette.step(step));
  final pw.TextStyle emptyStyle =
      styles.rowText.copyWith(color: _Palette.muted);
  final List<pw.Widget> out = [];

  for (final (int r, (String label, String text)) in rows.indexed) {
    final List<String> pieces = text.isEmpty ? const ['—'] : styles.split(text);
    final bool lastRow = r == rows.length - 1;
    for (final (int p, String piece) in pieces.indexed) {
      final bool lastPiece = p == pieces.length - 1;
      final pw.Widget row = pw.Container(
        // Continuation pieces keep the paragraph's line rhythm.
        padding: pw.EdgeInsets.only(
            top: p == 0 ? styles.rowPadding : styles.rowText.lineSpacing!,
            bottom: lastPiece ? styles.rowPadding : 0),
        decoration: lastPiece && !lastRow
            ? pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: _Palette.line, width: 0.6)))
            : null,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: labelWidth ?? styles.labelWidth,
              child: p == 0 && label.isNotEmpty
                  ? pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 8),
                      child: pw.Text(label, style: labelStyle))
                  : null,
            ),
            pw.Expanded(
              child: pw.Text(piece,
                  style: text.isEmpty ? emptyStyle : styles.rowText),
            ),
          ],
        ),
      );
      out.add(out.isEmpty
          ? _keepTogether(
              _sectionHeading(step, null, styles, number: number), row)
          : row);
    }
  }
  return out;
}

/// A numbered section holding one sentence, set in serif on a pale tint of
/// the step color with a colored rule on the left.
List<pw.Widget> _statementSection(
  StudyStep step,
  int number,
  String text,
  _Styles styles, {
  String? caption,
  String? leadIn,
}) {
  return _withHeading(
    _sectionHeading(step, null, styles, number: number, caption: caption),
    _tintedBlocks(step, text, styles.statement, styles,
        lead: leadIn == null
            ? null
            : pw.TextSpan(text: leadIn, style: styles.statementLead)),
  );
}

/// [text] set in [style] on a pale tint of the step color with a colored
/// rule on the left, split into page-sized pieces that stack seamlessly.
/// [lead] is set inline before the first piece.
List<pw.Widget> _tintedBlocks(
  StudyStep step,
  String text,
  pw.TextStyle style,
  _Styles styles, {
  pw.InlineSpan? lead,
}) {
  final pw.EdgeInsets padding = styles.tintPadding;
  final List<String> pieces = styles.split(text);
  return [
    for (final (int i, String piece) in pieces.indexed)
      _tintedBox(
        step,
        pw.RichText(
          text: pw.TextSpan(children: [
            if (i == 0 && lead != null) lead,
            pw.TextSpan(text: piece, style: style),
          ]),
        ),
        // Continuation pieces keep the paragraph's line rhythm.
        padding: pw.EdgeInsets.fromLTRB(
            padding.left,
            i == 0 ? padding.top : style.lineSpacing!,
            padding.right,
            i == pieces.length - 1 ? padding.bottom : 0),
      ),
  ];
}

pw.Widget _tintedBox(StudyStep step, pw.Widget child,
    {required pw.EdgeInsets padding}) {
  return pw.Container(
    width: double.infinity,
    padding: padding,
    decoration: pw.BoxDecoration(
      color: _Palette.tint(step),
      border: pw.Border(
          left: pw.BorderSide(color: _Palette.step(step), width: 2.5)),
    ),
    child: child,
  );
}

/// A Scripture reference at the start of an "other usage" line, such as
/// `Matthew 5:15`, `1 Cor. 13:4–7` or `Hebrews 9:2, 4`. Needs a verse, so
/// ordinary prose starting with a number is left alone.
final RegExp _leadingReference = RegExp(
    r'^((?:[1-3]\s?)?\p{L}[\p{L}.]*(?:\s(?:of\s)?\p{L}[\p{L}.]*){0,2}\s\d+'
    r'[:.]\d+(?:\s?[–—-]\s?\d+)?(?:,\s?\d+(?:[–—-]\d+)?)*)'
    r'(?=$|[\s,;:–—-])',
    unicode: true);

/// One "other usage" line (or a continuation [piece] of a long one): a dot
/// in the step color, then the text, with a leading Scripture reference set
/// in semibold.
pw.Widget _usageRow(StudyStep step, String piece, _Styles styles,
    {bool continuation = false}) {
  final Match? ref = continuation ? null : _leadingReference.firstMatch(piece);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: 13,
        alignment: pw.Alignment.topLeft,
        child: continuation
            ? null
            : pw.Container(
                width: 4,
                height: 4,
                margin: const pw.EdgeInsets.only(top: 5),
                decoration: pw.BoxDecoration(
                    color: _Palette.step(step), shape: pw.BoxShape.circle),
              ),
      ),
      pw.Expanded(
        child: pw.RichText(
          text: pw.TextSpan(children: [
            if (ref != null) ...[
              pw.TextSpan(text: ref[1], style: styles.reference),
              pw.TextSpan(text: piece.substring(ref.end), style: styles.body),
            ] else
              pw.TextSpan(text: piece, style: styles.body),
          ]),
        ),
      ),
    ],
  );
}

/// The "other usage" lines as a tinted list, one per row, each row its own
/// block so the list can run across pages.
List<pw.Widget> _usageList(StudyStep step, List<String> lines, _Styles styles) {
  final List<pw.Widget> out = [];
  for (final (int r, String line) in lines.indexed) {
    final List<String> pieces = styles.split(line);
    for (final (int p, String piece) in pieces.indexed) {
      final bool lastPiece = p == pieces.length - 1;
      final bool lastRow = r == lines.length - 1 && lastPiece;
      out.add(_tintedBox(
        step,
        _usageRow(step, piece, styles, continuation: p > 0),
        padding: pw.EdgeInsets.fromLTRB(
            styles.tintPadding.left,
            r == 0 && p == 0
                ? styles.tintPadding.top
                : (p == 0 ? 4 : styles.body.lineSpacing!),
            styles.tintPadding.right,
            lastRow ? styles.tintPadding.bottom : (lastPiece ? 4 : 0)),
      ));
    }
  }
  return out;
}

/// Short Definition and Other usage, side by side in two equal-height
/// tinted cards.
pw.Widget _definitionAndUsage(
    String definition, List<String> usages, _Styles styles) {
  const StudyStep defStep = StudyStep.application;
  const StudyStep useStep = StudyStep.summary;
  return pw.Table(
    columnWidths: const {
      0: pw.FlexColumnWidth(),
      1: pw.FixedColumnWidth(14),
      2: pw.FlexColumnWidth(),
    },
    children: [
      pw.TableRow(children: [
        _sectionHeading(defStep, styles.strings.pdfWordStudyDefinition, styles,
            top: styles.wordStudyGap),
        pw.SizedBox(),
        _sectionHeading(useStep, styles.strings.pdfWordStudyOtherUsage, styles,
            top: styles.wordStudyGap),
      ]),
      // "full" stretches both cards to the taller one's height.
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.full,
        children: [
          _tintedBox(defStep, pw.Text(definition, style: styles.body),
              padding: styles.tintPadding),
          pw.SizedBox(),
          _tintedBox(
            useStep,
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                for (final (int i, String line) in usages.indexed)
                  pw.Padding(
                    padding: pw.EdgeInsets.only(top: i == 0 ? 0 : 8),
                    child: _usageRow(useStep, line, styles),
                  ),
              ],
            ),
            padding: styles.tintPadding,
          ),
        ],
      ),
    ],
  );
}

pw.Widget _footer(
    int pageNumber, int pagesCount, String label, _Styles styles) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 10),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: _Palette.line, width: 0.6))),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(label,
              style: styles.footer,
              maxLines: 1,
              overflow: pw.TextOverflow.clip),
        ),
        // A lone square image needs no "page 1 of 1".
        if (styles.layout == HandoutLayout.page || pagesCount > 1) ...[
          pw.SizedBox(width: 12),
          pw.Text(styles.strings.pdfPageOf(pageNumber, pagesCount),
              style: styles.footer),
        ],
      ],
    ),
  );
}

/// The fixed text a handout in [l]'s language prints (headings, notes,
/// footer, date), for choosing script fonts.
List<String> _labelTexts(AppLocalizations l, DateTime? updatedAt) => [
      l.pdfOverlineHomiletics,
      l.pdfOverlineWordStudy,
      l.pdfUntitledPassage,
      l.pdfUntitledWord,
      l.pdfHomileticLabel(''),
      l.pdfWordStudyLabelWithPassage('', ''),
      l.pdfPageOf(1, 1),
      l.pdfFcfCaption,
      l.pdfAimLeadIn,
      l.pdfEmptyHomiletic,
      l.pdfEmptyWordStudy,
      l.pdfWordStudyDefinition,
      l.pdfWordStudyOtherUsage,
      l.pdfWordStudyContextualMeaning,
      l.pdfWordStudyDeeperMeaning,
      l.pdfWordStudyApplication,
      for (final StudyStep step in StudyStep.values) step.localizedLabel(l),
      if (updatedAt != null) _formatDate(updatedAt, l),
    ];

/// Everything a homiletic handout in [l]'s language prints.
List<String> homileticPdfTexts(
        Homiletic homiletic,
        List<ContentSummary> summaries,
        List<Division> divisions,
        List<Application> applications,
        AppLocalizations l) =>
    [
      homiletic.passage,
      homiletic.subjectSentence,
      homiletic.fcf,
      homiletic.aim,
      for (final ContentSummary s in summaries) ...[s.passage, s.summary],
      for (final Division d in divisions) ...[d.passage, d.title],
      for (final Application a in applications) a.text,
      ..._labelTexts(l, homiletic.updatedAt),
    ];

/// Everything a word study handout in [l]'s language prints.
List<String> wordStudyPdfTexts(WordStudy study, AppLocalizations l) => [
      study.word,
      study.passage,
      study.definition,
      study.otherUsage,
      study.contextualMeaning,
      study.deeperMeaning,
      study.application,
      ..._labelTexts(l, study.updatedAt),
    ];

/// The bundled fonts plus whatever script fonts [texts] need.
Future<HomileticPdfFonts> _fontsFor(List<String> texts, Locale locale) async =>
    withScriptFallbacks(await _loadBundledFonts(), texts, locale: locale);

/// Builds the handout in the app's language with the app's fonts,
/// downloading a CJK or Arabic font first if the handout needs one.
Future<pw.Document> createHomileticsPdf(
    Homiletic homiletic,
    List<ContentSummary> summaries,
    List<Division> divisions,
    List<Application> applications,
    {PdfPageFormat format = PdfPageFormat.letter}) async {
  final (AppLocalizations l, Locale locale) = _appStrings();
  final HomileticPdfFonts fonts = await _fontsFor(
      homileticPdfTexts(homiletic, summaries, divisions, applications, l),
      locale);
  return buildHomileticsDocument(homiletic, summaries, divisions, applications,
      fonts: fonts, format: format, strings: l);
}

/// Builds the word study handout like [createHomileticsPdf].
Future<pw.Document> createWordStudyPdf(WordStudy study,
    {PdfPageFormat format = PdfPageFormat.letter}) async {
  final (AppLocalizations l, Locale locale) = _appStrings();
  final HomileticPdfFonts fonts =
      await _fontsFor(wordStudyPdfTexts(study, l), locale);
  return buildWordStudyDocument(study,
      fonts: fonts, format: format, strings: l);
}

/// [text] made safe for a file name: path and reserved characters become
/// `-`, whitespace becomes `_`.
String _slug(String text) => text
    .trim()
    .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]+'), '-')
    .replaceAll(RegExp(r'\s+'), '_');

String _fileName(Homiletic homiletic) {
  final String slug = _slug(homiletic.passage);
  return slug.isEmpty ? 'homiletics.pdf' : 'homiletics-$slug.pdf';
}

String _wordStudyFileName(WordStudy study) {
  final String slug = [_slug(study.word), _slug(study.passage)]
      .where((String part) => part.isNotEmpty)
      .join('-');
  return slug.isEmpty ? 'word-study.pdf' : 'word-study-$slug.pdf';
}

/// A study rendered as square PNG images for a social media feed.
class HandoutImages {
  /// The file name the images share, without an extension.
  final String baseName;

  /// The images, in order, each 1080px square.
  final List<Uint8List> pngs;

  const HandoutImages(this.baseName, this.pngs);

  /// A file name for each image: `name.png` for one, `name-1.png`, ... for
  /// more.
  List<String> get fileNames => pngs.length == 1
      ? ['$baseName.png']
      : [for (int i = 1; i <= pngs.length; i++) '$baseName-$i.png'];
}

/// Rasterizes each page of [doc] at [squareImageDpi].
Future<List<Uint8List>> _pngs(pw.Document doc) async {
  final Uint8List bytes = await doc.save();
  return [
    await for (final PdfRaster page
        in Printing.raster(bytes, dpi: squareImageDpi))
      await page.toPng()
  ];
}

String _baseName(String fileName) =>
    fileName.substring(0, fileName.length - '.pdf'.length);

/// The homiletic as square images, in the app's language.
Future<HandoutImages> homileticImages(
    Homiletic homiletic,
    List<ContentSummary> summaries,
    List<Division> divisions,
    List<Application> applications) async {
  final (AppLocalizations l, Locale locale) = _appStrings();
  final HomileticPdfFonts fonts = await _fontsFor(
      homileticPdfTexts(homiletic, summaries, divisions, applications, l),
      locale);
  return HandoutImages(
      _baseName(_fileName(homiletic)),
      await _pngs(buildHomileticsDocument(
          homiletic, summaries, divisions, applications,
          fonts: fonts, layout: HandoutLayout.square, strings: l)));
}

/// The word study as square images, like [homileticImages].
Future<HandoutImages> wordStudyImages(WordStudy study) async {
  final (AppLocalizations l, Locale locale) = _appStrings();
  final HomileticPdfFonts fonts =
      await _fontsFor(wordStudyPdfTexts(study, l), locale);
  return HandoutImages(
      _baseName(_wordStudyFileName(study)),
      await _pngs(buildWordStudyDocument(study,
          fonts: fonts, layout: HandoutLayout.square, strings: l)));
}

Future<void> printHomiletic(Homiletic homiletic, List<ContentSummary> summaries,
    List<Division> divisions, List<Application> applications) async {
  final (AppLocalizations l, Locale locale) = _appStrings();
  final HomileticPdfFonts fonts = await _fontsFor(
      homileticPdfTexts(homiletic, summaries, divisions, applications, l),
      locale);
  await Printing.layoutPdf(
    name: _fileName(homiletic),
    // Lay out for the paper the user picks (Letter, A4, ...).
    onLayout: (PdfPageFormat format) => buildHomileticsDocument(
            homiletic, summaries, divisions, applications,
            fonts: fonts, format: format, strings: l)
        .save(),
  );
}

Future<void> shareHomiletic(Homiletic homiletic, List<ContentSummary> summaries,
    List<Division> divisions, List<Application> applications) async {
  final pw.Document pdf =
      await createHomileticsPdf(homiletic, summaries, divisions, applications);
  await Printing.sharePdf(
      bytes: await pdf.save(), filename: _fileName(homiletic));
}

Future<void> printWordStudy(WordStudy study) async {
  final (AppLocalizations l, Locale locale) = _appStrings();
  final HomileticPdfFonts fonts =
      await _fontsFor(wordStudyPdfTexts(study, l), locale);
  await Printing.layoutPdf(
    name: _wordStudyFileName(study),
    // Lay out for the paper the user picks (Letter, A4, ...).
    onLayout: (PdfPageFormat format) =>
        buildWordStudyDocument(study, fonts: fonts, format: format, strings: l)
            .save(),
  );
}

Future<void> shareWordStudy(WordStudy study) async {
  final pw.Document pdf = await createWordStudyPdf(study);
  await Printing.sharePdf(
      bytes: await pdf.save(), filename: _wordStudyFileName(study));
}
