import 'package:flutter/material.dart';
import 'package:homiletics/components/word_study/definition_suggestions_sheet.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';

class DefinitionCard extends StatelessWidget {
  final TextEditingController wordController;
  final TextEditingController controller;
  final Future<void> Function(String) onChanged;
  final Color lightColor;

  const DefinitionCard({
    Key? key,
    required this.wordController,
    required this.controller,
    required this.onChanged,
    required this.lightColor,
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
    if (chosen == null) return;
    controller.text = chosen;
    await onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return WordStudySectionCard(
      title: 'Definition',
      helpText:
          'What does this word mean, in plain terms? Tap "Suggest Definition" for candidate definitions pulled from a dictionary, or write your own.',
      hint: 'What does this word mean, in plain terms?',
      controller: controller,
      onChanged: onChanged,
      lightColor: lightColor,
      actions: [
        OutlinedButton.icon(
          onPressed: () => _suggestDefinition(context),
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('Suggest Definition'),
        ),
      ],
    );
  }
}
