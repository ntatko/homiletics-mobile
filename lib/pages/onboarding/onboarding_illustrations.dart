import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/home_widgets.dart';
import 'package:homiletics/theme/widgets.dart';

// Small drawings for the first-run guide, built from the app's own tiles,
// badges and progress bar so they match what the reader will see next.
// Purely decorative: each is hidden from screen readers.

/// An open Bible with the three kinds of study around it.
class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(
            size: 88,
            background: c.accentTint,
            foreground: c.accent,
            child: const Icon(Icons.menu_book_rounded),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StudyKindTile(StudyKind.homiletic, size: 48),
              SizedBox(width: 14),
              StudyKindTile(StudyKind.lecture, size: 48),
              SizedBox(width: 14),
              StudyKindTile(StudyKind.wordStudy, size: 48),
            ],
          ),
        ],
      ),
    );
  }
}

/// Passage → main message → life, over a full six-step progress bar.
class MethodIllustration extends StatelessWidget {
  const MethodIllustration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    Widget arrow() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded, size: 20, color: c.muted),
        );
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTile(
                      size: 48,
                      background: c.stepTint(StudyStep.content),
                      foreground: c.step(StudyStep.content),
                      child: const Icon(Icons.menu_book_rounded),
                    ),
                    arrow(),
                    IconTile(
                      size: 48,
                      background: c.stepTint(StudyStep.summary),
                      foreground: c.step(StudyStep.summary),
                      child: const Icon(Icons.lightbulb_outline_rounded),
                    ),
                    arrow(),
                    IconTile(
                      size: 48,
                      background: c.stepTint(StudyStep.application),
                      foreground: c.step(StudyStep.application),
                      child: const Icon(Icons.directions_walk_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              StepProgressBar(done: StudyStep.values.toSet()),
            ],
          ),
        ),
      ),
    );
  }
}

/// The six steps, each with its numbered, colored badge, name and a
/// one-line description. Unlike the drawings this is the page's content,
/// so it stays readable by screen readers.
class StepsList extends StatelessWidget {
  const StepsList({Key? key}) : super(key: key);

  static String describe(AppLocalizations l, StudyStep step) => switch (step) {
        StudyStep.content => l.onboardingStepContent,
        StudyStep.divisions => l.onboardingStepDivisions,
        StudyStep.summary => l.onboardingStepSummary,
        StudyStep.fcf => l.onboardingStepFcf,
        StudyStep.aim => l.onboardingStepAim,
        StudyStep.application => l.onboardingStepApplication,
      };

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final StudyStep step in StudyStep.values) ...[
            if (step.index > 0) const SizedBox(height: 12),
            MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: StepBadge(
                        step: step, state: StudyStepState.active, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(step.localizedLabel(l),
                            style: AppText.bodyStrong
                                .copyWith(color: c.step(step))),
                        const SizedBox(height: 1),
                        Text(describe(l, step),
                            style: AppText.caption
                                .copyWith(fontSize: 14, color: c.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A lecture recording (red dot, waveform, a time mark) above a word
/// highlighted for a word study.
class LectureIllustration extends StatelessWidget {
  const LectureIllustration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const StudyKindTile(StudyKind.lecture, size: 40),
                  const SizedBox(width: 12),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                        color: c.recording, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: _Waveform()),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.accentTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('12:04',
                        style: AppText.caption.copyWith(
                            color: c.accent, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: c.line),
              ),
              Row(
                children: [
                  const StudyKindTile(StudyKind.wordStudy, size: 40),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.highlight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      // "Word" in John 1:1 — the same in every language.
                      child: Text('λόγος',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.scripture.copyWith(
                              height: 1.2,
                              fontStyle: FontStyle.italic,
                              color: c.ink)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bars of a recording, as many as fit.
class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      const double bar = 3, gap = 3, maxH = 26;
      final int count =
          math.max(0, ((constraints.maxWidth + gap) / (bar + gap)).floor());
      return SizedBox(
        height: maxH,
        child: Row(
          children: [
            for (int i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              Container(
                width: bar,
                height: 6 + (maxH - 6) * (0.5 + 0.5 * math.sin(i * 0.9)).abs(),
                decoration: BoxDecoration(
                  color: i < count * 0.7 ? c.recording : c.lineStrong,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// A finished-looking study: the accent tile with a check.
class StartIllustration extends StatelessWidget {
  const StartIllustration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return ExcludeSemantics(
      child: IconTile(
        size: 80,
        background: c.accent,
        foreground: c.onAccent,
        child: const Icon(Icons.auto_stories_rounded),
      ),
    );
  }
}
