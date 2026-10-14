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

  /// Shows the "tap a verse number" tip under the rows.
  final bool showVerseTapTip;

  const ContentSummariesCard({
    Key? key,
    required this.contentSummaries,
    required this.homiletic,
    required this.addContentSummary,
    required this.removeContentSummary,
    this.showVerseTapTip = false,
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

  /// One per row, around the row's fields, so [focusSummary] can reach the
  /// summary field.
  final Map<ContentSummary, FocusNode> _rowFocus =
      Map<ContentSummary, FocusNode>.identity();

  @override
  void dispose() {
    _controllers.dispose();
    for (final FocusNode node in _rowFocus.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _focusFor(ContentSummary row) => _rowFocus.putIfAbsent(
      row,
      () => FocusNode(
          debugLabel: 'content row',
          skipTraversal: true,
          canRequestFocus: false));

  void _retainFocusNodes() {
    final Set<ContentSummary> keep = Set<ContentSummary>.identity()
      ..addAll(widget.contentSummaries);
    final List<ContentSummary> removed =
        _rowFocus.keys.where((row) => !keep.contains(row)).toList();
    for (final ContentSummary row in removed) {
      final FocusNode node = _rowFocus.remove(row)!;
      WidgetsBinding.instance.addPostFrameCallback((_) => node.dispose());
    }
  }

  /// Shows [row]'s (possibly just set) verses and puts the cursor in its
  /// summary field. Call after [row] is in [ContentSummariesCard.contentSummaries]
  /// and this card has been rebuilt with it.
  void focusSummary(ContentSummary row) {
    final List<TextEditingController> controllers = _controllers.of(row);
    if (controllers[0].text != row.passage) {
      controllers[0].text = row.passage;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final FocusNode? node = _rowFocus[row];
      final List<FocusNode> fields =
          node?.traversalDescendants.toList() ?? const <FocusNode>[];
      if (fields.isEmpty) return;
      final FocusNode summary = fields.last;
      summary.requestFocus();
      final BuildContext? fieldContext = summary.context;
      if (fieldContext != null && fieldContext.mounted) {
        Scrollable.ensureVisible(fieldContext,
            alignment: 0.3,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic);
      }
    });
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
    final AppColors c = AppColors.of(context);
    _controllers.retainOnly(widget.contentSummaries);
    _retainFocusNodes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.contentSummaries.map((element) {
          final controllers = _controllers.of(element);
          return Padding(
            key: ObjectKey(element),
            padding: const EdgeInsets.only(bottom: 8),
            child: Focus(
              focusNode: _focusFor(element),
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
            ),
          );
        }),
        DashedAddButton(
            step: StudyStep.content,
            label: l.homileticAddContentSummary,
            onPressed: _add),
        if (widget.showVerseTapTip)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: c.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.bibleVerseTapTip,
                      style: AppText.caption.copyWith(color: c.muted)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
