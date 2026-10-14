import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VerseContainer extends StatefulWidget {
  final String passage;

  /// Explicit translation override. When null, the user's current
  /// [Preferences.translation] is used.
  final Translation? translation;

  const VerseContainer({Key? key, required this.passage, this.translation})
      : super(key: key);

  @override
  VerseContainerState createState() => VerseContainerState();
}

/// Maps translation codes to Bible Gateway version codes
String getBibleGatewayVersion(Translation translation) {
  switch (translation.code) {
    // Popular modern translations
    case 'niv':
      return 'NIV';
    case 'esv':
      return 'ESV';
    case 'nasb':
      return 'NASB';
    case 'nlt':
      return 'NLT';
    case 'nkjv':
      return 'NKJV';
    case 'csb':
      return 'CSB';
    case 'nrsv':
      return 'NRSV';
    case 'kjv':
      return 'KJV';
    case 'msg':
      return 'MSG';
    case 'amp':
      return 'AMP';
    case 'cev':
      return 'CEV';
    case 'ncv':
      return 'NCV';
    // Other translations
    case 'web':
      return 'WEB';
    case 'bbe':
      return 'BBE';
    case 'oeb-cw':
    case 'oeb-us':
      return 'OEB';
    case 'net':
      return 'NET';
    case 'asv':
      return 'ASV';
    default:
      return 'NIV'; // Default fallback
  }
}

/// Creates a Bible Gateway URL for the given passage and translation
String _createBibleGatewayUrl(String passage, Translation translation) {
  final encodedPassage = Uri.encodeComponent(passage);
  final version = getBibleGatewayVersion(translation);
  return 'https://www.biblegateway.com/passage/?search=$encodedPassage&version=$version&interface=print';
}

/// Hosts the passage view may navigate to in-app; everything else opens
/// externally.
bool _isBibleGatewayHost(String host) {
  final h = host.toLowerCase();
  return h == 'biblegateway.com' || h.endsWith('.biblegateway.com');
}

const String _darkModeStyleId = 'homiletics-dark-mode-style';

const String _darkModeCss = '''
  body {
    background-color: #1a1a1a !important;
    color: #e0e0e0 !important;
  }
  /* Target all text elements */
  p, div, span, td, th, li {
    color: #e0e0e0 !important;
    background-color: transparent !important;
  }
  /* Target all heading elements more aggressively */
  h1, h2, h3, h4, h5, h6,
  h1 *, h2 *, h3 *, h4 *, h5 *, h6 *,
  .passage-title, .passage-title *,
  .reference, .passage-reference,
  .reference *, .passage-reference * {
    color: #ffffff !important;
    background-color: transparent !important;
  }
  /* Target Bible Gateway specific elements */
  .passage-text, .passage, .text, .verse, .chapter,
  .passage-text *, .passage *, .text *, .verse *, .chapter * {
    color: #e0e0e0 !important;
    background-color: transparent !important;
  }
  /* Style verse numbers */
  .verse-num, .verse-number, .verse-num *, .verse-number * {
    color: #b0b0b0 !important;
  }
  /* Remove any white backgrounds from all elements */
  *, *::before, *::after {
    background-color: transparent !important;
  }
  /* Override any existing color styles */
  [style*="color"] {
    color: #e0e0e0 !important;
  }
  /* Style links */
  a, a * {
    color: #4a9eff !important;
  }
  a:visited, a:visited * {
    color: #8a4aff !important;
  }
''';

class VerseContainerState extends State<VerseContainer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isDarkMode = false;

  /// URL most recently requested, used to skip redundant reloads.
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (isDarkMode != _isDarkMode) {
      _isDarkMode = isDarkMode;
      // Restyle an already-loaded page when the system theme changes.
      if (!_isLoading) _applyDarkModeStyling();
    }
  }

  @override
  void didUpdateWidget(covariant VerseContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passage != widget.passage ||
        oldWidget.translation?.code != widget.translation?.code) {
      _loadPassage(widget.translation ?? Preferences.translation);
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            _applyDarkModeStyling();
          },
        ),
      );
    _loadPassage(widget.translation ?? Preferences.translation);
  }

  /// Keeps the web view on Bible Gateway; other links open externally.
  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    final isWeb = uri.scheme == 'https' || uri.scheme == 'http';
    if ((isWeb && _isBibleGatewayHost(uri.host)) ||
        (!request.isMainFrame && uri.toString() == 'about:blank')) {
      return NavigationDecision.navigate;
    }

    // Only user-visible (main frame) navigations are handed off; third-party
    // iframes (ads, trackers) are simply blocked.
    if (request.isMainFrame &&
        (isWeb || uri.scheme == 'mailto' || uri.scheme == 'tel')) {
      _launchExternally(uri);
    }
    return NavigationDecision.prevent;
  }

  Future<void> _launchExternally(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Nothing can handle the link; staying on the passage is fine.
    }
  }

  /// Injects (or removes) the dark-mode stylesheet. Uses a fixed element id
  /// so repeated calls replace the style instead of stacking copies.
  Future<void> _applyDarkModeStyling() async {
    final script = _isDarkMode
        ? '''
          (function() {
            var style = document.getElementById('$_darkModeStyleId');
            if (!style) {
              style = document.createElement('style');
              style.id = '$_darkModeStyleId';
              (document.head || document.documentElement).appendChild(style);
            }
            style.innerHTML = `$_darkModeCss`;
          })();
        '''
        : '''
          (function() {
            var style = document.getElementById('$_darkModeStyleId');
            if (style) style.remove();
          })();
        ''';
    try {
      await _controller.runJavaScript(script);
    } catch (_) {
      // Page may have navigated away or not be scriptable; styling is
      // re-applied on the next onPageFinished.
    }
  }

  void _loadPassage(Translation translation, {bool force = false}) {
    final url = _createBibleGatewayUrl(widget.passage, translation);
    if (!force && url == _loadedUrl) return;
    _loadedUrl = url;
    _controller.loadRequest(Uri.parse(url));
  }

  /// Reloads the passage using the user's *current* [Preferences.translation].
  ///
  /// Editors call this right after the preference changes, before their own
  /// rebuild has handed this widget the new [VerseContainer.translation], so
  /// the live preference is read here rather than the (possibly stale) widget
  /// value. The later rebuild then finds the same URL and does not reload
  /// again.
  void reloadPassage() {
    _loadPassage(Preferences.translation, force: true);
  }

  /// Public method to apply dark mode styling
  void applyDarkMode() {
    _applyDarkModeStyling();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
