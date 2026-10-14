import 'package:flutter/material.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

/// The editor of the Divisions step: one row of verses + division sentence
/// per grouping of the passage.
class DivisionsCard extends StatefulWidget {
  static String helpTitle(AppLocalizations l) => l.stepDivisions;
  static String helpText(AppLocalizations l) => l.homileticDivisionsHelpText;

  final List<Division> divisions;
  final Homiletic homiletic;
  final VoidCallback addDivision;
  final Future<void> Function(Division division) removeDivision;

  const DivisionsCard(
      {Key? key,
      required this.divisions,
      required this.homiletic,
      required this.addDivision,
      required this.removeDivision})
      : super(key: key);

  @override
  State<DivisionsCard> createState() => _DivisionsCardState();
}

class _DivisionsCardState extends State<DivisionsCard> {
  /// Per row: [verses, title].
  final RowControllers<Division> _controllers =
      RowControllers<Division>((division) => [
            TextEditingController(text: division.passage),
            TextEditingController(text: division.title),
          ]);
  final RowRemover _remover = RowRemover();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _add() {
    _controllers.focusNextNewRow();
    widget.addDivision();
  }

  Future<void> _remove(Division division) {
    final controllers = _controllers.of(division);
    return _remover.remove(
      context,
      hasText: controllers.any((c) => c.text.trim().isNotEmpty),
      confirmTitle: context.l10n.homileticRemoveDivisionTitle,
      remove: () => widget.removeDivision(division),
      failureMessage: context.l10n.homileticRemoveDivisionFailed,
      errorIdentifier: "Remove Divisions",
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    _controllers.retainOnly(widget.divisions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.divisions.map((division) {
          final controllers = _controllers.of(division);
          return Padding(
            key: ObjectKey(division),
            padding: const EdgeInsets.only(bottom: 8),
            child: StepListRow(
              step: StudyStep.divisions,
              autofocus: _controllers.shouldAutofocus(division),
              versesController: controllers[0],
              onVersesChanged: (String value) async {
                await division.updatePassage(value);
                await widget.homiletic.update();
              },
              textController: controllers[1],
              textHint: l.homileticDivisionHint,
              onSubmitted: (_) => _add(),
              onTextChanged: (String value) async {
                await division.updateText(value);
                await widget.homiletic.update();
              },
              removeTooltip: l.homileticRemoveDivisionTooltip,
              onRemove: () => _remove(division),
            ),
          );
        }),
        DashedAddButton(
            step: StudyStep.divisions,
            label: l.homileticAddDivision,
            onPressed: _add),
      ],
    );
  }
}
