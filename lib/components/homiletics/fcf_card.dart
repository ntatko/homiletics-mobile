import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the FCF step: a single multiline answer.
class FcfCard extends StatefulWidget {
  static const String helpTitle = "FCF";
  static const String helpText =
      "The FCF (Fallen Condition Focus) is the part of humanity that is the most illustrated or referenced in the passage. It is the condition that the audience is in, the reason that the audience needs to be saved.";

  final Homiletic homiletic;

  const FcfCard({Key? key, required this.homiletic}) : super(key: key);

  @override
  State<FcfCard> createState() => _FcfCardState();
}

class _FcfCardState extends State<FcfCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.homiletic.fcf);
  }

  @override
  void didUpdateWidget(covariant FcfCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.homiletic, widget.homiletic)) {
      _controller.text = widget.homiletic.fcf;
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
      step: StudyStep.fcf,
      controller: _controller,
      hint: 'Fallen/Frail/Feeble/Fickle',
      keyboardType: TextInputType.text,
      onChanged: (String text) async {
        await widget.homiletic.updateFcf(text);
      },
    );
  }
}
