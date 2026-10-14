/// Blank, printable worksheets for the two guided study methods (the six-step
/// homiletic and the word study), styled like the app's PDF handouts
/// (lib/storage/pdf_generation.dart) so they read as the same family.
///
/// Built and written by test/templates_test.dart:
///
///   TEMPLATES_OUT_DIR=/path/to/out PDF_NOTO_DIR=/path/to/noto \
///     flutter test test/templates_test.dart
///
/// PDF_NOTO_DIR must hold NotoSansSC-Regular.ttf and NotoSansTC-Regular.ttf
/// (see PdfScriptFont in lib/services/pdf_font_service.dart for the URLs)
/// for the Chinese worksheets to render their glyphs.
library;

import 'dart:typed_data';
import 'dart:ui' show Color, Locale;

import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/storage/pdf_generation.dart' show HomileticPdfFonts;
import 'package:homiletics/theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A worksheet language: the file-name tag and the app locale it uses.
class TemplateLocale {
  final String tag;
  final Locale locale;
  const TemplateLocale(this.tag, this.locale);

  bool get isChinese => locale.languageCode == 'zh';
  bool get isTraditional => locale.scriptCode == 'Hant';

  AppLocalizations get strings => lookupAppLocalizations(locale);
}

const List<TemplateLocale> templateLocales = [
  TemplateLocale('en', Locale('en')),
  TemplateLocale('es', Locale('es')),
  TemplateLocale(
      'zh_Hans', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')),
  TemplateLocale(
      'zh_Hant', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
  TemplateLocale('fr', Locale('fr')),
  TemplateLocale('pt', Locale('pt')),
  TemplateLocale('sw', Locale('sw')),
];

const Map<String, PdfPageFormat> templateFormats = {
  'letter': PdfPageFormat.letter,
  'a4': PdfPageFormat.a4,
};

/// The website the footer points to.
const String _site = 'homiletics.app';

/// "Date" for the header's date field: the ARB files have no such label.
const Map<String, String> _dateLabel = {
  'en': 'Date',
  'es': 'Fecha',
  'zh_Hans': '日期',
  'zh_Hant': '日期',
  'fr': 'Date',
  'pt': 'Data',
  'sw': 'Tarehe',
};

/// Returns [data] with a few zero bytes appended (copy of `_padded` in
/// pdf_generation.dart: guards the pdf package against reading past the end
/// of a font whose last glyph is empty).
ByteData paddedFont(Uint8List bytes) {
  final Uint8List out = Uint8List(bytes.length + 32)
    ..setRange(0, bytes.length, bytes);
  return ByteData.sublistView(out);
}

PdfColor _pdf(Color color) => PdfColor.fromInt(color.toARGB32());

/// The light palette, as in pdf_generation.dart.
class _Palette {
  static const AppColors _c = AppColors.light;
  static final PdfColor ink = _pdf(_c.ink);
  static final PdfColor muted = _pdf(_c.muted);
  static final PdfColor line = _pdf(_c.line);
  static final PdfColor lineStrong = _pdf(_c.lineStrong);
  static final PdfColor accent = _pdf(_c.accent);
  static final PdfColor onAccent = _pdf(_c.onAccent);
  static PdfColor step(StudyStep s) => _pdf(_c.stepColors[s.index]);
}

/// Writing lines: darker than the handout's hairlines so they survive a
/// light printer, still quiet enough not to compete with handwriting.
final PdfColor _ruleColor = _Palette.lineStrong;
const double _ruleWidth = 0.6;

class _Styles {
  /// [cjk]: Chinese has no italics and no tracking, so Latin digits and
  /// labels stay upright and unspaced within Chinese text.
  _Styles(HomileticPdfFonts f, {bool cjk = false})
      : overline = pw.TextStyle(
            font: f.sansSemiBold,
            fontSize: 8,
            letterSpacing: cjk ? 0.6 : 1.8,
            color: _Palette.accent),
        fieldLabel = pw.TextStyle(
            font: f.sansSemiBold,
            fontSize: cjk ? 8.5 : 8,
            letterSpacing: cjk ? 0 : 0.6,
            color: _Palette.muted),
        number = pw.TextStyle(
            font: f.sansBold, fontSize: 8.5, color: _Palette.onAccent),
        sectionTitle = pw.TextStyle(
            font: f.serifSemiBold, fontSize: 15, color: _Palette.ink),
        caption = pw.TextStyle(
            font: cjk ? f.sans : f.serifItalic,
            fontSize: cjk ? 10 : 10.5,
            color: _Palette.muted),
        instruction = pw.TextStyle(
            font: cjk ? f.sans : f.serifItalic,
            fontSize: cjk ? 10 : 10.5,
            lineSpacing: 2,
            color: _Palette.muted),
        hint = pw.TextStyle(font: f.sans, fontSize: 8.5, color: _Palette.muted),
        columnLabel = pw.TextStyle(
            font: f.sansSemiBold,
            fontSize: cjk ? 8.5 : 8,
            letterSpacing: cjk ? 0 : 0.6),
        lineNumber = pw.TextStyle(font: f.serifSemiBold, fontSize: 11),
        leadIn = pw.TextStyle(
            font: cjk ? f.sans : f.serifItalic,
            fontSize: cjk ? 11 : 12,
            color: _Palette.muted),
        footer = pw.TextStyle(font: f.sans, fontSize: 8, color: _Palette.muted),
        footerSite = pw.TextStyle(
            font: f.sansSemiBold, fontSize: 8, color: _Palette.accent);

  final pw.TextStyle overline;
  final pw.TextStyle fieldLabel;
  final pw.TextStyle number;
  final pw.TextStyle sectionTitle;
  final pw.TextStyle caption;
  final pw.TextStyle instruction;
  final pw.TextStyle hint;
  final pw.TextStyle columnLabel;
  final pw.TextStyle lineNumber;
  final pw.TextStyle leadIn;
  final pw.TextStyle footer;
  final pw.TextStyle footerSite;
}

/// [s] without a trailing ellipsis ("Summary…" → "Summary").
String _bare(String s) => s.replaceAll(RegExp(r'\s*(…|\.\.\.)\s*$'), '').trim();

/// [s] without a leading "Label:" gloss, e.g. the FCF one-liner
/// "Fallen Condition Focus: the human need…" → "The human need…".
String _withoutGloss(String s) {
  final Match? m = RegExp(r'^[^:：]{1,40}\s?[:：]\s*').firstMatch(s);
  if (m == null) return s;
  final String rest = s.substring(m.end);
  if (rest.isEmpty) return s;
  return rest[0].toUpperCase() + rest.substring(1);
}

pw.ThemeData _theme(HomileticPdfFonts fonts) => pw.ThemeData.withFont(
      base: fonts.sans,
      bold: fonts.sansBold,
      italic: fonts.sansItalic,
      boldItalic: fonts.sansBold,
      fontFallback: fonts.fallback,
    );

const pw.EdgeInsets _margin = pw.EdgeInsets.fromLTRB(54, 46, 54, 34);

pw.Widget _footer(_Styles styles, String? pageLabel) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 14),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: _Palette.line, width: 0.6))),
    child: pw.Row(children: [
      pw.Text(_site, style: styles.footerSite),
      pw.Spacer(),
      if (pageLabel != null) pw.Text(pageLabel, style: styles.footer),
    ]),
  );
}

