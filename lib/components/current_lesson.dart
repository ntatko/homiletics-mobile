import 'dart:math' as math;
import 'package:homiletics/l10n/l10n.dart';

import 'package:homiletics/common/homiletic_progress.dart';
import 'package:homiletics/common/start_passage_item_flow.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/services/suggested_passages_repository.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/home_widgets.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:homiletics/utils/study_launch_uri.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:loggy/loggy.dart';
import 'package:url_launcher/url_launcher.dart';

/// Horizontal padding around each week card; Home lays this section out
/// edge to edge so swiping shows a gap between cards.
const double _pageGutter = 20;
const double _cardPaddingH = 20;
const double _cardPaddingV = 18;

/// Menu values of the study filter that aren't a study.
const String _allStudies = '';
const String _openStudySite = '\u0000open';

const TextStyle _pillText = TextStyle(
    fontFamily: AppFonts.sans, fontSize: 12, fontWeight: FontWeight.w500);

/// Outlined buttons with less side padding, so two fit side by side on a
/// narrow card.
final ButtonStyle _compactButton = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12));

const TextStyle _progressText =
    TextStyle(fontFamily: AppFonts.sans, fontSize: 14);

/// The suggested-passage cards ("This week"): one page per scheduled
/// passage, filterable by study, starting at the current week.
class CurrentLesson extends StatefulWidget {
  final List<PassageSchedule> schedules;

  const CurrentLesson({Key? key, required this.schedules}) : super(key: key);

  @override
  State<CurrentLesson> createState() => _CurrentLessonState();
}

