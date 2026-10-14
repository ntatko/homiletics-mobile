import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Application step: one application question per row.
class ApplicationQuestionsCard extends StatefulWidget {
  static String helpTitle(AppLocalizations l) =>
      l.homileticApplicationHelpTitle;
  static String helpText(AppLocalizations l) => l.homileticApplicationHelpText;

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
      confirmTitle: context.l10n.homileticRemoveApplicationTitle,
      remove: () => widget.removeApplication(application),
      failureMessage: context.l10n.homileticRemoveApplicationFailed,
      errorIdentifier: "Remove application",
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
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
              textHint: l.homileticApplicationHint,
              onSubmitted: (_) => _add(),
              onTextChanged: (value) async {
                await application.updateText(value);
                await widget.homiletic.update();
              },
              removeTooltip: l.homileticRemoveApplicationTooltip,
              onRemove: () => _remove(application),
            ),
          );
        }),
        DashedAddButton(
            step: StudyStep.application,
            label: l.homileticAddApplication,
            onPressed: _add),
      ],
    );
  }
}
