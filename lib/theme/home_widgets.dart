import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// The kind of saved study a list row shows; picks its [IconTile].
enum StudyKind { homiletic, lecture, wordStudy }

/// The [IconTile] that marks a [StudyKind]: "H" on the accent tint for a
/// homiletic, a mic on a warm tint for a lecture, an italic serif "W" for a
/// word study.
class StudyKindTile extends StatelessWidget {
  final StudyKind kind;
  final double size;

  const StudyKindTile(this.kind, {Key? key, this.size = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    switch (kind) {
      case StudyKind.homiletic:
        return IconTile(
          size: size,
          background: c.accentTint,
          foreground: c.accent,
          child: Text(context.l10n.homeKindTileHomiletic),
        );
      case StudyKind.lecture:
        return IconTile(
          size: size,
          background: c.stepTint(StudyStep.fcf),
          foreground: c.step(StudyStep.fcf),
          child: const Icon(Icons.mic_none_rounded),
        );
      case StudyKind.wordStudy:
        return IconTile(
          size: size,
          background: c.stepTint(StudyStep.divisions),
          foreground: c.step(StudyStep.divisions),
          child: Text(context.l10n.homeKindTileWordStudy,
              style: TextStyle(
                  fontFamily: AppFonts.serif,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  fontSize: size * 0.45)),
        );
    }
  }
}

/// A row in a list of saved studies: tile, title, muted subtitle, chevron,
/// with an optional hairline under it.
class StudyListRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool divider;

  const StudyListRow({
    Key? key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.divider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
          decoration: divider
              ? BoxDecoration(border: Border(bottom: BorderSide(color: c.line)))
              : null,
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyStrong.copyWith(color: c.ink)),
                    const SizedBox(height: 1),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(color: c.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 22, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// The six-segment homiletic progress bar with tiny step labels: done
/// steps take their [AppColors.step] color, the rest the line color.
class StepProgressBar extends StatelessWidget {
  final Set<StudyStep> done;

  const StepProgressBar({Key? key, required this.done}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final String doneNames = StudyStep.values
        .where(done.contains)
        .map((s) => s.localizedLabel(l))
        .join(', ');
    return Semantics(
      label:
          done.isEmpty ? l.homeProgressNoneDone : l.homeProgressDone(doneNames),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (final StudyStep s in StudyStep.values) ...[
                if (s.index > 0) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: done.contains(s) ? c.step(s) : c.line,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              for (final StudyStep s in StudyStep.values) ...[
                if (s.index > 0) const SizedBox(width: 4),
                Expanded(
                  // Labels shrink rather than clip on narrow cards.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      s.localizedShortLabel(l),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: c.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Page indicator: the current page is a wide accent pill, the others small
/// dots. Falls back to "3 / 12" text when there are too many pages for dots.
class PageDots extends StatelessWidget {
  final int count;
  final int index;
  final int maxDots;

  const PageDots({
    Key? key,
    required this.count,
    required this.index,
    this.maxDots = 9,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    if (count <= 1) return const SizedBox.shrink();
    final AppLocalizations l = context.l10n;
    final String label = l.homePageOf(index + 1, count);
    if (count > maxDots) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Text(l.homePageFraction(index + 1, count),
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: c.muted)),
      );
    }
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == index ? c.accent : c.lineStrong,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The empty rounded square in front of an application question.
class CheckSquare extends StatelessWidget {
  const CheckSquare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.of(context).muted, width: 1.5),
      ),
    );
  }
}
