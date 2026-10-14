import 'package:flutter/material.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/editor/passage_split_scaffold.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/word_study/definition_card.dart';
import 'package:homiletics/components/word_study/other_usage_card.dart';
import 'package:homiletics/components/word_study/word_hero_card.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

class WordStudyEditor extends StatefulWidget {
  const WordStudyEditor({Key? key, this.study}) : super(key: key);

  final WordStudy? study;

  @override
  State<WordStudyEditor> createState() => _WordStudyEditorState();
}

class _WordStudyEditorState extends State<WordStudyEditor> {
  late final WordStudy _thisStudy;

  late final TextEditingController _wordController;
  late final TextEditingController _definitionController;
  late final TextEditingController _otherUsageController;
  late final TextEditingController _contextualMeaningController;
  late final TextEditingController _deeperMeaningController;
  late final TextEditingController _applicationController;
  final FocusNode _wordFocusNode = FocusNode();

  /// The passage as typed, for the chip on the word card.
  late final ValueNotifier<String> _passage;
  bool _autoUsageShown = false;

  @override
  void initState() {
    super.initState();
    _thisStudy = widget.study ?? WordStudy();
    _wordController = TextEditingController(text: _thisStudy.word);
    _definitionController = TextEditingController(text: _thisStudy.definition);
    _otherUsageController = TextEditingController(text: _thisStudy.otherUsage);
    _contextualMeaningController =
        TextEditingController(text: _thisStudy.contextualMeaning);
    _deeperMeaningController =
        TextEditingController(text: _thisStudy.deeperMeaning);
    _applicationController =
        TextEditingController(text: _thisStudy.application);
    _passage = ValueNotifier<String>(_thisStudy.passage);
    _wordFocusNode.addListener(_onWordFocusChange);
    FocusManager.instance.addListener(_onFocusMoved);
    // Only a brand-new study needs saving up front; re-saving an existing
    // one would bump its updated time just for being opened.
    if (_thisStudy.id == -1) _thisStudy.update();
  }

  /// Offers the Other Usage search once, the first time the user finishes
  /// typing a word and moves on to another field on this page. Focus also
  /// leaves the word field when a menu, dialog or another route opens, or
  /// when the page closes; none of those should pop the sheet up.
  void _onWordFocusChange() {
    if (_wordFocusNode.hasFocus) return;
    // Focus changes are applied in a batch; look at where focus ended up
    // once that settles.
    Future.microtask(() {
      if (!mounted || _autoUsageShown) return;
      if (_wordController.text.trim().isEmpty) return;
      if (_otherUsageController.text.trim().isNotEmpty) return;
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      if (!_focusMovedToFieldOnThisPage(FocusScope.of(context))) return;

      _autoUsageShown = true;
      OtherUsageCard.openUsageSearch(
        context,
        word: _wordController.text,
        translation: Preferences.translation,
        controller: _otherUsageController,
        onChanged: _thisStudy.updateOtherUsage,
      );
    });
  }

  /// Whether the focused node is a text field inside [pageScope] (the
  /// route's focus scope; dialogs and sheets have their own).
  bool _focusMovedToFieldOnThisPage(FocusScopeNode pageScope) {
    final FocusNode? focused = FocusManager.instance.primaryFocus;
    if (focused == null || !focused.ancestors.contains(pageScope)) {
      return false;
    }
    return focused.context?.findAncestorStateOfType<EditableTextState>() !=
        null;
  }

  /// Fields save straight to the model, so re-check whether the study is
  /// finished (for the Print / Share card) whenever focus moves on.
  void _onFocusMoved() {
    if (mounted) setState(() {});
  }

  bool get _isFinished => [
        _wordController,
        _definitionController,
        _otherUsageController,
        _contextualMeaningController,
        _deeperMeaningController,
        _applicationController,
      ].every((c) => c.text.trim().isNotEmpty);

