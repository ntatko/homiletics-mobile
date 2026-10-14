import 'package:flutter/material.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/pages/onboarding/onboarding_illustrations.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/home_widgets.dart';
import 'package:homiletics/theme/widgets.dart';

/// The first-run guide: five swipeable pages explaining the app and the
/// homiletics method. Pops with this week's (English) passage when the
/// reader taps "Start this week's homiletic", otherwise with null. Open it
/// with `showOnboarding` (onboarding_launcher.dart), which handles that.
class OnboardingPage extends StatefulWidget {
  /// Finds the passage for "Start this week's homiletic"; when it gives
  /// null the last page only offers to explore.
  final Future<PassageSchedule?> Function() loadThisWeek;

  const OnboardingPage({Key? key, required this.loadThisWeek})
      : super(key: key);

  static const int pageCount = 5;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;
  PassageSchedule? _thisWeek;

  static const Duration _turn = Duration(milliseconds: 280);

  bool get _onLastPage => _page == OnboardingPage.pageCount - 1;

  @override
  void initState() {
    super.initState();
    _loadThisWeek();
  }

  /// Also retried on reaching the last page: on a fresh install the
  /// passages feed is usually still downloading when the guide opens.
  Future<void> _loadThisWeek() async {
    if (_thisWeek != null) return;
    try {
      final PassageSchedule? schedule = await widget.loadThisWeek();
      if (mounted && schedule != null) setState(() => _thisWeek = schedule);
    } catch (_) {
      // No passage: the last page just offers to explore.
    }
  }

  void _close([String? passage]) {
    Preferences.hasSeenOnboarding = true;
    Navigator.of(context).pop(passage);
  }

  void _goTo(int page) => _controller.animateToPage(page,
      duration: _turn, curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final List<Widget> pages = [
      _Slide(
        overline: l.onboardingWelcomeOverline,
        title: l.onboardingWelcomeTitle,
        body: [l.onboardingWelcomeBody],
        aside: const WelcomeIllustration(),
      ),
      _Slide(
        overline: l.onboardingMethodOverline,
        title: l.onboardingMethodTitle,
        body: [l.onboardingMethodBody],
        aside: const MethodIllustration(),
      ),
      _Slide(
        overline: l.onboardingStepsOverline,
        title: l.onboardingStepsTitle,
        aside: const StepsList(),
        asideFirst: false,
      ),
      _Slide(
        overline: l.onboardingLecturesOverline,
        title: l.onboardingLecturesTitle,
        body: [l.onboardingLecturesBody, l.onboardingWordStudyBody],
        aside: const LectureIllustration(),
      ),
      _Slide(
        overline: l.onboardingStartOverline,
        title: l.onboardingStartTitle,
        body: [l.onboardingStartBody],
        aside: const StartIllustration(),
        footer: _StartActions(
          thisWeek: _thisWeek,
          onStart: (passage) => _close(passage),
          onExplore: () => _close(),
        ),
      ),
    ];

    return PopScope(
      // System back / swipe-to-dismiss also counts as having seen it.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) Preferences.hasSeenOnboarding = true;
      },
      child: Scaffold(
        backgroundColor: c.ground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Visibility(
                    visible: !_onLastPage,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      key: const ValueKey('onboardingSkip'),
                      onPressed: _onLastPage ? null : () => _close(),
                      style:
                          TextButton.styleFrom(minimumSize: const Size(64, 44)),
                      child: Text(l.onboardingSkip),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (page) {
                    setState(() => _page = page);
                    if (page == OnboardingPage.pageCount - 1) _loadThisWeek();
                  },
                  children: pages,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _page == 0
                            ? const SizedBox(height: 46)
                            : TextButton(
                                key: const ValueKey('onboardingBack'),
                                onPressed: () => _goTo(_page - 1),
                                style: TextButton.styleFrom(
                                    minimumSize: const Size(64, 46)),
                                child: _FitLabel(l.onboardingBack),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PageDots(count: OnboardingPage.pageCount, index: _page),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _onLastPage
                            ? const SizedBox(height: 46)
                            : FilledButton(
                                key: const ValueKey('onboardingNext'),
                                onPressed: () => _goTo(_page + 1),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(64, 46),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                ),
                                child: _FitLabel(l.onboardingNext),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A one-line button label that shrinks instead of overflowing in the
/// narrow Back/Next slots.
class _FitLabel extends StatelessWidget {
  final String text;

  const _FitLabel(this.text);

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, softWrap: false),
      );
}

/// One page of the guide: an illustration (or the steps list) plus an
/// overline, a serif title and short paragraphs. Side by side when the
/// page is wide and short (landscape), stacked otherwise; scrolls when the
/// text is large.
class _Slide extends StatelessWidget {
  final String overline;
  final String title;
  final List<String> body;
  final Widget aside;

  /// Whether [aside] comes before the text (an illustration) or after it
  /// (content, like the steps list).
  final bool asideFirst;

  /// Shown under the text (the last page's buttons).
  final Widget? footer;

  const _Slide({
    required this.overline,
    required this.title,
    required this.aside,
    this.body = const [],
    this.asideFirst = true,
    this.footer,
  });

  static const double _hPad = 24;
  static const double _vPad = 12;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Overline(overline, color: c.accent),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(title,
              style: AppText.display.copyWith(fontSize: 28, color: c.ink)),
        ),
        for (final String paragraph in body) ...[
          const SizedBox(height: 12),
          Text(paragraph,
              style: AppText.body.copyWith(fontSize: 16, color: c.ink)),
        ],
        if (footer != null) ...[
          const SizedBox(height: 20),
          footer!,
        ],
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final bool sideBySide = constraints.maxWidth >= 560 &&
          constraints.maxWidth > constraints.maxHeight;
      final Widget content = sideBySide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: asideFirst ? Center(child: aside) : text),
                const SizedBox(width: 32),
                Expanded(child: asideFirst ? text : aside),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: asideFirst
                  ? [Center(child: aside), const SizedBox(height: 28), text]
                  : [text, const SizedBox(height: 20), aside],
            );
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: _vPad),
        child: ConstrainedBox(
          // Centered vertically while it fits, scrolling once it doesn't.
          constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 2 * _vPad)
                  .clamp(0, double.infinity)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sideBySide ? 880 : 520),
              child: content,
            ),
          ),
        ),
      );
    });
  }
}

/// The last page's buttons: start this week's homiletic (when the passages
/// feed has a week) and explore on my own, plus where to find the guide
/// again.
class _StartActions extends StatelessWidget {
  final PassageSchedule? thisWeek;
  final ValueChanged<String> onStart;
  final VoidCallback onExplore;

  const _StartActions({
    required this.thisWeek,
    required this.onStart,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final PassageSchedule? week = thisWeek;
    final Widget explore =
        Text(l.onboardingExplore, textAlign: TextAlign.center);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (week != null) ...[
          Text(
            l.onboardingThisWeekPassage(week.displayPassage(
                Language.match(Localizations.localeOf(context)))),
            style: AppText.caption.copyWith(color: c.muted),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('onboardingStartThisWeek'),
            onPressed: () => onStart(week.passage),
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: Text(l.onboardingStartThisWeek, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            key: const ValueKey('onboardingExplore'),
            onPressed: onExplore,
            child: explore,
          ),
        ] else
          FilledButton(
            key: const ValueKey('onboardingExplore'),
            onPressed: onExplore,
            child: explore,
          ),
        const SizedBox(height: 14),
        Text(l.onboardingReopenHint,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: c.muted)),
      ],
    );
  }
}
