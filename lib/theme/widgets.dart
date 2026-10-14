import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';

/// A white card with a hairline border: the basic container of the design.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Draws a thicker border in this color (an active/focused card).
  final Color? highlight;

  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.card,
    this.highlight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final BorderRadius br = BorderRadius.circular(radius);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: br,
        side: highlight != null
            ? BorderSide(color: highlight!, width: 1.5)
            : BorderSide(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small uppercase label ("THIS WEEK", "PASSAGE").
class Overline extends StatelessWidget {
  final String text;
  final Color? color;

  const Overline(this.text, {Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: AppText.overline
            .copyWith(color: color ?? AppColors.of(context).muted));
  }
}

/// The grey pill that marks a draggable divider or sheet.
class DragHandle extends StatelessWidget {
  final Axis axis;

  const DragHandle({Key? key, this.axis = Axis.horizontal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool horizontal = axis == Axis.horizontal;
    return Center(
      child: Container(
        width: horizontal ? 40 : 4,
        height: horizontal ? 4 : 40,
        decoration: BoxDecoration(
          color: AppColors.of(context).lineStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

enum StudyStepState { done, active, pending }

/// The numbered circle for a homiletic step / word-study section: filled
/// with a check when done, filled with the number when active, outlined
/// when still to do.
class StepBadge extends StatelessWidget {
  final StudyStep step;
  final StudyStepState state;
  final double size;

  const StepBadge({
    Key? key,
    required this.step,
    required this.state,
    this.size = 26,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color color = c.step(step);
    final bool filled = state != StudyStepState.pending;
    final Color fg = filled ? c.surface : color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: filled ? null : Border.all(color: color, width: 1.5),
      ),
      child: state == StudyStepState.done
          ? Icon(Icons.check_rounded, size: size * 0.55, color: fg)
          : Text('${step.index + 1}',
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.w600,
                  color: fg)),
    );
  }
}

/// A rounded square holding an icon or a letter, used to mark the kind of
/// item in lists (homiletic, lecture, word study).
class IconTile extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color foreground;
  final double size;

  const IconTile({
    Key? key,
    required this.child,
    required this.background,
    required this.foreground,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: IconTheme(
        data: IconThemeData(color: foreground, size: size * 0.45),
        child: DefaultTextStyle(
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: size * 0.33,
              fontWeight: FontWeight.w600,
              color: foreground),
          child: child,
        ),
      ),
    );
  }
}

/// A serif section heading with an optional trailing action ("See all").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {Key? key, this.actionLabel, this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Text(title, style: AppText.title.copyWith(color: c.ink))),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
