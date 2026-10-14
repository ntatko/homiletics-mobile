import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/common/web_view_scroll.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows a bottom sheet with Bible Gateway search results for [word].
/// Tapping a result reference calls [onReferenceSelected] with just the
/// reference text (e.g. "Ephesians 2:8-9") -- the sheet never reads or
/// stores the verse body text itself, only the citation the user picks.
/// Stays open so multiple references can be picked; dismissed via "Done".
///
/// Where there's no web view (Windows) the search opens in the browser
/// instead and the user types the references in themselves.
Future<void> showOtherUsageSearchSheet(
  BuildContext context, {
  required String word,
  required Translation translation,
  required void Function(String reference) onReferenceSelected,
}) async {
  if (!webViewSupported) {
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);
    final String opened = context.l10n.wordStudyOtherUsageOpenedInBrowser;
    final String failed = context.l10n.commonSomethingWentWrong;
    bool ok = false;
    try {
      ok = await launchUrl(_searchUrl(word, translation),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    messenger?.showSnackBar(SnackBar(content: Text(ok ? opened : failed)));
    return;
  }
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

/// Bible Gateway's search for [word] in [translation].
Uri _searchUrl(String word, Translation translation) =>
    Uri.parse('https://www.biblegateway.com/quicksearch/')
        .replace(queryParameters: {
      'search': word.trim(),
      'version': getBibleGatewayVersion(translation),
    });

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Turns Bible Gateway's search page into a plain list of results: the
/// results container is moved into its own wrapper and everything else
/// (header, menus, ads, footer) is hidden rather than removed, so the
/// page's own scripts can keep filling in results and pages. Taps on a
/// result title are caught with one delegated listener, so results added
/// after load still post their reference.
String _readerScript(AppColors c, Color accent, String addLabel) {
  final String css = """
    @import url('https://fonts.googleapis.com/css2?family=Newsreader:opsz,wght@6..72,400;6..72,600&display=swap');
    html, body { background: ${_hex(c.surface)} !important; margin: 0 !important; }
    body > *:not(#homiletics-results) { display: none !important; }
    #homiletics-results {
      padding: 0 16px 28px; color: ${_hex(c.ink)};
      font-family: -apple-system, 'Roboto', sans-serif;
    }
    #homiletics-results * {
      background: transparent !important; box-shadow: none !important;
      border-color: ${_hex(c.line)} !important;
    }
    #homiletics-results .search-tools input,
    #homiletics-results .mobile-search-controls,
    #homiletics-results .vote,
    #homiletics-results .vote-message,
    #homiletics-results .bible-item-extras,
    #homiletics-results ul.menu,
    #homiletics-results .sponsor-ad,
    #homiletics-results [class*="raptive"],
    #homiletics-results iframe,
    #homiletics-results ins,
    #homiletics-results .iv-pane-topical {
      display: none !important;
    }
    .search-result-heading, .search-result-heading .wrapper {
      font-size: 11px !important; font-weight: 600 !important;
      letter-spacing: 0.08em; text-transform: uppercase;
      color: ${_hex(c.muted)} !important; margin: 16px 0 0 !important;
    }
    .bible-item {
      display: block; padding: 14px 0 !important; margin: 0 !important;
      border-bottom: 1px solid ${_hex(c.line)} !important;
    }
    a.bible-item-title {
      font-family: 'Newsreader', Georgia, serif !important;
      font-size: 18px !important; font-weight: 600 !important;
      color: ${_hex(accent)} !important; text-decoration: none !important;
    }
    a.bible-item-title::after {
      content: ${jsonEncode(addLabel)}; margin-left: 10px; padding: 2px 9px;
      border: 1px solid ${_hex(accent)}; border-radius: 10px;
      font: 600 11px -apple-system, 'Roboto', sans-serif;
      vertical-align: 3px;
    }
    .bible-item-title-wrap + br { display: none; }
    .bible-item-text {
      display: block; margin-top: 4px;
      font-family: 'Newsreader', Georgia, serif !important;
      font-size: 15px !important; line-height: 1.5 !important;
      color: ${_hex(c.ink)} !important;
    }
    .bible-item-text b, .bible-item-text strong {
      background: ${_hex(c.highlight)} !important;
      color: ${_hex(c.ink)} !important; font-weight: 600;
      padding: 0 2px; border-radius: 3px;
    }
    .info-viewer-footer {
      display: flex !important; justify-content: space-between;
      gap: 12px; padding: 18px 0 8px;
    }
    .iv-prev-page a, .iv-next-page a {
      display: inline-block; padding: 11px 16px; border-radius: 12px;
      border: 1px solid ${_hex(c.lineStrong)} !important;
      color: ${_hex(c.ink)} !important; text-decoration: none !important;
      font-size: 14px; font-weight: 500;
    }
    .publisher-info, .publisher-info p, .publisher-info a {
      font-size: 11px !important; color: ${_hex(c.muted)} !important;
      font-weight: 400 !important;
    }
  """
      .replaceAll('`', '');
  return """
    (function() {
      var style = document.getElementById('homiletics-results-style');
      if (!style) {
        style = document.createElement('style');
        style.id = 'homiletics-results-style';
        (document.head || document.documentElement).appendChild(style);
      }
      style.innerHTML = `$css`;
      var results = document.querySelector('.results-container') ||
          document.querySelector('.search');
      if (results && !document.getElementById('homiletics-results')) {
        var wrapper = document.createElement('div');
        wrapper.id = 'homiletics-results';
        wrapper.appendChild(results);
        document.body.appendChild(wrapper);
      }
      if (!window.__otherUsageBound) {
        window.__otherUsageBound = true;
        document.addEventListener('click', function(e) {
          var link = e.target.closest && e.target.closest('a.bible-item-title');
          if (!link) return;
          e.preventDefault();
          e.stopPropagation();
          OtherUsageChannel.postMessage(link.textContent.trim());
        }, true);
      }
    })();
  """;
}

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

  /// Hides the page until it's been trimmed to the results list.
  bool _styled = false;
  final List<String> _picked = [];

  @override
  void initState() {
    super.initState();
    final url = _searchUrl(widget.word, widget.translation);

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
            setState(() {
              _isLoading = true;
              _styled = false;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _applyReader();
          },
        ),
      )
      ..loadRequest(url);
  }

  Future<void> _applyReader() async {
    final AppColors c = AppColors.of(context);
    setWebViewBackground(_controller, c.surface);
    try {
      await _controller.runJavaScript(_readerScript(
          c,
          c.step(StudyStep.summary),
          context.l10n.wordStudyOtherUsageAddResult));
    } catch (_) {
      // Page navigated away mid-script; the next onPageFinished re-applies.
    }
    if (mounted && !_styled) setState(() => _styled = true);
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
                          Overline(context.l10n.wordStudyOtherUsageTitle,
                              color: color),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n
                                .wordStudyOtherUsageSheetTitle(widget.word),
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
                      child: Text(context.l10n.commonDone),
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
                      Text(context.l10n.wordStudyOtherUsageAdded,
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
                  context.l10n.wordStudyOtherUsageInstructions,
                  style: AppText.caption.copyWith(color: c.muted),
                ),
              ),
              Divider(color: c.line),
              Expanded(
                child: Stack(
                  children: [
                    Opacity(
                      opacity: _styled ? 1 : 0,
                      child: WebViewScrollForwarder(
                        controller: _controller,
                        child: WebViewWidget(
                          controller: _controller,
                          // Claim drags right away; otherwise the bottom
                          // sheet's own drag-to-dismiss wins every vertical
                          // swipe and the results can't be scrolled.
                          gestureRecognizers: {
                            Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer()),
                          },
                        ),
                      ),
                    ),
                    if (_isLoading || !_styled)
                      Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: c.muted),
                        ),
                      ),
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