/// A blank field: a small label over a writing line [height] tall.
pw.Widget _field(String label, _Styles styles, {double height = 26}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(label.toUpperCase(), style: styles.fieldLabel),
      pw.Container(
        height: height,
        decoration: pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: _Palette.ink, width: 0.75))),
      ),
    ],
  );
}

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

/// A step heading: numbered circle (or square marker), title, optional
/// caption beside it and [hint] at the right, with [instruction] beneath,
/// indented to the title.
pw.Widget _heading(
  StudyStep step,
  String title,
  _Styles styles, {
  int? number,
  String? caption,
  String? hint,
  String? instruction,
  double top = 18,
}) {
  final double indent = number != null ? 28 : 18;
  return pw.Padding(
    padding: pw.EdgeInsets.only(top: top, bottom: 6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (number != null)
              _numberMarker(step, number, styles)
            else
              _squareMarker(step),
            pw.SizedBox(width: number != null ? 9 : 8),
            pw.Text(title, style: styles.sectionTitle),
            if (caption != null) ...[
              pw.SizedBox(width: 8),
              pw.Text(caption, style: styles.caption),
            ],
            pw.Spacer(),
            if (hint != null)
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _Palette.step(step), width: 0.6),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(hint,
                    style: styles.hint.copyWith(color: _Palette.step(step))),
              ),
          ],
        ),
        if (instruction != null)
          pw.Padding(
            padding: pw.EdgeInsets.only(left: indent, top: 3),
            child: pw.Text(instruction, style: styles.instruction),
          ),
      ],
    ),
  );
}

pw.BoxDecoration get _ruled => pw.BoxDecoration(
    border:
        pw.Border(bottom: pw.BorderSide(color: _ruleColor, width: _ruleWidth)));

