import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Summary sentence step: a single multiline answer.
class SummarySentenceCard extends StatefulWidget {
  static String helpTitle(AppLocalizations l) => l.homileticSummaryHelpTitle;
  static String helpText(AppLocalizations l) => l.homileticSummaryHelpText;

  final Homiletic homiletic;

  const SummarySentenceCard({Key? key, required this.homiletic})
      : super(key: key);

  @override
  State<SummarySentenceCard> createState() => _SummarySentenceCardState();
}

class _SummarySentenceCardState extends State<SummarySentenceCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.homiletic.subjectSentence);
  }

  @override
  void didUpdateWidget(covariant SummarySentenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.homiletic, widget.homiletic)) {
      _controller.text = widget.homiletic.subjectSentence;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepTextField(
      step: StudyStep.summary,
      controller: _controller,
      hint: context.l10n.homileticSummaryHint,
      keyboardType: TextInputType.text,
      onChanged: (String text) async {
        await widget.homiletic.updateSubjectSentence(text);
      },
    );
  }
}
