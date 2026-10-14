import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Corner radius of the word-study section cards (the hero word card uses
/// [AppRadius.panel]).
const double wordStudyCardRadius = 16;

/// Text style of a word-study section title ("DEFINITION"); colored per
/// section.
const TextStyle wordStudyTitleStyle = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5);

/// Shows the explanation of a word-study section in a dialog.
Future<void> showWordStudyHelp(
    BuildContext context, String title, String helpText) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(helpText),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// A small uppercase section title followed by a "?" icon; tapping either
/// opens [helpText] in a dialog. The tap target is at least 44px tall.
class WordStudyTitle extends StatelessWidget {
  final String title;
  final String helpText;
  final Color color;

  /// Overrides [wordStudyTitleStyle] (e.g. the hero card's overline).
  final TextStyle? style;

  const WordStudyTitle({
    Key? key,
    required this.title,
    required this.helpText,
    required this.color,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = (style ?? wordStudyTitleStyle).copyWith(
      color: color,
    );
    return Semantics(
      button: true,
      label: '$title, about this section',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => showWordStudyHelp(context, title, helpText),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.help_outline_rounded,
                size: 15,
                color: color.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The small round tinted "+" button in a section card's corner. Draws a
/// 28px circle inside a 44px tap target.
class WordStudyAddButton extends StatelessWidget {
  final String tooltip;
  final Color color;
  final Color tint;
  final VoidCallback onPressed;

  const WordStudyAddButton({
    Key? key,
    required this.tooltip,
    required this.color,
    required this.tint,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onPressed,
          radius: 22,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(Icons.add_rounded, size: 18, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A translucent label on the filled hero word card ("Revelation 2:1-7").
class WordHeroChip extends StatelessWidget {
  final String label;
  final Color foreground;

  const WordHeroChip({Key? key, required this.label, required this.foreground})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(color: foreground),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
