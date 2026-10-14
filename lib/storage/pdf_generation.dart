import 'package:flutter/services.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', //
  'August', 'September', 'October', 'November', 'December',
];

String _formatDate(DateTime date) {
  final DateTime local = date.toLocal();
  return '${_months[local.month - 1]} ${local.day}, ${local.year}';
}

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
  PdfPageFormat format = PdfPageFormat.letter,
}) {
  final String passage = homiletic.passage.trim();
  final String title = passage.isEmpty ? 'Untitled passage' : passage;
  final _Styles styles = _Styles(fonts);

  final pw.Document doc = pw.Document(
    title: 'Homiletics · $title',
    creator: 'Homiletics',
    producer: 'Homiletics',
  );

  final List<pw.Widget> body = [
    _header('HOMILETICS', title, styles, updatedAt: homiletic.updatedAt)
  ];
  final int before = body.length;

  final List<(String, String)> contentRows = [
    for (final ContentSummary s in summaries)
      if (s.summary.trim().isNotEmpty || s.passage.trim().isNotEmpty)
        (s.passage.trim(), s.summary.trim())
  ];
  if (contentRows.isNotEmpty) {
    body.addAll(_rowSection(StudyStep.content, 1, contentRows, styles));
  }

  final List<(String, String)> divisionRows = [
    for (final Division d in divisions)
      if (d.title.trim().isNotEmpty || d.passage.trim().isNotEmpty)
        (d.passage.trim(), d.title.trim())
  ];
  if (divisionRows.isNotEmpty) {
    body.addAll(_rowSection(StudyStep.divisions, 2, divisionRows, styles));
  }

  if (homiletic.subjectSentence.trim().isNotEmpty) {
    body.addAll(_statementSection(
        StudyStep.summary, 3, homiletic.subjectSentence.trim(), styles));
  }
  if (homiletic.fcf.trim().isNotEmpty) {
    body.addAll(_statementSection(
        StudyStep.fcf, 4, homiletic.fcf.trim(), styles,
        caption: 'Fallen Condition Focus'));
  }
  if (homiletic.aim.trim().isNotEmpty) {
    body.addAll(_statementSection(
        StudyStep.aim, 5, homiletic.aim.trim(), styles,
        leadIn: 'Cause the audience to learn that '));
  }

  final List<String> questions = [
    for (final Application a in applications)
      if (a.text.trim().isNotEmpty) a.text.trim()
  ];
  if (questions.isNotEmpty) {
    body.addAll(_rowSection(
      StudyStep.application,
      6,
      [for (final (int i, String q) in questions.indexed) ('${i + 1}', q)],
      styles,
      labelWidth: 22,
    ));
  }

  if (body.length == before) {
    body.add(
        _emptyNote('Nothing has been written for this passage yet.', styles));
  }

  doc.addPage(_handoutPage(body, fonts, styles, format, 'Homiletics · $title'));
  return doc;
}

/// Space above each word study section; a little tighter than the
/// homiletic's so a typical study fits on one page.
const double _wordStudyGap = 18;

/// Lays out a word study as a printable handout, in the same style as
/// [buildHomileticsDocument]. Pure, like it.
pw.Document buildWordStudyDocument(
  WordStudy study, {
  required HomileticPdfFonts fonts,
  PdfPageFormat format = PdfPageFormat.letter,
}) {
  final String word = study.word.trim();
  final String passage = study.passage.trim();
  final String title = word.isEmpty ? 'Untitled word' : word;
  final _Styles styles = _Styles(fonts);
  final String label =
      ['Word study', title, if (passage.isNotEmpty) passage].join(' · ');

  final pw.Document doc = pw.Document(
    title: label,
    creator: 'Homiletics',
    producer: 'Homiletics',
  );

  final List<pw.Widget> body = [
    _header('WORD STUDY', title, styles,
        subtitle: passage.isEmpty ? null : passage, updatedAt: study.updatedAt)
  ];
  final int before = body.length;

  void prose(String title, StudyStep step, String text) {
    if (text.trim().isEmpty) return;
    body.addAll(_withHeading(
        _sectionHeading(step, title, styles, top: _wordStudyGap),
        _tintedBlocks(step, text.trim(), styles.body,
            padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 11))));
  }

  final String definition = study.definition.trim();
  final List<String> usages = [
    for (final String line in study.otherUsage.split('\n'))
      if (line.trim().isNotEmpty) line.trim()
  ];
  // Like the editor, short Definition and Other usage sit side by side;
  // anything longer is stacked so it can run across pages.
  final bool sideBySide = definition.isNotEmpty &&
      usages.isNotEmpty &&
      definition.length <= 420 &&
      '\n'.allMatches(definition).length < 6 &&
      usages.length <= 10 &&
      usages.every((String line) => line.length <= 70);
  if (sideBySide) {
    body.add(_definitionAndUsage(definition, usages, styles));
  } else {
    prose('Definition', StudyStep.application, definition);
    if (usages.isNotEmpty) {
      body.addAll(_withHeading(
          _sectionHeading(StudyStep.summary, 'Other usage', styles,
              top: _wordStudyGap),
          _usageList(StudyStep.summary, usages, styles)));
    }
  }

  prose('Contextual meaning', StudyStep.fcf, study.contextualMeaning);
  prose('Deeper meaning', StudyStep.divisions, study.deeperMeaning);
  prose('Application', StudyStep.aim, study.application);

  if (body.length == before) {
    body.add(_emptyNote(
        'Nothing has been written for this word study yet.', styles));
  }

  doc.addPage(_handoutPage(body, fonts, styles, format, label));
  return doc;
}