/// A writing line [height] tall, with an optional [lead] widget at its left.
pw.Widget _line({double? height, pw.Widget? lead}) {
  return pw.Container(
    height: height,
    decoration: _ruled,
    alignment: pw.Alignment.bottomLeft,
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: lead,
  );
}

/// [count] writing lines sharing the available height (each at least as
/// tall as the flex allows), indented by [indent].
pw.Widget _flexLines(int count,
    {double indent = 0, pw.Widget? Function(int)? lead}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(left: indent),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < count; i++)
          pw.Expanded(child: _line(lead: lead?.call(i))),
      ],
    ),
  );
}

/// A two-column ruled table: a narrow [leftLabel] column and a wide
/// [rightLabel] one, with [rows] rows sharing the available height.
pw.Widget _twoColumnTable(StudyStep step, String leftLabel, String rightLabel,
    int rows, _Styles styles,
    {double leftWidth = 66}) {
  final pw.TextStyle label =
      styles.columnLabel.copyWith(color: _Palette.step(step));
  final pw.BorderSide divider = pw.BorderSide(color: _Palette.line, width: 0.6);
  pw.Widget row({required bool header}) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            width: leftWidth,
            padding: const pw.EdgeInsets.only(bottom: 4, right: 6),
            alignment: pw.Alignment.bottomLeft,
            decoration: pw.BoxDecoration(border: pw.Border(right: divider)),
            child:
                header ? pw.Text(leftLabel.toUpperCase(), style: label) : null,
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 8, bottom: 4),
              alignment: pw.Alignment.bottomLeft,
              child: header
                  ? pw.Text(rightLabel.toUpperCase(), style: label)
                  : null,
            ),
          ),
        ],
      );
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 28),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          height: 16,
          decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom:
                      pw.BorderSide(color: _Palette.step(step), width: 0.9))),
          child: row(header: true),
        ),
        for (int i = 0; i < rows; i++)
          pw.Expanded(
            child: pw.Container(decoration: _ruled, child: row(header: false)),
          ),
      ],
    ),
  );
}

/// The blank six-step homiletic worksheet: two pages.
pw.Document buildHomileticTemplate(TemplateLocale loc,
    {required HomileticPdfFonts fonts, required PdfPageFormat format}) {
  final AppLocalizations l = loc.strings;
  final _Styles styles = _Styles(fonts, cjk: loc.isChinese);
  final bool tall = format.height > PdfPageFormat.letter.height + 1;
  final int contentRows = tall ? 14 : 13;

  final pw.Document doc = pw.Document(
    title: '${l.pdfOverlineHomiletics} · ${l.onboardingStepsTitle}',
    creator: 'Homiletics',
    producer: 'Homiletics',
    subject: _site,
  );
  final pw.PageTheme pageTheme =
      pw.PageTheme(pageFormat: format, margin: _margin, theme: _theme(fonts));

  pw.Widget page(int n, List<pw.Widget> children) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          ...children,
          _footer(styles, l.pdfPageOf(n, 2)),
        ],
      );

  // Page 1: header, Content, Divisions.
  doc.addPage(pw.Page(
    pageTheme: pageTheme,
    build: (_) => page(1, [
      pw.Text(l.pdfOverlineHomiletics, style: styles.overline),
      pw.SizedBox(height: 10),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(child: _field(l.editorPassageLabel, styles, height: 30)),
          pw.SizedBox(width: 22),
          pw.SizedBox(
              width: 140,
              child: _field(_dateLabel[loc.tag]!, styles, height: 30)),
        ],
      ),
      pw.SizedBox(height: 4),
      _heading(StudyStep.content, l.stepContent, styles,
          number: 1, instruction: l.onboardingStepContent, top: 16),
      pw.Expanded(
        flex: contentRows * 10,
        child: _twoColumnTable(StudyStep.content, l.homileticVersesLabel,
            _bare(l.homileticContentSummaryHint), contentRows, styles),
      ),
      _heading(StudyStep.divisions, l.stepDivisions, styles,
          number: 2, instruction: l.onboardingStepDivisions, top: 20),
      pw.Expanded(
        flex: 4 * 14,
        child: _twoColumnTable(StudyStep.divisions, l.homileticVersesLabel,
            _bare(l.homileticDivisionHint), 4, styles),
      ),
    ]),
  ));

  // Page 2: Summary sentence, FCF, Aim, Application.
  const double lineHeight = 30;
  pw.Widget lines(int n) => pw.Padding(
        padding: const pw.EdgeInsets.only(left: 28),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [for (int i = 0; i < n; i++) _line(height: lineHeight)],
        ),
      );

  doc.addPage(pw.Page(
    pageTheme: pageTheme,
    build: (_) => page(2, [
      _heading(StudyStep.summary, l.stepSummary, styles,
          number: 3,
          hint: l.homileticSummaryEmptySummary,
          instruction: l.onboardingStepSummary,
          top: 0),
      lines(2),
      pw.Spacer(),
      _heading(StudyStep.fcf, l.stepFcf, styles,
          number: 4,
          caption: l.pdfFcfCaption,
          hint: l.homileticFcfHint,
          instruction: _withoutGloss(l.onboardingStepFcf)),
      lines(2),
      pw.Spacer(),
      _heading(StudyStep.aim, l.stepAim, styles,
          number: 5, instruction: l.onboardingStepAim),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 28),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _line(
                height: lineHeight,
                lead: pw.Text(l.pdfAimLeadIn.trim(), style: styles.leadIn)),
            _line(height: lineHeight),
          ],
        ),
      ),
      pw.Spacer(),
      _heading(StudyStep.application, l.stepApplication, styles,
          number: 6,
          hint: l.homileticApplicationEmptySummary,
          instruction: l.onboardingStepApplication),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 28),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Four questions, two lines each: a question is a sentence.
            for (int i = 0; i < 4; i++) ...[
              _line(
                height: lineHeight + (i == 0 ? 0 : 8),
                lead: pw.Text('${i + 1}.',
                    style: styles.lineNumber
                        .copyWith(color: _Palette.step(StudyStep.application))),
              ),
              _line(height: lineHeight - 4),
            ],
          ],
        ),
      ),
      pw.Spacer(),
    ]),
  ));
  return doc;
}

