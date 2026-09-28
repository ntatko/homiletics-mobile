import 'package:flutter/material.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/verse_container.dart';
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
          final reference = message.message.trim();
          if (reference.isEmpty) return;
          widget.onReferenceSelected(reference);
          setState(() => _picked.add(reference));
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _controller.runJavaScript(_bridgeScript);
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Other places "${widget.word}" appears',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              if (_picked.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Added: ${_picked.join(", ")}',
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tap a result below to add its reference.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
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
