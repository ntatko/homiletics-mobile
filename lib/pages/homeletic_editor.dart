import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/editor/passage_split_scaffold.dart';
import 'package:homiletics/components/homiletics/aim_card.dart';
import 'package:homiletics/components/homiletics/application_questions_card.dart';
import 'package:homiletics/components/homiletics/content_summaries_card.dart';
import 'package:homiletics/components/homiletics/divisions_card.dart';
import 'package:homiletics/components/homiletics/fcf_card.dart';
import 'package:homiletics/components/homiletics/summary_sentence_card.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/bible_text_service.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

class HomileticEditor extends StatefulWidget {
  const HomileticEditor({Key? key, this.homiletic, this.initialExpanded})
      : super(key: key);

  /// Steps to open on load instead of the first unfinished one.
  final Set<StudyStep>? initialExpanded;

  final Homiletic? homiletic;

  @override
  State<HomileticEditor> createState() => _HomileticState();
}

class _HomileticState extends State<HomileticEditor> {
  late final Homiletic _thisHomiletic;
  List<ContentSummary> _summaries = [];
  List<Division> _divisions = [];
  List<Application> _applications = [];

  /// The steps currently open; any number can be open at once (e.g.
  /// Content stays open for reference while writing Divisions).
  final Set<StudyStep> _expanded = {};

  /// Set once the user opens or closes a step, so finishing the load
  /// doesn't override their choice.
  bool _userChoseStep = false;

  final GlobalKey<ContentSummariesCardState> _contentCardKey =
      GlobalKey<ContentSummariesCardState>();

  /// Whether to show the "tap a verse number" tip (until it's first used).
  bool _showVerseTapTip = !VerseTapTip.hasUsed;

