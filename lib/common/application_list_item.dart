import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/home_widgets.dart';
import 'package:homiletics/theme/widgets.dart';

/// [compact] — a row inside Home's "Living it out" card (text clipped to
/// three lines, hairline under it).
/// [list] — its own card on the full "show more" screen (text wraps).
enum ApplicationQuestionDisplay { compact, list }

/// An application question: an empty check square, the question, and the
/// passage of the homiletic it came from. Tapping opens that homiletic.
class ApplicationListItem extends StatelessWidget {
  final Application application;
  final ApplicationQuestionDisplay displayStyle;

  /// Draws a hairline under a [ApplicationQuestionDisplay.compact] row.
  final bool divider;

  const ApplicationListItem({
    Key? key,
    required this.application,
    this.displayStyle = ApplicationQuestionDisplay.compact,
    this.divider = false,
  }) : super(key: key);

  Future<void> _openHomiletic(BuildContext context) async {
    final homiletic = await getHomileticById(application.homileticsId);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomileticEditor(homiletic: homiletic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final bool compact = displayStyle == ApplicationQuestionDisplay.compact;
    final String? passage = application.homileticPassage;

    final Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: CheckSquare(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                application.text,
                maxLines: compact ? 3 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
                style: AppText.body.copyWith(color: c.ink),
              ),
              if (passage != null && passage.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  passage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(color: c.muted),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, size: 22, color: c.muted),
      ],
    );

    if (!compact) {
      return AppCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        onTap: () => _openHomiletic(context),
        child: content,
      );
    }

    return InkWell(
      onTap: () => _openHomiletic(context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: divider
            ? BoxDecoration(border: Border(bottom: BorderSide(color: c.line)))
            : null,
        child: content,
      ),
    );
  }
}
