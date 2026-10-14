import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/components/word_study/other_usage_search_sheet.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/word_study_widgets.dart';

class OtherUsageCard extends StatelessWidget {
  final TextEditingController wordController;

  /// The translation to search; defaults to the current preference, read at
  /// the time of the search.
  final Translation? translation;
  final TextEditingController controller;
  final Future<void> Function(String) onChanged;

  const OtherUsageCard({
    Key? key,
    required this.wordController,
    this.translation,
    required this.controller,
    required this.onChanged,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.wordStudyEnterWordFirst),
      ));
      return;
    }
    await showOtherUsageSearchSheet(
      context,
      word: word.trim(),
      translation: translation,
      onReferenceSelected: (reference) async {
        // The sheet can outlive the page that opened it; don't write into a
        // disposed controller.
        if (!context.mounted) return;
        final existing = controller.text.trim();
        controller.text =
            existing.isEmpty ? reference : '$existing\n$reference';
        await onChanged(controller.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    const StudyStep step = StudyStep.summary;
    return WordStudySectionCard(
      title: l.wordStudyOtherUsageTitle,
      helpText: l.wordStudyOtherUsageHelp,
      hint: l.wordStudyOtherUsageHint,
      controller: controller,
      onChanged: onChanged,
      step: step,
      minLines: 3,
      compact: true,
      action: WordStudyAddButton(
        tooltip: l.wordStudyFindOtherUsages,
        color: c.step(step),
        tint: c.stepTint(step),
        onPressed: () => openUsageSearch(
          context,
          word: wordController.text,
          translation: translation ?? Preferences.translation,
          controller: controller,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
