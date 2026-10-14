import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Summary sentence step: a single multiline answer.
class SummarySentenceCard extends StatefulWidget {
  static const String helpTitle = "Summary Sentence";
  static const String helpText =
      "The Summary Sentence is a concise, memorable statement that encapsulates the most relevant facts. A good way of thinking of it is the 2am test: if someone were to wake you up at 2am and ask you what the sermon was about, what would you say? You'd say the Summary Sentence.\nIt should be 10 words or fewer. If you're feeling frisky, you can try to make an alliteration.";

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
      hint: 'Summarize: 10 words or fewer',
      keyboardType: TextInputType.text,
      onChanged: (String text) async {
        await widget.homiletic.updateSubjectSentence(text);
      },
    );
  }
}
