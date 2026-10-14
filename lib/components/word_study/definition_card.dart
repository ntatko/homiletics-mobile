import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/components/word_study/definition_suggestions_sheet.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/word_study_widgets.dart';

enum _ExistingDefinitionChoice { replace, append }

class DefinitionCard extends StatelessWidget {
  final TextEditingController wordController;
  final TextEditingController controller;
  final Future<void> Function(String) onChanged;

  const DefinitionCard({
    Key? key,
    required this.wordController,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  Future<void> _suggestDefinition(BuildContext context) async {
    final String word = wordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.wordStudyEnterWordFirst),
      ));
      return;
    }
    final String? chosen = await showDefinitionSuggestionsSheet(context, word);
    if (chosen == null || !context.mounted) return;

    String updated = chosen;
    final String existing = controller.text.trim();
    if (existing.isNotEmpty && existing != chosen) {
      final _ExistingDefinitionChoice? choice =
          await showDialog<_ExistingDefinitionChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.wordStudyReplaceDefinitionTitle),
          content: Text(context.l10n.wordStudyReplaceDefinitionMessage),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.commonCancel)),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, _ExistingDefinitionChoice.append),
                child: Text(context.l10n.wordStudyAddBelow)),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, _ExistingDefinitionChoice.replace),
                child: Text(context.l10n.wordStudyReplace)),
          ],
        ),
      );
      if (choice == null || !context.mounted) return;
      if (choice == _ExistingDefinitionChoice.append) {
        updated = '$existing\n$chosen';
      }
    } else if (existing == chosen) {
      return;
    }

    controller.text = updated;
    await onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    const StudyStep step = StudyStep.application;
    // The suggestions come from an English-only dictionary, so only offer
    // them when the study's Bible text is English.
    final bool canSuggest = Preferences.translation.languageCode == 'en';
    return WordStudySectionCard(
      title: l.wordStudyDefinitionTitle,
      helpText: canSuggest
          ? l.wordStudyDefinitionHelp
          : l.wordStudyDefinitionHelpNoSuggest,
      hint: l.wordStudyDefinitionHint,
      controller: controller,
      onChanged: onChanged,
      step: step,
      minLines: 3,
      compact: true,
      action: canSuggest
          ? WordStudyAddButton(
              tooltip: l.wordStudySuggestDefinition,
              color: c.step(step),
              tint: c.stepTint(step),
              onPressed: () => _suggestDefinition(context),
            )
          : null,
    );
  }
}
