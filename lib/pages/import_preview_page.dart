import 'package:flutter/material.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:homiletics/services/share_link.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/homiletics_widgets.dart';
import 'package:homiletics/theme/widgets.dart';

/// Opens what a share link decoded to: the preview of the study, or a
/// friendly error for a broken link or one from a newer app.
Future<void> openShareLinkResult(
    NavigatorState navigator, ShareLinkResult result) async {
  switch (result) {
    case ShareLinkSuccess(:final SharedStudy study):
      await navigator.push(MaterialPageRoute<void>(
        builder: (context) => ImportPreviewPage(study: study),
      ));
    case ShareLinkUnsupportedVersion():
      await _showLinkError(navigator.context, (l) => l.importNewerVersion);
    case ShareLinkInvalid():
      await _showLinkError(navigator.context, (l) => l.importInvalidLink);
  }
}

Future<void> _showLinkError(
    BuildContext context, String Function(AppLocalizations) message) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final AppLocalizations l = dialogContext.l10n;
      return AlertDialog(
        title: Text(l.importCouldNotOpenTitle),
        content: Text(message(l)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l.commonOk)),
        ],
      );
    },
  );
}

/// A read-only look at a shared study, with "Save a copy" (which always
/// makes new records, then opens them in the editor) and "Cancel".
class ImportPreviewPage extends StatefulWidget {
  final SharedStudy study;

  const ImportPreviewPage({Key? key, required this.study}) : super(key: key);

  @override
  State<ImportPreviewPage> createState() => _ImportPreviewPageState();
}

