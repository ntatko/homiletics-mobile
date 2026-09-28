import 'package:flutter/material.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/components/word_study/other_usage_search_sheet.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';

class OtherUsageCard extends StatelessWidget {
  final TextEditingController wordController;
  final Translation translation;
  final TextEditingController controller;
  final Future<void> Function(String) onChanged;
  final Color lightColor;

  const OtherUsageCard({
    Key? key,
    required this.wordController,
    required this.translation,
    required this.controller,
    required this.onChanged,
    required this.lightColor,
  }) : super(key: key);

  /// Opens the usage-search sheet and appends any picked references to
  /// [controller]. Shared by the card's manual button and the editor's
  /// one-shot auto-trigger so the "append + persist" logic lives in one
  /// place.
  static Future<void> openUsageSearch(
    BuildContext context, {
    required String word,
    required Translation translation,
    required TextEditingController controller,
    required Future<void> Function(String) onChanged,
  }) async {
    if (word.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter a word above first."),
      ));
      return;
    }
    await showOtherUsageSearchSheet(
      context,
      word: word.trim(),
      translation: translation,
      onReferenceSelected: (reference) async {
        final existing = controller.text.trim();
        controller.text = existing.isEmpty ? reference : '$existing\n$reference';
        await onChanged(controller.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WordStudySectionCard(
      title: 'Other Usage',
      helpText:
          'Where else does this word or concept appear in Scripture? Tap "Find Usage" to search Bible Gateway and add references you find, or write your own.',
      hint: 'Where else does this word or concept appear in Scripture?',
      controller: controller,
      onChanged: onChanged,
      lightColor: lightColor,
      actions: [
        OutlinedButton.icon(
          onPressed: () => openUsageSearch(
            context,
            word: wordController.text,
            translation: translation,
            controller: controller,
            onChanged: onChanged,
          ),
          icon: const Icon(Icons.search),
          label: const Text('Find Usage'),
        ),
      ],
    );
  }
}