  final Map<StudyStep, GlobalKey> _stepKeys = {
    for (final StudyStep step in StudyStep.values) step: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _thisHomiletic = widget.homiletic ?? Homiletic();
    FocusManager.instance.addListener(_onFocusMoved);
    prepTheTable();
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusMoved);
    notifyStudyDataChanged();
    super.dispose();
  }

  /// Fields save straight to the model without rebuilding this page, so
  /// refresh step summaries / done badges / the finished card whenever the
  /// user moves on from a field.
  void _onFocusMoved() {
    if (mounted) setState(() {});
  }

  Future<void> prepTheTable() async {
    try {
      // Only a brand-new homiletic needs saving up front (to get an id for
      // its rows); re-saving an existing one would bump its updated time
      // just for being opened.
      if (_thisHomiletic.id == -1) await _thisHomiletic.update();
      final List<ContentSummary> savedSummaries =
          await getSummariesByHomileticId(_thisHomiletic.id);
      final List<Division> savedDivisions =
          await getDivisionsByHomileticId(_thisHomiletic.id);
      final List<Application> savedApplications =
          await getApplicationsByHomileticId(_thisHomiletic.id);
      if (!mounted) return;

      setState(() {
        _summaries = savedSummaries.isNotEmpty
            ? savedSummaries
            : [ContentSummary.blank(_thisHomiletic.id)];
        _divisions = savedDivisions.isNotEmpty
            ? savedDivisions
            : [Division.blank(_thisHomiletic.id)];
        _applications = savedApplications.isNotEmpty
            ? savedApplications
            : [Application.blank(_thisHomiletic.id)];
        if (!_userChoseStep && widget.initialExpanded != null) {
          _expanded
            ..clear()
            ..addAll(widget.initialExpanded!);
        } else if (!_userChoseStep) {
          final StudyStep? firstOpen =
              StudyStep.values.where((step) => !_isDone(step)).firstOrNull;
          _expanded
            ..clear()
            ..addAll([if (firstOpen != null) firstOpen]);
        }
      });
    } catch (error) {
      sendError(error, "load homiletics");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.homileticLoadError),
        action: SnackBarAction(
          onPressed: () {},
          label: context.l10n.commonOk,
        ),
      ));
    }
  }

  /// Takes [item] out of [list] right away (so the row disappears and a
  /// second tap can't hit it), then deletes it, putting it back if the
  /// delete fails.
  Future<void> _removeRow<T>(
      List<T> list, T item, Future<void> Function() delete) async {
    final int index = list.indexOf(item);
    if (index == -1) return;
    setState(() {
      list.removeAt(index);
    });
    try {
      await delete();
    } catch (_) {
      if (mounted) {
        setState(() {
          list.insert(index.clamp(0, list.length), item);
        });
      }
      rethrow;
    }
  }

  static bool _filled(String text) => text.trim().isNotEmpty;

  /// Whether [step] has anything written in it.
  bool _isDone(StudyStep step) {
    switch (step) {
      case StudyStep.content:
        return _summaries.any((s) => _filled(s.summary) || _filled(s.passage));
      case StudyStep.divisions:
        return _divisions.any((d) => _filled(d.title) || _filled(d.passage));
      case StudyStep.summary:
        return _filled(_thisHomiletic.subjectSentence);
      case StudyStep.fcf:
        return _filled(_thisHomiletic.fcf);
      case StudyStep.aim:
        return _filled(_thisHomiletic.aim);
      case StudyStep.application:
        return _applications.any((a) => _filled(a.text));
    }
  }

  /// The short text on the right of a collapsed step.
  String _summaryOf(StudyStep step) {
    final AppLocalizations l = context.l10n;
    switch (step) {
      case StudyStep.content:
        final int n = _summaries.where((s) => _filled(s.summary)).length;
        return n > 0
            ? l.homileticSummaryCount(n)
            : l.homileticContentEmptySummary;
      case StudyStep.divisions:
        final int n = _divisions.where((d) => _filled(d.title)).length;
        return n > 0
            ? l.homileticDivisionCount(n)
            : l.homileticDivisionsEmptySummary;
      case StudyStep.summary:
        return _filled(_thisHomiletic.subjectSentence)
            ? _thisHomiletic.subjectSentence.trim()
            : l.homileticSummaryEmptySummary;
      case StudyStep.fcf:
        return _filled(_thisHomiletic.fcf)
            ? _thisHomiletic.fcf.trim()
            : l.homileticFcfEmptySummary;
      case StudyStep.aim:
        return _filled(_thisHomiletic.aim)
            ? _thisHomiletic.aim.trim()
            : l.homileticAimEmptySummary;
      case StudyStep.application:
        final int n = _applications.where((a) => _filled(a.text)).length;
        return n > 0
            ? l.homileticQuestionCount(n)
            : l.homileticApplicationEmptySummary;
    }
  }

  /// Opens [step], or closes it if it's open, and scrolls an opened card
  /// into view. Other open steps stay open.
  void _toggle(StudyStep step) {
    FocusScope.of(context).unfocus();
    final bool opening = !_expanded.contains(step);
    setState(() {
      _userChoseStep = true;
      if (opening) {
        _expanded.add(step);
      } else {
        _expanded.remove(step);
      }
    });
    if (!opening) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? stepContext = _stepKeys[step]?.currentContext;
      if (stepContext == null || !stepContext.mounted) return;
      Scrollable.ensureVisible(stepContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic);
    });
  }

  Widget _editorFor(StudyStep step) {
    switch (step) {
      case StudyStep.content:
        return ContentSummariesCard(
            key: _contentCardKey,
            showVerseTapTip: _showVerseTapTip,
            contentSummaries: _summaries,
            homiletic: _thisHomiletic,
            addContentSummary: () {
              setState(() {
                _summaries.add(ContentSummary.blank(_thisHomiletic.id));
              });
            },
            removeContentSummary: (summary) =>
                _removeRow(_summaries, summary, summary.delete));
      case StudyStep.divisions:
        return DivisionsCard(
            divisions: _divisions,
            homiletic: _thisHomiletic,
            addDivision: () {
              setState(() {
                _divisions.add(Division.blank(_thisHomiletic.id));
              });
            },
            removeDivision: (division) =>
                _removeRow(_divisions, division, division.delete));
      case StudyStep.summary:
        return SummarySentenceCard(homiletic: _thisHomiletic);
      case StudyStep.fcf:
        return FcfCard(homiletic: _thisHomiletic);
      case StudyStep.aim:
        return AimCard(homiletic: _thisHomiletic);
      case StudyStep.application:
        return ApplicationQuestionsCard(
            applications: _applications,
            homiletic: _thisHomiletic,
            addApplication: () {
              setState(() {
                _applications.add(Application.blank(_thisHomiletic.id));
              });
            },
            removeApplication: (application) =>
                _removeRow(_applications, application, application.delete));
    }
  }

  static (String, String) _helpFor(StudyStep step, AppLocalizations l) {
    switch (step) {
      case StudyStep.content:
        return (
          ContentSummariesCard.helpTitle(l),
          ContentSummariesCard.helpText(l)
        );
      case StudyStep.divisions:
        return (DivisionsCard.helpTitle(l), DivisionsCard.helpText(l));
      case StudyStep.summary:
        return (
          SummarySentenceCard.helpTitle(l),
          SummarySentenceCard.helpText(l)
        );
      case StudyStep.fcf:
        return (FcfCard.helpTitle(l), FcfCard.helpText(l));
      case StudyStep.aim:
        return (AimCard.helpTitle(l), AimCard.helpText(l));
      case StudyStep.application:
        return (
          ApplicationQuestionsCard.helpTitle(l),
          ApplicationQuestionsCard.helpText(l)
        );
    }
  }

  Widget _buildStep(StudyStep step, {bool compact = false}) {
    final AppLocalizations l = context.l10n;
    if (_expanded.contains(step)) {
      final (String helpTitle, String helpText) = _helpFor(step, l);
      return ExpandedStepCard(
        key: _stepKeys[step],
        step: step,
        title: step.localizedLabel(l),
        helpTitle: helpTitle,
        helpText: helpText,
        onCollapse: () => _toggle(step),
        child: _editorFor(step),
      );
    }
    return CollapsedStepTile(
      key: _stepKeys[step],
      step: step,
      title: compact && step == StudyStep.application
          ? step.localizedShortLabel(l)
          : step.localizedLabel(l),
      summary: _summaryOf(step),
      done: _isDone(step),
      compact: compact,
      onTap: () => _toggle(step),
    );
  }

  List<Widget> _buildSteps() {
    // Aim and Application share a row while both are closed.
    final bool pairLast = !_expanded.contains(StudyStep.aim) &&
        !_expanded.contains(StudyStep.application);
    final List<Widget> steps = [
      for (final StudyStep step in StudyStep.values)
        if (!pairLast ||
            (step != StudyStep.aim && step != StudyStep.application))
          _buildStep(step),
      if (pairLast)
        Row(children: [
          Expanded(child: _buildStep(StudyStep.aim, compact: true)),
          const SizedBox(width: 8),
          Expanded(child: _buildStep(StudyStep.application, compact: true)),
        ]),
    ];
    if (StudyStep.values.every(_isDone)) {
      steps.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: StudyCompleteCard(
          title: context.l10n.homileticCompleteTitle,
          message: context.l10n.homileticCompleteMessage,
          onPrint: _print,
          onShare: _share,
        ),
      ));
    }
    return [
      for (int i = 0; i < steps.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        steps[i],
      ],
    ];
  }

  /// A verse number in the passage was tapped: start a Content summary
  /// there. Fills the last row when it's completely empty, otherwise adds
  /// one, opens the Content step and puts the cursor in the summary.
  Future<void> _startSummaryAt(String verses) async {
    final ContentSummary? last = _summaries.lastOrNull;
    final ContentSummary row =
        last != null && !_filled(last.summary) && !_filled(last.passage)
            ? last
            : ContentSummary.blank(_thisHomiletic.id);
    VerseTapTip.markUsed();
    setState(() {
      if (!identical(row, last)) _summaries.add(row);
      row.passage = verses;
      _expanded.add(StudyStep.content);
      _userChoseStep = true;
      _showVerseTapTip = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentCardKey.currentState?.focusSummary(row);
    });
    try {
      await row.updatePassage(verses);
      await _thisHomiletic.update();
    } catch (error) {
      sendError(error, "start content summary from verse");
    }
  }

  Future<void> _runPdfAction(Future<void> Function() action, String success,
      String failure, String errorIdentifier) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String okLabel = context.l10n.commonOk;
    try {
      await action();
      messenger.showSnackBar(SnackBar(
        content: Text(success),
        action: SnackBarAction(
          onPressed: () {},
          label: okLabel,
        ),
      ));
    } catch (error) {
      sendError(error, errorIdentifier);
      messenger.showSnackBar(SnackBar(
        content: Text(failure),
        action: SnackBarAction(
          onPressed: () {},
          label: okLabel,
        ),
      ));
    }
  }

  Future<void> _share() => _runPdfAction(
      () =>
          shareHomiletic(_thisHomiletic, _summaries, _divisions, _applications),
      context.l10n.homileticPdfShared,
      context.l10n.homileticPdfShareFailed,
      "Share PDF");

  Future<void> _print() => _runPdfAction(
      () =>
          printHomiletic(_thisHomiletic, _summaries, _divisions, _applications),
      context.l10n.homileticPdfPrinted,
      context.l10n.homileticPdfPrintFailed,
      "PDF print");

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    return PassageSplitScaffold(
      initialPassage: _thisHomiletic.passage,
      headerLabel: l.homileticHeaderLabel,
      onPassageChanged: _thisHomiletic.updatePassage,
      itemName: l.homileticItemName,
      deletedMessage: l.homileticDeletedMessage,
      deleteErrorIdentifier: "delete homiletics",
      onDelete: _thisHomiletic.delete,
      onVerseTap: _startSummaryAt,
      extraActions: [
        EditorMenuAction(
            icon: Icons.ios_share_rounded,
            title: l.commonShare,
            onSelected: _share),
        EditorMenuAction(
            icon: Icons.print_outlined,
            title: l.commonPrint,
            onSelected: _print),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildSteps(),
        ),
      ),
    );
  }
}