/// The blank word study worksheet: one page.
pw.Document buildWordStudyTemplate(TemplateLocale loc,
    {required HomileticPdfFonts fonts, required PdfPageFormat format}) {
  final AppLocalizations l = loc.strings;
  final _Styles styles = _Styles(fonts, cjk: loc.isChinese);

  final pw.Document doc = pw.Document(
    title: l.pdfOverlineWordStudy,
    creator: 'Homiletics',
    producer: 'Homiletics',
    subject: _site,
  );

  pw.Widget heading(StudyStep step, String title, String question,
          {double top = 16}) =>
      _heading(step, title, styles, instruction: question, top: top);

  pw.Widget dot(StudyStep step) => pw.Container(
        width: 4,
        height: 4,
        margin: const pw.EdgeInsets.only(bottom: 2),
        decoration: pw.BoxDecoration(
            color: _Palette.step(step), shape: pw.BoxShape.circle),
      );

  doc.addPage(pw.Page(
    pageTheme:
        pw.PageTheme(pageFormat: format, margin: _margin, theme: _theme(fonts)),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(l.pdfOverlineWordStudy, style: styles.overline),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
                flex: 3,
                child: _field(l.wordStudyWordTitle, styles, height: 34)),
            pw.SizedBox(width: 22),
            pw.Expanded(
                flex: 2,
                child: _field(l.editorPassageLabel, styles, height: 34)),
          ],
        ),
        pw.SizedBox(height: 2),
        // Definition and Other usage side by side, as in the handout.
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(),
            1: pw.FixedColumnWidth(22),
            2: pw.FlexColumnWidth(),
          },
          children: [
            pw.TableRow(children: [
              heading(StudyStep.application, l.pdfWordStudyDefinition,
                  l.wordStudyDefinitionHint),
              pw.SizedBox(),
              heading(StudyStep.summary, l.pdfWordStudyOtherUsage,
                  l.wordStudyOtherUsageHint),
            ]),
          ],
        ),
        pw.Expanded(
          flex: 5,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Expanded(child: _flexLines(5, indent: 18)),
              pw.SizedBox(width: 22),
              pw.Expanded(
                child: _flexLines(5,
                    indent: 18, lead: (_) => dot(StudyStep.summary)),
              ),
            ],
          ),
        ),
        heading(StudyStep.fcf, l.pdfWordStudyContextualMeaning,
            l.wordStudyContextualMeaningHint,
            top: 20),
        pw.Expanded(flex: 3, child: _flexLines(3, indent: 18)),
        heading(StudyStep.divisions, l.pdfWordStudyDeeperMeaning,
            l.wordStudyDeeperMeaningHint,
            top: 20),
        pw.Expanded(flex: 3, child: _flexLines(3, indent: 18)),
        heading(StudyStep.aim, l.pdfWordStudyApplication,
            l.wordStudyApplicationHint,
            top: 20),
        pw.Expanded(flex: 3, child: _flexLines(3, indent: 18)),
        _footer(styles, null),
      ],
    ),
  ));
  return doc;
}
