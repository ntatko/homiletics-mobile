import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Application step: one application question per row.
class ApplicationQuestionsCard extends StatefulWidget {
  static const String helpTitle = "Application Questions";
  static const String helpText =
      "These are questions that help the audience apply what they've just heard to their own lives. They should be specific, personal, open-ended, and thought-provoking.";

  final List<Application> applications;
  final Homiletic homiletic;
  final VoidCallback addApplication;
  final Future<void> Function(Application application) removeApplication;

  const ApplicationQuestionsCard(
      {Key? key,
      required this.applications,
      required this.homiletic,
      required this.addApplication,
      required this.removeApplication})
      : super(key: key);

  @override
  State<ApplicationQuestionsCard> createState() =>
      _ApplicationQuestionsCardState();
}

class _ApplicationQuestionsCardState extends State<ApplicationQuestionsCard> {
  final RowControllers<Application> _controllers = RowControllers<Application>(
      (application) => [TextEditingController(text: application.text)]);
  final RowRemover _remover = RowRemover();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _add() {
    _controllers.focusNextNewRow();
    widget.addApplication();
  }

  Future<void> _remove(Application application) {
    return _remover.remove(
      context,
      hasText: _controllers.of(application)[0].text.trim().isNotEmpty,
      rowName: 'application question',
      remove: () => widget.removeApplication(application),
      failureMessage: "Removing that Application didn't work",
      errorIdentifier: "Remove application",
    );
  }

  @override
  Widget build(BuildContext context) {
    _controllers.retainOnly(widget.applications);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.applications.map((application) {
          return Padding(
            key: ObjectKey(application),
            padding: const EdgeInsets.only(bottom: 8),
            child: StepListRow(
              step: StudyStep.application,
              autofocus: _controllers.shouldAutofocus(application),
              textController: _controllers.of(application)[0],
              textHint: 'How can I…',
              onSubmitted: (_) => _add(),
              onTextChanged: (value) async {
                await application.updateText(value);
                await widget.homiletic.update();
              },
              removeTooltip: 'Remove application question',
              onRemove: () => _remove(application),
            ),
          );
        }),
        DashedAddButton(
            step: StudyStep.application,
            label: 'Add question',
            onPressed: _add),
      ],
    );
  }
}
