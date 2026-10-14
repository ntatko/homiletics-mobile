import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the FCF step: a single multiline answer.
class FcfCard extends StatefulWidget {
  static String helpTitle(AppLocalizations l) => l.stepFcf;
  static String helpText(AppLocalizations l) => l.homileticFcfHelpText;

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
      hint: context.l10n.homileticFcfHint,
      keyboardType: TextInputType.text,
      onChanged: (String text) async {
        await widget.homiletic.updateFcf(text);
      },
    );
  }
}
