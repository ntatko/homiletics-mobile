import 'package:flutter/material.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Content step: one row of verses + summary per section
/// of the passage.
class ContentSummariesCard extends StatefulWidget {
  static const String helpTitle = "Content Summaries";
  static const String helpText =
      "A content summary is a summary of a section of the bible. It doesn't need to be a sentence, it can also be more than one sentence. It should be a summary, in your own words, of the content of the passage.\nYou should have at least 10, but more than 20 content summaries. Generally, depending on the length of the passage, you will divide your passage into chunks of an approximate size to hit the 10-20 mark. So, if you passage is 30 verses, I'd try for 3 verses per content summary on average.";

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
      rowName: 'content summary',
      remove: () => widget.removeContentSummary(summary),
      failureMessage: "Removing that Content Summary didn't work",
      errorIdentifier: "Content Summary removal",
    );
  }

  @override
  Widget build(BuildContext context) {
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
              textHint: 'Summary…',
              onSubmitted: (_) => _add(),
              onTextChanged: (String value) async {
                await element.updateText(value);
                await widget.homiletic.update();
              },
              removeTooltip: 'Remove content summary',
              onRemove: () => _remove(element),
            ),
          );
        }),
        DashedAddButton(
            step: StudyStep.content, label: 'Add summary', onPressed: _add),
      ],
    );
  }
}
