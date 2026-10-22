import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';

// Plain text versions of a study, for pasting into a social media post or
// comment. Those don't render formatting, so headings are set in capitals
// and lists use numbers and bullets. Empty sections are left out, like in
// the PDF.

/// A heading and its body lines, or nothing when [lines] is empty.
List<String> _section(String heading, List<String> lines) =>
    lines.isEmpty ? const [] : [heading.toUpperCase(), ...lines];

/// "label — text", or whichever of the two isn't empty.
String _row(String label, String text) => label.isEmpty
    ? text
    : text.isEmpty
        ? label
        : '$label — $text';

String _join(String title, List<List<String>> sections) => [
      title,
      for (final List<String> section in sections)
        if (section.isNotEmpty) section.join('\n'),
    ].join('\n\n');

/// The homiletic as plain text in [l]'s language.
String homileticText(
  Homiletic homiletic,
  List<ContentSummary> summaries,
  List<Division> divisions,
  List<Application> applications,
  AppLocalizations l,
) {
  final String passage = homiletic.passage.trim();
  final String subject = homiletic.subjectSentence.trim();
  final String fcf = homiletic.fcf.trim();
  final String aim = homiletic.aim.trim();
  final List<String> questions = [
    for (final Application a in applications)
      if (a.text.trim().isNotEmpty) a.text.trim()
  ];
  return _join(
    l.pdfHomileticLabel(passage.isEmpty ? l.pdfUntitledPassage : passage),
    [
      _section(StudyStep.content.localizedLabel(l), [
        for (final ContentSummary s in summaries)
          if (s.passage.trim().isNotEmpty || s.summary.trim().isNotEmpty)
            _row(s.passage.trim(), s.summary.trim())
      ]),
      _section(StudyStep.divisions.localizedLabel(l), [
        for (final Division d in divisions)
          if (d.passage.trim().isNotEmpty || d.title.trim().isNotEmpty)
            _row(d.passage.trim(), d.title.trim())
      ]),
      _section(StudyStep.summary.localizedLabel(l),
          [if (subject.isNotEmpty) subject]),
      _section('${StudyStep.fcf.localizedLabel(l)} (${l.pdfFcfCaption})',
          [if (fcf.isNotEmpty) fcf]),
      _section(StudyStep.aim.localizedLabel(l),
          [if (aim.isNotEmpty) '${l.pdfAimLeadIn}$aim']),
      _section(StudyStep.application.localizedLabel(l),
          [for (final (int i, String q) in questions.indexed) '${i + 1}. $q']),
    ],
  );
}

/// The word study as plain text in [l]'s language.
String wordStudyText(WordStudy study, AppLocalizations l) {
  final String word = study.word.trim();
  final String passage = study.passage.trim();
  final String title = word.isEmpty ? l.pdfUntitledWord : word;
  List<String> prose(String text) =>
      text.trim().isEmpty ? const [] : [text.trim()];
  return _join(
    passage.isEmpty
        ? l.pdfWordStudyLabel(title)
        : l.pdfWordStudyLabelWithPassage(title, passage),
    [
      _section(l.pdfWordStudyDefinition, prose(study.definition)),
      _section(l.pdfWordStudyOtherUsage, [
        for (final String line in study.otherUsage.split('\n'))
          if (line.trim().isNotEmpty) '• ${line.trim()}'
      ]),
      _section(l.pdfWordStudyContextualMeaning, prose(study.contextualMeaning)),
      _section(l.pdfWordStudyDeeperMeaning, prose(study.deeperMeaning)),
      _section(l.pdfWordStudyApplication, prose(study.application)),
    ],
  );
}
