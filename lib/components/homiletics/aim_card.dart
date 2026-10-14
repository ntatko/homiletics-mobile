import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Aim step: a single multiline answer.
class AimCard extends StatefulWidget {
  static const String helpTitle = "Aim";
  static const String helpText =
      "The Aim is the key point, the one main takeaway truth you want yourself or an audience to walk away with. It may be derivable from the FCF, and will likely influence the Application Questions.";

  final Homiletic homiletic;

  const AimCard({Key? key, required this.homiletic}) : super(key: key);

  @override
  State<AimCard> createState() => _AimCardState();
}

class _AimCardState extends State<AimCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.homiletic.aim);
  }

  @override
  void didUpdateWidget(covariant AimCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.homiletic, widget.homiletic)) {
      _controller.text = widget.homiletic.aim;
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
      step: StudyStep.aim,
      controller: _controller,
      hint: 'Cause the audience to learn that…',
      keyboardType: TextInputType.multiline,
      onChanged: (String text) async {
        await widget.homiletic.updateAim(text);
      },
    );
  }
}