  Future<void> _runPdfAction(Future<void> Function() action, String success,
      String failure, String errorIdentifier) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(
        content: Text(success),
        action: SnackBarAction(onPressed: () {}, label: "Ok"),
      ));
    } catch (error) {
      sendError(error, errorIdentifier);
      messenger.showSnackBar(SnackBar(
        content: Text(failure),
        action: SnackBarAction(onPressed: () {}, label: "Ok"),
      ));
    }
  }

  Future<void> _share() => _runPdfAction(
      () => shareWordStudy(_thisStudy),
      "PDF shared successfully.",
      "Something went wrong sharing your PDF. Try again soon.",
      "Share word study PDF");

  Future<void> _print() => _runPdfAction(
      () => printWordStudy(_thisStudy),
      "PDF printed successfully.",
      "Something went wrong creating your PDF. Try again soon.",
      "Print word study PDF");

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusMoved);
    _wordFocusNode.removeListener(_onWordFocusChange);
    _wordFocusNode.dispose();
    _passage.dispose();
    _wordController.dispose();
    _definitionController.dispose();
    _otherUsageController.dispose();
    _contextualMeaningController.dispose();
    _deeperMeaningController.dispose();
    _applicationController.dispose();
    notifyStudyDataChanged();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PassageSplitScaffold(
      initialPassage: _thisStudy.passage,
      onPassageChanged: (String passage) {
        _passage.value = passage;
        _thisStudy.updatePassage(passage);
      },
      itemName: "Word Study",
      deletedMessage: "Word Study Deleted",
      deleteErrorIdentifier: "word study deletion",
      onDelete: _thisStudy.delete,
      headerLabel: 'Word study · Passage',
      versePanelFirst: true,
      verseWeight: 0.22,
      extraActions: [
        EditorMenuAction(
            icon: Icons.ios_share_rounded, title: 'Share', onSelected: _share),
        EditorMenuAction(
            icon: Icons.print_outlined, title: 'Print', onSelected: _print),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        children: [
          ValueListenableBuilder<String>(
            valueListenable: _passage,
            builder: (context, passage, _) => WordHeroCard(
              helpText:
                  'The specific word or short phrase you\'re studying. Once you\'ve entered it, Definition and Other Usage can suggest content for you.',
              controller: _wordController,
              focusNode: _wordFocusNode,
              onChanged: _thisStudy.updateWord,
              chips: [if (passage.trim().isNotEmpty) passage.trim()],
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DefinitionCard(
                    wordController: _wordController,
                    controller: _definitionController,
                    onChanged: _thisStudy.updateDefinition,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OtherUsageCard(
                    wordController: _wordController,
                    controller: _otherUsageController,
                    onChanged: _thisStudy.updateOtherUsage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          WordStudySectionCard(
            title: 'Contextual meaning',
            helpText:
                'What did the author intend this word to mean here, in this passage? Consider the surrounding verses, not just the word alone.',
            hint: 'What does it mean here, in this passage?',
            controller: _contextualMeaningController,
            onChanged: _thisStudy.updateContextualMeaning,
            step: StudyStep.fcf,
          ),
          const SizedBox(height: 10),
          WordStudySectionCard(
            title: 'Deeper meaning',
            helpText:
                'Any insight from the original language, commentary, or outside study that adds depth beyond the basic definition? How does the rest of Scripture shape it? A Strong\'s concordance or Blue Letter Bible can help here.',
            hint: 'How does the rest of Scripture shape it?',
            controller: _deeperMeaningController,
            onChanged: _thisStudy.updateDeeperMeaning,
            step: StudyStep.divisions,
          ),
          const SizedBox(height: 10),
          WordStudySectionCard(
            title: 'Application',
            helpText:
                'How should this truth shape your life? Be specific, personal, and practical.',
            hint: 'What will you do with it?',
            controller: _applicationController,
            onChanged: _thisStudy.updateApplication,
            step: StudyStep.aim,
          ),
          if (_isFinished) ...[
            const SizedBox(height: 10),
            StudyCompleteCard(
              title: 'Word study done',
              onPrint: _print,
              onShare: _share,
            ),
          ],
          const SizedBox(height: 12),
          const HelpMenu(),
        ],
      ),
    );
  }
}
