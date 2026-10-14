import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/word_study_widgets.dart';

/// The filled accent card at the top of the word study: a "WORD" label
/// (tap it for [helpText]), the word itself as a large serif field, and
/// [chips] of context underneath.
class WordHeroCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(String) onChanged;
  final String helpText;
  final List<String> chips;

  const WordHeroCard({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.helpText,
    this.chips = const [],
  }) : super(key: key);

  static const TextStyle _wordStyle = TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 36,
      height: 1.15,
      fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color fg = c.onAccent;
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(AppRadius.panel),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: focusNode.requestFocus,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WordStudyTitle(
                title: context.l10n.wordStudyWordTitle,
                helpText: helpText,
                color: fg.withValues(alpha: 0.82),
                style: AppText.overline,
              ),
              TextField(
                focusNode: focusNode,
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                style: _wordStyle.copyWith(color: fg),
                cursorColor: fg,
                decoration: InputDecoration(
                  hintText: context.l10n.wordStudyWordHint,
                  hintStyle:
                      _wordStyle.copyWith(color: fg.withValues(alpha: 0.6)),
                  isCollapsed: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (String value) async {
                  await onChanged(value);
                },
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final String chip in chips)
                      WordHeroChip(label: chip, foreground: fg),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