class _CurrentLessonState extends State<CurrentLesson> {
  late PageController _pageController;
  String? _selectedStudy;
  late List<PassageSchedule> _filteredSchedules;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredSchedules = widget.schedules;
    _currentPage = _getInitialPage();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(CurrentLesson oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameScheduleList(oldWidget.schedules, widget.schedules)) {
      _selectedStudy = null;
      _filteredSchedules = widget.schedules;
      _replacePageController();
    }
  }

  /// Swaps in a controller starting at the right page for
  /// [_filteredSchedules]. The old one is still attached to the PageView
  /// until this build finishes, so it's disposed after the frame.
  void _replacePageController() {
    final PageController old = _pageController;
    _currentPage = _getInitialPage();
    _pageController = PageController(initialPage: _currentPage);
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  bool _sameScheduleList(List<PassageSchedule> a, List<PassageSchedule> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].passage != b[i].passage ||
          a[i].rollout != b[i].rollout ||
          a[i].lesson != b[i].lesson ||
          a[i].study != b[i].study ||
          !mapEquals(a[i].lessonI18n, b[i].lessonI18n) ||
          !mapEquals(a[i].passageI18n, b[i].passageI18n) ||
          !mapEquals(a[i].studyNames, b[i].studyNames)) {
        return false;
      }
    }
    return true;
  }

  /// Index of the latest passage that has rolled out, or -1 if none has.
  int get _currentWeekIndex {
    final now = DateTime.now();
    return _filteredSchedules
        .lastIndexWhere((schedule) => schedule.rollout.isBefore(now));
  }

  int _getInitialPage() {
    if (_filteredSchedules.isEmpty) return 0;
    // Nothing has rolled out yet: start at the first lesson.
    return math.max(0, _currentWeekIndex);
  }

  List<String> get _uniqueStudies {
    return widget.schedules.map((s) => s.study).toSet().toList()..sort();
  }

  void _filterSchedules(String? study) {
    setState(() {
      _selectedStudy = study;
      _filteredSchedules = study == null
          ? widget.schedules
          : widget.schedules.where((s) => s.study == study).toList();
      _replacePageController();
    });
  }

  /// The interface language, for the feed's translated titles.
  Language get _language => Language.match(Localizations.localeOf(context));

  /// The study's name from the feed in the current language, else its
  /// address without the scheme ("bsfinternational.org/john").
  String _studyLabel(String study) {
    for (final PassageSchedule s in widget.schedules) {
      if (s.study == study) {
        final String? name = s.studyName(_language);
        if (name != null && name.trim().isNotEmpty) return name;
        break;
      }
    }
    return _studyAddress(study);
  }

  static String _studyAddress(String study) => study
      .trim()
      .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^www\.', caseSensitive: false), '')
      .replaceFirst(RegExp(r'/$'), '');

  String _filterLabel(AppLocalizations l) =>
      _selectedStudy == null ? l.homeAllStudies : _studyLabel(_selectedStudy!);

  String _overlineFor(AppLocalizations l, int index) {
    final int current = _currentWeekIndex;
    final String when = index == current
        ? l.homeThisWeek
        : (current >= 0 && index < current ? l.homeEarlier : l.homeComingUp);
    final String lesson =
        _filteredSchedules[index].displayLesson(_language).trim();
    return lesson.isEmpty ? when : l.homeWeekOverline(when, lesson);
  }

  /// Widest the filter pill may get, given the card's inner width.
  static double _pillMaxWidth(double inner) => inner * 0.5;

  /// The schedule whose passage takes the most room (so its card is the
  /// tallest once the title wraps).
  PassageSchedule _longestPassage(TextScaler scaler) {
    PassageSchedule longest = _filteredSchedules.first;
    double widest = -1;
    for (final PassageSchedule s in _filteredSchedules) {
      final TextPainter painter = TextPainter(
        text:
            TextSpan(text: s.displayPassage(_language), style: AppText.display),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      if (painter.width > widest) {
        widest = painter.width;
        longest = s;
      }
      painter.dispose();
    }
    return longest;
  }

  Future<void> _onFilterMenu(String value, PassageSchedule schedule) async {
    if (value == _openStudySite) {
      await launchUrl(studyLaunchUri(schedule.study));
      return;
    }
    _filterSchedules(value == _allStudies ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredSchedules.isEmpty) return const SizedBox.shrink();
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final AppLocalizations l = context.l10n;

    return LayoutBuilder(builder: (context, constraints) {
      final double inner =
          constraints.maxWidth - 2 * _pageGutter - 2 * _cardPaddingH;
      final double pillMaxWidth = _pillMaxWidth(inner);
      Widget pill(PassageSchedule schedule) => _StudyFilterPill(
            label: _filterLabel(l),
            selected: _selectedStudy,
            studies: _uniqueStudies,
            studyLabel: _studyLabel,
            canOpenSite: schedule.study.trim().isNotEmpty,
            onSelected: (value) => _onFilterMenu(value, schedule),
          );
      final PassageSchedule tallest = _longestPassage(scaler);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // A PageView needs a fixed height: an invisible copy of the
          // tallest card sizes the stack, and the pages fill it.
          Stack(
            children: [
              ExcludeSemantics(
                child: ExcludeFocus(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: _pageGutter),
                        child: _WeekCard(
                          schedule: tallest,
                          overline: l.homeThisWeek,
                          pillMaxWidth: pillMaxWidth,
                          filter: pill(tallest),
                          measuring: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _filteredSchedules.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final PassageSchedule schedule = _filteredSchedules[index];
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: _pageGutter),
                      child: _WeekCard(
                        schedule: schedule,
                        overline: _overlineFor(l, index),
                        pillMaxWidth: pillMaxWidth,
                        filter: pill(schedule),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PageDots(count: _filteredSchedules.length, index: _currentPage),
        ],
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// The "All studies ▾" pill; its menu filters the cards by study and can
/// open the current card's study website.
class _StudyFilterPill extends StatelessWidget {
  final String label;
  final String? selected;
  final List<String> studies;
  final String Function(String) studyLabel;
  final bool canOpenSite;
  final ValueChanged<String> onSelected;

  const _StudyFilterPill({
    required this.label,
    required this.selected,
    required this.studies,
    required this.studyLabel,
    required this.canOpenSite,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    PopupMenuItem<String> item(String value, String text, bool checked) =>
        PopupMenuItem<String>(
          value: value,
          child: Row(children: [
            SizedBox(
              width: 28,
              child: checked
                  ? Icon(Icons.check_rounded, size: 18, color: c.accent)
                  : null,
            ),
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
          ]),
        );

    return PopupMenuButton<String>(
      tooltip: l.homeFilterByStudy,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        item(_allStudies, l.homeAllStudies, selected == null),
        for (final String study in studies)
          item(study, studyLabel(study), selected == study),
        if (canOpenSite) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: _openStudySite,
            child: Row(children: [
              SizedBox(
                  width: 28,
                  child: Icon(Icons.open_in_new_rounded,
                      size: 18, color: c.muted)),
              Text(l.homeOpenStudySite),
            ]),
          ),
        ],
      ],
      // The pill is 32px tall; the tap target around it is 44px.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Center(
          widthFactor: 1,
          child: Container(
            height: 32,
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: ShapeDecoration(
              shape: StadiumBorder(side: BorderSide(color: c.lineStrong)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _pillText.copyWith(color: c.ink),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, size: 20, color: c.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  final PassageSchedule schedule;
  final String overline;
  final Widget filter;
  final double pillMaxWidth;

  /// An invisible copy used only to size the PageView: no data loading,
  /// and no [Spacer] (its height is unbounded).
  final bool measuring;

  const _WeekCard({
    required this.schedule,
    required this.overline,
    required this.filter,
    required this.pillMaxWidth,
    this.measuring = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: _cardPaddingH, vertical: _cardPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The pill shares the overline's row (its 44px tap target sets
          // the row height) so the passage gets the card's full width.
          Row(
            children: [
              Expanded(
                child: Text(
                  overline.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.overline.copyWith(color: c.accent),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: pillMaxWidth),
                child: filter,
              ),
            ],
          ),
          Text(
            schedule.displayPassage(
                Language.match(Localizations.localeOf(context))),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.display.copyWith(color: c.ink),
          ),
          if (!measuring) const Spacer(),
          const SizedBox(height: 14),
          measuring
              ? const _ProgressRowContent(status: '', done: {})
              : _HomileticProgressRow(passage: schedule.passage),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: _compactButton,
                  onPressed: () =>
                      startLectureNoteForPassage(context, schedule.passage),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: c.recording,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(context.l10n.startLecture,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: _compactButton,
                  onPressed: () =>
                      startWordStudyForPassage(context, schedule.passage),
                  child: Text(context.l10n.startWordStudy,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The homiletic step bar plus the card's main action — "Start
/// homiletics" / "Continue homiletics" — for the latest homiletic on
/// [passage]. The button opens (or starts) that homiletic.
class _HomileticProgressRow extends StatelessWidget {
  final String passage;

  const _HomileticProgressRow({required this.passage});

  @override
  Widget build(BuildContext context) {
    return StudyDataBuilder<Set<StudyStep>?>(
      key: ValueKey(passage),
      load: () => loadPassageProgress(passage),
      builder: (context, snapshot) {
        if (snapshot.hasError) logError('${snapshot.error}');
        final Set<StudyStep>? done = snapshot.data;
        final bool loading =
            snapshot.connectionState != ConnectionState.done && done == null;
        return _ProgressRowContent(
          status: loading ? '' : describeProgress(context.l10n, done),
          done: done ?? const {},
          started: done != null,
          onPressed: () =>
              startHomileticForPassage(context, passage, askIfExisting: false),
        );
      },
    );
  }
}

class _ProgressRowContent extends StatelessWidget {
  final String status;
  final Set<StudyStep> done;

  /// Whether a homiletic exists for this passage yet.
  final bool started;

  /// Null while only measuring the card's height.
  final VoidCallback? onPressed;

  const _ProgressRowContent({
    required this.status,
    required this.done,
    this.started = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final bool finished = done.length == StudyStep.values.length;
    final AppLocalizations l = context.l10n;
    final String label = !started
        ? l.homeStartHomiletics
        : finished
            ? l.homeOpenHomiletics
            : l.homeContinueHomiletics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        StepProgressBar(done: done),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onPressed ?? () {},
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child:
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (started) ...[
                const SizedBox(width: 8),
                Text(status,
                    style: _progressText.copyWith(
                        color: c.onAccent.withValues(alpha: 0.85))),
              ],
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

/// Placeholder card while the suggested passages load.
class LoadingLesson extends StatelessWidget {
  const LoadingLesson({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _pageGutter),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
            horizontal: _cardPaddingH, vertical: _cardPaddingV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Overline(context.l10n.homeThisWeek, color: c.accent),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(context.l10n.homeLoadingPassages,
                      style: AppText.body.copyWith(color: c.muted)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentLessonActions extends StatefulWidget {
  const CurrentLessonActions({Key? key}) : super(key: key);

  @override
  State<CurrentLessonActions> createState() => _CurrentLessonActionsState();
}

class _CurrentLessonActionsState extends State<CurrentLessonActions> {
  List<PassageSchedule> _schedules = [];
  bool _waitingForFirstPayload = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await SuggestedPassagesRepository.loadWithCallback(
      onData: (schedules) {
        if (!mounted) return;
        setState(() {
          _schedules = schedules;
          _waitingForFirstPayload = false;
        });
      },
      onError: (e, st) {
        logError('$e\n$st');
        if (!mounted) return;
        setState(() => _waitingForFirstPayload = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForFirstPayload && _schedules.isEmpty) {
      return const LoadingLesson();
    }
    return CurrentLesson(schedules: _schedules);
  }
}
