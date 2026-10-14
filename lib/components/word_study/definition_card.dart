import 'package:flutter/material.dart';
import 'package:homiletics/components/word_study/definition_suggestions_sheet.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter a word above first."),
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
          title: const Text("Replace your definition?"),
          content: const Text(
              "You've already written a definition. Replace it with the suggestion, or add the suggestion below it?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, _ExistingDefinitionChoice.append),
                child: const Text('Add below')),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, _ExistingDefinitionChoice.replace),
                child: const Text('Replace')),
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
    const StudyStep step = StudyStep.application;
    return WordStudySectionCard(
      title: 'Definition',
      helpText:
          'What does this word mean, in plain terms? Tap "+" for candidate definitions pulled from a dictionary, or write your own.',
      hint: 'What does it mean, in plain terms?',
      controller: controller,
      onChanged: onChanged,
      step: step,
      minLines: 3,
      compact: true,
      action: WordStudyAddButton(
        tooltip: 'Suggest a definition',
        color: c.step(step),
        tint: c.stepTint(step),
        onPressed: () => _suggestDefinition(context),
      ),
    );
  }
}
