import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:homiletics/theme/word_study_widgets.dart';

/// One section of a word study: a white card with a small uppercase title
/// in the section's [step] color (tap it for [helpText]), an optional
/// [action] in the corner, and a borderless multiline field. The card's
/// border turns the section color while its field has focus.
class WordStudySectionCard extends StatefulWidget {
  final String title;
  final String helpText;
  final String hint;
  final TextEditingController controller;
  final Future<void> Function(String) onChanged;
  final StudyStep step;
  final int minLines;

  /// Shown at the right of the title row (e.g. a [WordStudyAddButton]).
  final Widget? action;
  final FocusNode? focusNode;

  /// Smaller body text, for the half-width cards.
  final bool compact;

  const WordStudySectionCard({
    Key? key,
    required this.title,
    required this.helpText,
    required this.hint,
    required this.controller,
    required this.onChanged,
    required this.step,
    this.minLines = 2,
    this.action,
    this.focusNode,
    this.compact = false,
  }) : super(key: key);

  @override
  State<WordStudySectionCard> createState() => _WordStudySectionCardState();
}

class _WordStudySectionCardState extends State<WordStudySectionCard> {
  FocusNode? _ownFocusNode;
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(WordStudySectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChange);
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color color = c.step(widget.step);
    final TextStyle bodyStyle = widget.compact
        ? AppText.body.copyWith(fontSize: 14, color: c.ink)
        : AppText.body.copyWith(color: c.ink);

    return AppCard(
      radius: wordStudyCardRadius,
      highlight: _focusNode.hasFocus ? color : null,
      padding: const EdgeInsets.fromLTRB(14, 2, 6, 12),
      onTap: _focusNode.requestFocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: WordStudyTitle(
                    title: widget.title,
                    helpText: widget.helpText,
                    color: color,
                  ),
                ),
              ),
              if (widget.action != null) widget.action!,
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextField(
              focusNode: _focusNode,
              maxLines: null,
              minLines: widget.minLines,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              controller: widget.controller,
              style: bodyStyle,
              cursorColor: color,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: bodyStyle.copyWith(color: c.muted),
                hintMaxLines: 4,
                isCollapsed: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (String value) async {
                await widget.onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
