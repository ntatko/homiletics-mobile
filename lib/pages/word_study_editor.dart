import 'package:flutter/material.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/editor/passage_split_scaffold.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/share/study_share_sheet.dart';
import 'package:homiletics/components/word_study/definition_card.dart';
import 'package:homiletics/components/word_study/other_usage_card.dart';
import 'package:homiletics/components/word_study/word_hero_card.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/share_link.dart';
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

  Future<void> _runPdfAction(
      Future<void> Function() action,
      String Function(AppLocalizations) success,
      String Function(AppLocalizations) failure,
      String errorIdentifier) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l = context.l10n;
    try {
      await action();
      messenger.showSnackBar(SnackBar(
        content: Text(success(l)),
        action: SnackBarAction(onPressed: () {}, label: l.commonOk),
      ));
    } catch (error) {
      sendError(error, errorIdentifier);
      messenger.showSnackBar(SnackBar(
        content: Text(failure(l)),
        action: SnackBarAction(onPressed: () {}, label: l.commonOk),
      ));
    }
  }

  Future<void> _sharePdf() => _runPdfAction(
      () => shareWordStudy(_thisStudy),
      (l) => l.wordStudyPdfShared,
      (l) => l.wordStudyPdfShareFailed,
      "Share word study PDF");

  Future<void> _print() => _runPdfAction(
      () => printWordStudy(_thisStudy),
      (l) => l.wordStudyPdfPrinted,
      (l) => l.wordStudyPdfPrintFailed,
      "Print word study PDF");

  Future<void> _openShareSheet() {
    final AppLocalizations l = context.l10n;
    final String word = _thisStudy.word.trim();
    final String passage = _thisStudy.passage.trim();
    final String title = word.isEmpty
        ? (passage.isEmpty ? l.pdfUntitledWord : passage)
        : passage.isEmpty
            ? l.pdfWordStudyLabel(word)
            : l.pdfWordStudyLabelWithPassage(word, passage);
    return showStudyShareSheet(
      context,
      buildLink: () => ShareLink.encodeWordStudy(_thisStudy,
          translation: Preferences.preferredVersion),
      title: title,
      buildImages: () => wordStudyImages(_thisStudy),
      onSharePdf: _sharePdf,
      onPrint: _print,
    );
  }

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
    final AppLocalizations l = context.l10n;
    return PassageSplitScaffold(
      initialPassage: _thisStudy.passage,
      onPassageChanged: (String passage) {
        _passage.value = passage;
        _thisStudy.updatePassage(passage);
      },
      itemName: l.wordStudyItemName,
      deletedMessage: l.wordStudyDeleted,
      deleteErrorIdentifier: "word study deletion",
      onDelete: _thisStudy.delete,
      headerLabel: l.wordStudyHeaderLabel,
      versePanelFirst: true,
      verseWeight: 0.22,
      extraActions: [
        EditorMenuAction(
            icon: Icons.ios_share_rounded,
            title: l.commonShare,
            onSelected: _openShareSheet),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        children: [
          ValueListenableBuilder<String>(
            valueListenable: _passage,
            builder: (context, passage, _) => WordHeroCard(
              helpText: l.wordStudyWordHelp,
              controller: _wordController,
              focusNode: _wordFocusNode,
              onChanged: _thisStudy.updateWord,
              chips: [if (passage.trim().isNotEmpty) passage.trim()],
            ),
          ),
          const SizedBox(height: 10),
          // Each card sizes to its own content: forcing equal heights
          // (IntrinsicHeight) mis-measures the multi-line fields and
          // overflows the taller card.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 10),
          WordStudySectionCard(
            title: l.wordStudyContextualMeaningTitle,
            helpText: l.wordStudyContextualMeaningHelp,
            hint: l.wordStudyContextualMeaningHint,
            controller: _contextualMeaningController,
            onChanged: _thisStudy.updateContextualMeaning,
            step: StudyStep.fcf,
          ),
          const SizedBox(height: 10),
          WordStudySectionCard(
            title: l.wordStudyDeeperMeaningTitle,
            helpText: l.wordStudyDeeperMeaningHelp,
            hint: l.wordStudyDeeperMeaningHint,
            controller: _deeperMeaningController,
            onChanged: _thisStudy.updateDeeperMeaning,
            step: StudyStep.divisions,
          ),
          const SizedBox(height: 10),
          WordStudySectionCard(
            title: l.wordStudyApplicationTitle,
            helpText: l.wordStudyApplicationHelp,
            hint: l.wordStudyApplicationHint,
            controller: _applicationController,
            onChanged: _thisStudy.updateApplication,
            step: StudyStep.aim,
          ),
          if (_isFinished) ...[
            const SizedBox(height: 10),
            StudyCompleteCard(
              title: l.wordStudyDoneTitle,
              onPrint: _print,
              onShare: _openShareSheet,
            ),
          ],
          const SizedBox(height: 12),
          const HelpMenu(),
        ],
      ),
    );
  }
}
