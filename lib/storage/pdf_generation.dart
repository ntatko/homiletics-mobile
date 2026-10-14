import 'package:flutter/services.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
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

  final List<pw.Widget> body = [_header(title, homiletic.updatedAt, styles)];
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
    body.add(pw.Padding(
      padding: const pw.EdgeInsets.only(top: 28),
      child: pw.Text('Nothing has been written for this passage yet.',
          style: styles.statementLead),
    ));
  }

  doc.addPage(pw.MultiPage(
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
    footer: (pw.Context context) => _footer(context, title, styles),
    build: (pw.Context context) => body,
  ));
  return doc;
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
  final pw.TextStyle statement;
  final pw.TextStyle statementLead;
  final pw.TextStyle footer;
}

pw.Widget _header(String title, DateTime? updatedAt, _Styles styles) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('HOMILETICS', style: styles.overline),
      pw.SizedBox(height: 6),
      pw.Text(title, style: styles.passage),
      pw.SizedBox(height: 10),
      pw.Container(height: 0.75, color: _Palette.lineStrong),
      pw.SizedBox(height: 6),
      if (updatedAt != null)
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(_formatDate(updatedAt), style: styles.date),
        ),
      pw.SizedBox(height: 4),
    ],
  );
}

pw.Widget _sectionHeading(StudyStep step, int number, _Styles styles,
    {String? caption}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 22, bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 19,
          height: 19,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
              color: _Palette.step(step), shape: pw.BoxShape.circle),
          child: pw.Text('$number', style: styles.number),
        ),
        pw.SizedBox(width: 9),
        pw.Text(step.label, style: styles.sectionTitle),
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
          ? _keepTogether(_sectionHeading(step, number, styles), row)
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
  final List<String> pieces = splitForPages(text);
  final List<pw.Widget> out = [];
  for (final (int i, String piece) in pieces.indexed) {
    final pw.Widget box = pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.fromLTRB(
          14,
          i == 0 ? 11 : styles.statement.lineSpacing!,
          14,
          i == pieces.length - 1 ? 12 : 0),
      decoration: pw.BoxDecoration(
        color: _Palette.tint(step),
        border: pw.Border(
            left: pw.BorderSide(color: _Palette.step(step), width: 2.5)),
      ),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          if (i == 0 && leadIn != null)
            pw.TextSpan(text: leadIn, style: styles.statementLead),
          pw.TextSpan(text: piece, style: styles.statement),
        ]),
      ),
    );
    out.add(i == 0
        ? _keepTogether(
            _sectionHeading(step, number, styles, caption: caption), box)
        : box);
  }
  return out;
}

pw.Widget _footer(pw.Context context, String title, _Styles styles) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 18),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: _Palette.line, width: 0.6))),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text('Homiletics · $title',
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

String _fileName(Homiletic homiletic) {
  final String slug = homiletic.passage
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-')
      .replaceAll(RegExp(r'\s+'), '_');
  return slug.isEmpty ? 'homiletics.pdf' : 'homiletics-$slug.pdf';
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