/// The page setup every handout shares: margins, fonts and the running
/// footer labelled [footerLabel].
pw.MultiPage _handoutPage(List<pw.Widget> body, HomileticPdfFonts fonts,
    _Styles styles, PdfPageFormat format, String footerLabel) {
  return pw.MultiPage(
    pageTheme: pw.PageTheme(
      pageFormat: format,
      margin: const pw.EdgeInsets.fromLTRB(58, 52, 58, 36),
      theme: pw.ThemeData.withFont(
        base: fonts.sans,
        bold: fonts.sansBold,
        italic: fonts.sansItalic,
        boldItalic: fonts.sansBold,
        fontFallback: fonts.fallback,
      ),
    ),
    maxPages: 500,
    footer: (pw.Context context) => _footer(context, footerLabel, styles),
    build: (pw.Context context) => body,
  );
}

pw.Widget _emptyNote(String text, _Styles styles) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 28),
    child: pw.Text(text, style: styles.statementLead),
  );
}

class _Styles {
  _Styles(HomileticPdfFonts f)
      : overline = pw.TextStyle(
            font: f.sansSemiBold,
            fontSize: 8,
            letterSpacing: 1.8,
            color: _Palette.accent),
        passage = pw.TextStyle(
            font: f.serifMedium,
            fontSize: 30,
            lineSpacing: 2,
            color: _Palette.ink),
        date = pw.TextStyle(font: f.sans, fontSize: 9, color: _Palette.muted),
        number = pw.TextStyle(
            font: f.sansBold, fontSize: 8.5, color: _Palette.onAccent),
        sectionTitle = pw.TextStyle(
            font: f.serifSemiBold, fontSize: 15, color: _Palette.ink),
        caption = pw.TextStyle(
            font: f.serifItalic, fontSize: 10.5, color: _Palette.muted),
        rowLabel = pw.TextStyle(font: f.serifSemiBold, fontSize: 10.5),
        rowText = pw.TextStyle(
            font: f.sans, fontSize: 10.5, lineSpacing: 4, color: _Palette.ink),
        body = pw.TextStyle(
            font: f.sans, fontSize: 10.75, lineSpacing: 4, color: _Palette.ink),
        reference = pw.TextStyle(
            font: f.sansSemiBold, fontSize: 10.75, color: _Palette.ink),
        subtitle = pw.TextStyle(
            font: f.serifItalic, fontSize: 12, color: _Palette.muted),
        statement = pw.TextStyle(
            font: f.serif, fontSize: 13, lineSpacing: 4.5, color: _Palette.ink),
        statementLead = pw.TextStyle(
            font: f.serifItalic,
            fontSize: 13,
            lineSpacing: 4.5,
            color: _Palette.muted),
        footer = pw.TextStyle(font: f.sans, fontSize: 8, color: _Palette.muted);

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
}

/// The title block: a small accent [overline], the [title] large in serif,
/// then a rule with the [subtitle] (if any) and the date beneath it.
pw.Widget _header(String overline, String title, _Styles styles,
    {String? subtitle, DateTime? updatedAt}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(overline, style: styles.overline),
      pw.SizedBox(height: 6),
      pw.Text(title, style: styles.passage),
      pw.SizedBox(height: 10),
      pw.Container(height: 0.75, color: _Palette.lineStrong),
      pw.SizedBox(height: 6),
      if (subtitle != null || updatedAt != null)
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: subtitle == null
                  ? pw.SizedBox()
                  : pw.Text(subtitle, style: styles.subtitle),
            ),
            if (updatedAt != null) ...[
              pw.SizedBox(width: 12),
              pw.Text(_formatDate(updatedAt), style: styles.date),
            ],
          ],
        ),
      pw.SizedBox(height: 4),
    ],
  );
}

