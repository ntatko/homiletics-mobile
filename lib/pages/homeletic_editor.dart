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
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';

class HomileticEditor extends StatefulWidget {
  const HomileticEditor({Key? key, this.homiletic}) : super(key: key);

  final Homiletic? homiletic;

  @override
  State<HomileticEditor> createState() => _HomileticState();
}

class _HomileticState extends State<HomileticEditor> {
  late final Homiletic _thisHomiletic;
  List<ContentSummary> _summaries = [];
  List<Division> _divisions = [];
  List<Application> _applications = [];

  /// The open step of the accordion, if any.
  StudyStep? _expanded;

  /// Set once the user opens or closes a step, so finishing the load
  /// doesn't override their choice.
  bool _userChoseStep = false;

  final Map<StudyStep, GlobalKey> _stepKeys = {
    for (final StudyStep step in StudyStep.values) step: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _thisHomiletic = widget.homiletic ?? Homiletic();
    prepTheTable();
  }

  @override
  void dispose() {
    notifyStudyDataChanged();
    super.dispose();
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
        if (!_userChoseStep) {
          _expanded =
              StudyStep.values.where((step) => !_isDone(step)).firstOrNull;
        }
      });
    } catch (error) {
      sendError(error, "load homiletics");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Something went wrong loading this lesson."),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
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

  static String _count(int n, String one, String many) =>
      '$n ${n == 1 ? one : many}';

  /// The short text on the right of a collapsed step.
  String _summaryOf(StudyStep step) {
    switch (step) {
      case StudyStep.content:
        final int n = _summaries.where((s) => _filled(s.summary)).length;
        return n > 0 ? _count(n, 'summary', 'summaries') : 'Verses + summary';
      case StudyStep.divisions:
        final int n = _divisions.where((d) => _filled(d.title)).length;
        return n > 0 ? _count(n, 'division', 'divisions') : '2–4 groupings';
      case StudyStep.summary:
        return _filled(_thisHomiletic.subjectSentence)
            ? _thisHomiletic.subjectSentence.trim()
            : '≤ 10 words';
      case StudyStep.fcf:
        return _filled(_thisHomiletic.fcf)
            ? _thisHomiletic.fcf.trim()
            : 'Fallen condition focus';
      case StudyStep.aim:
        return _filled(_thisHomiletic.aim)
            ? _thisHomiletic.aim.trim()
            : 'The main takeaway';
      case StudyStep.application:
        final int n = _applications.where((a) => _filled(a.text)).length;
        return n > 0 ? _count(n, 'question', 'questions') : 'How can I…';
    }
  }

  /// Opens [step] (closing the open one), or closes it if it's open, and
  /// scrolls the opened card into view.
  void _toggle(StudyStep step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _userChoseStep = true;
      _expanded = _expanded == step ? null : step;
    });
    if (_expanded == null) return;
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

  static (String, String) _helpFor(StudyStep step) {
    switch (step) {
      case StudyStep.content:
        return (ContentSummariesCard.helpTitle, ContentSummariesCard.helpText);
      case StudyStep.divisions:
        return (DivisionsCard.helpTitle, DivisionsCard.helpText);
      case StudyStep.summary:
        return (SummarySentenceCard.helpTitle, SummarySentenceCard.helpText);
      case StudyStep.fcf:
        return (FcfCard.helpTitle, FcfCard.helpText);
      case StudyStep.aim:
        return (AimCard.helpTitle, AimCard.helpText);
      case StudyStep.application:
        return (
          ApplicationQuestionsCard.helpTitle,
          ApplicationQuestionsCard.helpText
        );
    }
  }

  Widget _buildStep(StudyStep step, {bool compact = false}) {
    if (_expanded == step) {
      final (String helpTitle, String helpText) = _helpFor(step);
      return ExpandedStepCard(
        key: _stepKeys[step],
        step: step,
        title: step.label,
        helpTitle: helpTitle,
        helpText: helpText,
        onCollapse: () => _toggle(step),
        child: _editorFor(step),
      );
    }
    return CollapsedStepTile(
      key: _stepKeys[step],
      step: step,
      title: compact && step == StudyStep.application ? 'Apply' : step.label,
      summary: _summaryOf(step),
      done: _isDone(step),
      compact: compact,
      onTap: () => _toggle(step),
    );
  }

  List<Widget> _buildSteps() {
    // Aim and Application share a row while both are closed.
    final bool pairLast =
        _expanded != StudyStep.aim && _expanded != StudyStep.application;
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
    return [
      for (int i = 0; i < steps.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        steps[i],
      ],
    ];
  }

  Future<void> _runPdfAction(Future<void> Function() action, String success,
      String failure, String errorIdentifier) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(
        content: Text(success),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
        ),
      ));
    } catch (error) {
      sendError(error, errorIdentifier);
      messenger.showSnackBar(SnackBar(
        content: Text(failure),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PassageSplitScaffold(
      initialPassage: _thisHomiletic.passage,
      headerLabel: 'Homiletics · Passage',
      onPassageChanged: _thisHomiletic.updatePassage,
      itemName: "Homiletics lesson",
      deletedMessage: "Homiletics Deleted",
      deleteErrorIdentifier: "delete homiletics",
      onDelete: _thisHomiletic.delete,
      extraActions: [
        EditorMenuAction(
          icon: Icons.share,
          title: 'Share',
          onSelected: () => _runPdfAction(
              () => shareHomiletic(
                  _thisHomiletic, _summaries, _divisions, _applications),
              "PDF shared successfully.",
              "Something went wrong sharing your PDF. Try again soon.",
              "Share PDF"),
        ),
        EditorMenuAction(
          icon: Icons.print,
          title: 'Print',
          onSelected: () => _runPdfAction(
              () => printHomiletic(
                  _thisHomiletic, _summaries, _divisions, _applications),
              "PDF printed successfully.",
              "Something went wrong creating your PDF. Try again soon.",
              "PDF print"),
        ),
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