class _ImportPreviewPageState extends State<ImportPreviewPage> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l = context.l10n;
    try {
      final Widget editor = switch (widget.study) {
        SharedHomiletic study =>
          HomileticEditor(homiletic: await study.saveCopy()),
        SharedWordStudy study => WordStudyEditor(study: await study.saveCopy()),
      };
      notifyStudyDataChanged();
      if (!mounted) return;
      navigator.pushReplacement(
          MaterialPageRoute<void>(builder: (context) => editor));
      messenger.showSnackBar(SnackBar(
        content: Text(l.importSaved),
        action: SnackBarAction(onPressed: () {}, label: l.commonOk),
      ));
    } catch (error) {
      sendError(error, 'Import shared study');
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        content: Text(l.importSaveFailed),
        action: SnackBarAction(onPressed: () {}, label: l.commonOk),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final SharedStudy study = widget.study;
    final bool isHomiletic = study is SharedHomiletic;
    final String passage = study.passage.trim();
    final String? translation = study.translation?.trim();

    final List<Widget> body = switch (study) {
      SharedHomiletic h => _homileticSections(context, h),
      SharedWordStudy w => _wordStudySections(context, w),
    };

    return Scaffold(
      backgroundColor: c.ground,
      appBar: AppBar(
        backgroundColor: c.ground,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: l.commonCancel,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Overline(isHomiletic
                          ? l.importPreviewHomiletic
                          : l.importPreviewWordStudy),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                          passage.isEmpty ? l.pdfUntitledPassage : passage,
                          style: AppText.display.copyWith(color: c.ink)),
                    ),
                    if (translation != null && translation.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                        child: Text(
                            l.importPreviewTranslation(
                                translation.toUpperCase()),
                            style: AppText.caption.copyWith(color: c.muted)),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.accentTint,
                        borderRadius: BorderRadius.circular(AppRadius.tile),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: c.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(l.importPreviewNote,
                                style: AppText.caption.copyWith(color: c.ink)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (body.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                            isHomiletic
                                ? l.pdfEmptyHomiletic
                                : l.pdfEmptyWordStudy,
                            style: AppText.body.copyWith(color: c.muted)),
                      ),
                    for (int i = 0; i < body.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      body[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: c.surface,
            shape: Border(top: BorderSide(color: c.line)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        child: Text(l.commonCancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('importSaveCopy'),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.download_done_rounded, size: 18),
                        label: Text(l.importSaveCopy),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  static bool _has(String s) => s.trim().isNotEmpty;

  List<Widget> _homileticSections(BuildContext context, SharedHomiletic h) {
    final AppLocalizations l = context.l10n;
    final AppColors c = AppColors.of(context);
    final List<SharedRow> content =
        h.contentSummaries.where((r) => !r.isEmpty).toList();
    final List<SharedRow> divisions =
        h.divisions.where((r) => !r.isEmpty).toList();
    final List<String> applications = h.applications.where(_has).toList();
    return [
      if (content.isNotEmpty)
        _PreviewSection(
          step: StudyStep.content,
          title: StudyStep.content.localizedLabel(l),
          children: [
            for (final SharedRow r in content)
              _TintText(step: StudyStep.content, verses: r.verses, text: r.text)
          ],
        ),
      if (divisions.isNotEmpty)
        _PreviewSection(
          step: StudyStep.divisions,
          title: StudyStep.divisions.localizedLabel(l),
          children: [
            for (final SharedRow r in divisions)
              _TintText(
                  step: StudyStep.divisions, verses: r.verses, text: r.text)
          ],
        ),
      if (_has(h.subjectSentence))
        _PreviewSection(
          step: StudyStep.summary,
          title: StudyStep.summary.localizedLabel(l),
          children: [
            _TintText(step: StudyStep.summary, text: h.subjectSentence)
          ],
        ),
      if (_has(h.fcf))
        _PreviewSection(
          step: StudyStep.fcf,
          title: StudyStep.fcf.localizedLabel(l),
          children: [_TintText(step: StudyStep.fcf, text: h.fcf)],
        ),
      if (_has(h.aim))
        _PreviewSection(
          step: StudyStep.aim,
          title: StudyStep.aim.localizedLabel(l),
          children: [
            _TintText(
                step: StudyStep.aim,
                leadIn: l.pdfAimLeadIn,
                leadInColor: c.muted,
                text: h.aim)
          ],
        ),
      if (applications.isNotEmpty)
        _PreviewSection(
          step: StudyStep.application,
          title: StudyStep.application.localizedLabel(l),
          children: [
            for (final String a in applications)
              _TintText(step: StudyStep.application, text: a)
          ],
        ),
    ];
  }

  List<Widget> _wordStudySections(BuildContext context, SharedWordStudy w) {
    final AppLocalizations l = context.l10n;
    final AppColors c = AppColors.of(context);
    Widget section(StudyStep step, String title, String text) =>
        _PreviewSection(
            step: step,
            title: title,
            children: [_TintText(step: step, text: text.trim())]);
    return [
      if (_has(w.word))
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Overline(l.wordStudyWordTitle),
              const SizedBox(height: 4),
              Text(w.word.trim(),
                  style: AppText.display.copyWith(color: c.ink)),
            ],
          ),
        ),
      if (_has(w.definition))
        section(
            StudyStep.application, l.wordStudyDefinitionTitle, w.definition),
      if (_has(w.otherUsage))
        section(StudyStep.summary, l.wordStudyOtherUsageTitle, w.otherUsage),
      if (_has(w.contextualMeaning))
        section(StudyStep.fcf, l.wordStudyContextualMeaningTitle,
            w.contextualMeaning),
      if (_has(w.deeperMeaning))
        section(StudyStep.divisions, l.wordStudyDeeperMeaningTitle,
            w.deeperMeaning),
      if (_has(w.application))
        section(StudyStep.aim, l.wordStudyApplicationTitle, w.application),
    ];
  }
}

/// A read-only step card: done badge, serif title, then [children].
class _PreviewSection extends StatelessWidget {
  final StudyStep step;
  final String title;
  final List<Widget> children;

  const _PreviewSection(
      {required this.step, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            StepBadge(step: step, state: StudyStepState.done),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title,
                    style: TextStyle(
                        fontFamily: AppFonts.serif,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: c.ink)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Plain text on the step's tint, with an optional verse range in the
/// step color (like a row of the editor, but selectable instead of
/// editable).
class _TintText extends StatelessWidget {
  final StudyStep step;
  final String? verses;
  final String text;
  final String? leadIn;
  final Color? leadInColor;

  const _TintText({
    required this.step,
    required this.text,
    this.verses,
    this.leadIn,
    this.leadInColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final TextStyle style = AppText.body.copyWith(color: c.ink);
    final bool hasVerses = verses != null && verses!.trim().isNotEmpty;
    return StepTintBox(
      step: step,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasVerses) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40, maxWidth: 72),
              child: Text(verses!.trim(),
                  style: TextStyle(
                      fontFamily: AppFonts.serif,
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                      color: c.step(step))),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: SelectableText.rich(TextSpan(children: [
              if (leadIn != null)
                TextSpan(
                    text: leadIn,
                    style: style.copyWith(color: leadInColor ?? c.muted)),
              TextSpan(text: text.trim(), style: style),
            ])),
          ),
        ],
      ),
    );
  }
}
