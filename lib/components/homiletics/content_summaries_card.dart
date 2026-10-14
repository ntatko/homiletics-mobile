import 'package:flutter/material.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Content step: one row of verses + summary per section
/// of the passage.
class ContentSummariesCard extends StatefulWidget {
  static String helpTitle(AppLocalizations l) => l.homileticContentHelpTitle;
  static String helpText(AppLocalizations l) => l.homileticContentHelpText;

  final List<ContentSummary> contentSummaries;
  final Homiletic homiletic;
  final VoidCallback addContentSummary;
  final Future<void> Function(ContentSummary summary) removeContentSummary;

  const ContentSummariesCard({
    Key? key,
    required this.contentSummaries,
    required this.homiletic,
    required this.addContentSummary,
    required this.removeContentSummary,
  }) : super(key: key);

  @override
  ContentSummariesCardState createState() => ContentSummariesCardState();
}

class ContentSummariesCardState extends State<ContentSummariesCard> {
  /// Per row: [verses, summary].
  final RowControllers<ContentSummary> _controllers =
      RowControllers<ContentSummary>((summary) => [
            TextEditingController(text: summary.passage),
            TextEditingController(text: summary.summary),
          ]);
  final RowRemover _remover = RowRemover();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _add() {
    _controllers.focusNextNewRow();
    widget.addContentSummary();
  }

  Future<void> _remove(ContentSummary summary) {
    final controllers = _controllers.of(summary);
    return _remover.remove(
      context,
      hasText: controllers.any((c) => c.text.trim().isNotEmpty),
      confirmTitle: context.l10n.homileticRemoveContentSummaryTitle,
      remove: () => widget.removeContentSummary(summary),
      failureMessage: context.l10n.homileticRemoveContentSummaryFailed,
      errorIdentifier: "Content Summary removal",
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    _controllers.retainOnly(widget.contentSummaries);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.contentSummaries.map((element) {
          final controllers = _controllers.of(element);
          return Padding(
            key: ObjectKey(element),
            padding: const EdgeInsets.only(bottom: 8),
            child: StepListRow(
              step: StudyStep.content,
              autofocus: _controllers.shouldAutofocus(element),
              versesController: controllers[0],
              onVersesChanged: (String value) async {
                await element.updatePassage(value);
                await widget.homiletic.update();
              },
              textController: controllers[1],
              textHint: l.homileticContentSummaryHint,
              onSubmitted: (_) => _add(),
              onTextChanged: (String value) async {
                await element.updateText(value);
                await widget.homiletic.update();
              },
              removeTooltip: l.homileticRemoveContentSummaryTooltip,
              onRemove: () => _remove(element),
            ),
          );
        }),
        DashedAddButton(
            step: StudyStep.content,
            label: l.homileticAddContentSummary,
            onPressed: _add),
      ],
    );
  }
}
