import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/bible_text.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// The translation name + short-code button at the top of the passage
/// (scrolls away with the text, like the header injected into the web
/// view). Tapping the button opens preferences.
class BibleReaderHeader extends StatelessWidget {
  final String name;
  final String short;
  final VoidCallback onTap;

  const BibleReaderHeader(
      {Key? key, required this.name, required this.short, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Overline(name),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: context.l10n.editorChangeTranslation,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.line),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(short,
                            style: AppText.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: c.ink)),
                        const SizedBox(width: 2),
                        Icon(Icons.expand_more_rounded, size: 16, color: c.ink),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A passage from an offline Bible, drawn natively: serif scripture,
/// small accent verse numbers, a heading per chapter and the text's own
/// section headings, selectable text, and the licence line at the end.
///
/// With [onVerseTap], verse numbers are tappable and report "4" — or
/// "3:4" when [chapters] covers more than one chapter.
class BiblePassageView extends StatefulWidget {
  final List<PassageChapter> chapters;
  final String translationName;
  final String translationShort;
  final String copyright;
  final VoidCallback? onTranslationTap;
  final ValueChanged<String>? onVerseTap;

  const BiblePassageView({
    Key? key,
    required this.chapters,
    required this.translationName,
    required this.translationShort,
    required this.copyright,
    this.onTranslationTap,
    this.onVerseTap,
  }) : super(key: key);

  /// The reference a tap on [verse] in [chapter] reports.
  static String verseReference(
      int chapter, BibleVerse verse, bool spansChapters) {
    final String label = '${verse.number}';
    return spansChapters ? '$chapter:$label' : label;
  }

  @override
  State<BiblePassageView> createState() => _BiblePassageViewState();
}

class _BiblePassageViewState extends State<BiblePassageView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  bool get _spansChapters {
    final Set<String> seen = {
      for (final pc in widget.chapters) '${pc.book.id} ${pc.chapter.number}'
    };
    return seen.length > 1;
  }

  List<Widget> _chapterWidgets(
      PassageChapter pc, AppColors c, bool spansChapters) {
    final AppLocalizations l = context.l10n;
    final TextStyle scripture = AppText.scripture.copyWith(color: c.ink);
    final TextStyle number = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11,
        height: 1,
        fontWeight: FontWeight.w600,
        color: c.accent);
    final List<Widget> out = [
      Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(pc.title,
            style: AppText.title.copyWith(fontSize: 19, color: c.ink)),
      ),
    ];

    List<InlineSpan> spans = [];
    bool poetry = false;
    void flush() {
      if (spans.isEmpty) return;
      out.add(Padding(
        padding: EdgeInsets.only(top: 6, left: poetry ? 14 : 0),
        child: Text.rich(TextSpan(children: spans), style: scripture),
      ));
      spans = [];
      poetry = false;
    }

    bool first = true;
    for (final BibleVerse v in pc.verses) {
      final List<BibleHeading> headings =
          pc.chapter.headings.where((h) => h.beforeVerse == v.number).toList();
      if (headings.isNotEmpty) {
        flush();
        for (final BibleHeading h in headings) {
          out.add(Padding(
            padding: EdgeInsets.only(top: h.description ? 6 : 12),
            child: Text(h.text,
                style: h.description
                    ? scripture.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: c.muted)
                    : scripture.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.muted)),
          ));
        }
      } else if (!first && pc.chapter.paragraphStarts.contains(v.number)) {
        flush();
      }
      final bool lineStart = pc.chapter.lineStarts.contains(v.number);
      if (v.text.contains('\n') || lineStart) poetry = true;
      if (spans.isNotEmpty && lineStart) {
        spans.add(const TextSpan(text: '\n'));
      }

      final String ref =
          BiblePassageView.verseReference(pc.chapter.number, v, spansChapters);
      TapGestureRecognizer? recognizer;
      if (widget.onVerseTap != null) {
        recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onVerseTap?.call(ref);
        _recognizers.add(recognizer);
      }
      spans.add(TextSpan(
        text: '${v.label} ',
        style: number,
        recognizer: recognizer,
        mouseCursor:
            recognizer != null ? SystemMouseCursors.click : MouseCursor.defer,
        semanticsLabel:
            recognizer != null ? l.bibleVerseTapLabel(ref) : v.label,
      ));
      spans.add(TextSpan(text: '${v.text} '));
      first = false;
    }
    flush();
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    _disposeRecognizers();
    final bool spansChapters = _spansChapters;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
      children: [
        if (widget.onTranslationTap != null)
          BibleReaderHeader(
              name: widget.translationName,
              short: widget.translationShort,
              onTap: widget.onTranslationTap!),
        SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final PassageChapter pc in widget.chapters)
                ..._chapterWidgets(pc, c, spansChapters),
              if (widget.copyright.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(widget.copyright,
                      style: AppText.caption
                          .copyWith(fontSize: 12, color: c.muted)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