/// The numbered circle that marks a homiletic step.
pw.Widget _numberMarker(StudyStep step, int number, _Styles styles) {
  return pw.Container(
    width: 19,
    height: 19,
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
/// given, otherwise a small square) and [title] (default: the step label).
pw.Widget _sectionHeading(StudyStep step, String? title, _Styles styles,
    {int? number, String? caption, double top = 22}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(top: top, bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (number != null)
          _numberMarker(step, number, styles)
        else
          _squareMarker(step),
        pw.SizedBox(width: number != null ? 9 : 8),
        pw.Text(title ?? step.label, style: styles.sectionTitle),
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
  double labelWidth = 68,
}) {
  final pw.TextStyle labelStyle =
      styles.rowLabel.copyWith(color: _Palette.step(step));
  final pw.TextStyle emptyStyle =
      styles.rowText.copyWith(color: _Palette.muted);
  final List<pw.Widget> out = [];

  for (final (int r, (String label, String text)) in rows.indexed) {
    final List<String> pieces =
        text.isEmpty ? const ['—'] : splitForPages(text);
    final bool lastRow = r == rows.length - 1;
    for (final (int p, String piece) in pieces.indexed) {
      final bool lastPiece = p == pieces.length - 1;
      final pw.Widget row = pw.Container(
        // Continuation pieces keep the paragraph's line rhythm.
        padding: pw.EdgeInsets.only(
            top: p == 0 ? 7 : styles.rowText.lineSpacing!,
            bottom: lastPiece ? 7 : 0),
        decoration: lastPiece && !lastRow
            ? pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: _Palette.line, width: 0.6)))
            : null,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: labelWidth,
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
    _tintedBlocks(step, text, styles.statement,
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
  pw.TextStyle style, {
  pw.InlineSpan? lead,
  pw.EdgeInsets padding = const pw.EdgeInsets.fromLTRB(14, 11, 14, 12),
}) {
  final List<String> pieces = splitForPages(text);
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
    final List<String> pieces = splitForPages(line);
    for (final (int p, String piece) in pieces.indexed) {
      final bool lastPiece = p == pieces.length - 1;
      final bool lastRow = r == lines.length - 1 && lastPiece;
      out.add(_tintedBox(
        step,
        _usageRow(step, piece, styles, continuation: p > 0),
        padding: pw.EdgeInsets.fromLTRB(
            12,
            r == 0 && p == 0 ? 10 : (p == 0 ? 4 : styles.body.lineSpacing!),
            14,
            lastRow ? 11 : (lastPiece ? 4 : 0)),
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
        _sectionHeading(defStep, 'Definition', styles, top: _wordStudyGap),
        pw.SizedBox(),
        _sectionHeading(useStep, 'Other usage', styles, top: _wordStudyGap),
      ]),
      // "full" stretches both cards to the taller one's height.
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.full,
        children: [
          _tintedBox(defStep, pw.Text(definition, style: styles.body),
              padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 11)),
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
            padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 11),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _footer(pw.Context context, String label, _Styles styles) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 18),
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
        pw.SizedBox(width: 12),
        pw.Text('page ${context.pageNumber} of ${context.pagesCount}',
            style: styles.footer),
      ],
    ),
  );
}

/// Builds the handout with the app's bundled fonts.
Future<pw.Document> createHomileticsPdf(
    Homiletic homiletic,
    List<ContentSummary> summaries,
    List<Division> divisions,
    List<Application> applications,
    {PdfPageFormat format = PdfPageFormat.letter}) async {
  return buildHomileticsDocument(homiletic, summaries, divisions, applications,
      fonts: await _loadBundledFonts(), format: format);
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

Future<void> printHomiletic(Homiletic homiletic, List<ContentSummary> summaries,
    List<Division> divisions, List<Application> applications) async {
  final HomileticPdfFonts fonts = await _loadBundledFonts();
  await Printing.layoutPdf(
    name: _fileName(homiletic),
    // Lay out for the paper the user picks (Letter, A4, ...).
    onLayout: (PdfPageFormat format) => buildHomileticsDocument(
            homiletic, summaries, divisions, applications,
            fonts: fonts, format: format)
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
  final HomileticPdfFonts fonts = await _loadBundledFonts();
  await Printing.layoutPdf(
    name: _wordStudyFileName(study),
    // Lay out for the paper the user picks (Letter, A4, ...).
    onLayout: (PdfPageFormat format) =>
        buildWordStudyDocument(study, fonts: fonts, format: format).save(),
  );
}

Future<void> shareWordStudy(WordStudy study) async {
  final pw.Document pdf =
      buildWordStudyDocument(study, fonts: await _loadBundledFonts());
  await Printing.sharePdf(
      bytes: await pdf.save(), filename: _wordStudyFileName(study));
}
