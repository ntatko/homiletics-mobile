import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows a bottom sheet with Bible Gateway search results for [word].
/// Tapping a result reference calls [onReferenceSelected] with just the
/// reference text (e.g. "Ephesians 2:8-9") -- the sheet never reads or
/// stores the verse body text itself, only the citation the user picks.
/// Stays open so multiple references can be picked; dismissed via "Done".
Future<void> showOtherUsageSearchSheet(
  BuildContext context, {
  required String word,
  required Translation translation,
  required void Function(String reference) onReferenceSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.card))),
    builder: (context) => _OtherUsageSearchSheet(
      word: word,
      translation: translation,
      onReferenceSelected: onReferenceSelected,
    ),
  );
}

const String _bridgeScript = '''
if (!window.__otherUsageBound) {
  window.__otherUsageBound = true;
  document.querySelectorAll('a.bible-item-title').forEach(function(el) {
    el.addEventListener('click', function(e) {
      e.preventDefault();
      OtherUsageChannel.postMessage(el.textContent.trim());
    });
  });
}
''';

class _OtherUsageSearchSheet extends StatefulWidget {
  final String word;
  final Translation translation;
  final void Function(String reference) onReferenceSelected;

  const _OtherUsageSearchSheet({
    required this.word,
    required this.translation,
    required this.onReferenceSelected,
  });

  @override
  State<_OtherUsageSearchSheet> createState() => _OtherUsageSearchSheetState();
}

class _OtherUsageSearchSheetState extends State<_OtherUsageSearchSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final List<String> _picked = [];

  @override
  void initState() {
    super.initState();
    final version = getBibleGatewayVersion(widget.translation);
    final url = Uri.parse('https://www.biblegateway.com/quicksearch/')
        .replace(queryParameters: {
      'search': widget.word.trim(),
      'version': version,
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'OtherUsageChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!mounted) return;
          final reference = message.message.trim();
          if (reference.isEmpty) return;
          widget.onReferenceSelected(reference);
          setState(() => _picked.add(reference));
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _controller.runJavaScript(_bridgeScript);
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color color = c.step(StudyStep.summary);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Overline('Other usage', color: color),
                          const SizedBox(height: 2),
                          Text(
                            'Where else \u201c${widget.word}\u201d appears',
                            style: AppText.title.copyWith(color: c.ink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(64, 44)),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              if (_picked.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Added',
                          style: AppText.caption.copyWith(color: c.muted)),
                      for (final String reference in _picked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.stepTint(StudyStep.summary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(reference,
                              style: AppText.caption.copyWith(
                                  color: color, fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Tap a result below to add its reference.',
                  style: AppText.caption.copyWith(color: c.muted),
                ),
              ),
              Divider(color: c.line),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: _controller,
                      // Claim drags right away; otherwise the bottom
                      // sheet's own drag-to-dismiss wins every vertical
                      // swipe and the results can't be scrolled.
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer()),
                      },
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
