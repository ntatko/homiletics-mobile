import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';
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

const String _readingStyleId = 'homiletics-reading-style';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Restyles Bible Gateway's print view to match the app's verse panel:
/// the panel's surface and ink, serif scripture, accent verse numbers.
/// Newsreader comes from Google Fonts when online; Georgia otherwise.
String _readingCss(AppColors c) => """
  @import url('https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,400;0,6..72,600;1,6..72,400&display=swap');
  html, body {
    background: ${_hex(c.surface)} !important;
    color: ${_hex(c.ink)} !important;
    margin: 0 !important;
    -webkit-text-size-adjust: 100%;
  }
  body { padding: 4px 18px 32px !important; }
  *, *::before, *::after {
    background-color: transparent !important;
    border-color: ${_hex(c.line)} !important;
    box-shadow: none !important;
  }
  .passage-text, .passage-text p, .passage-text span, .passage-text li,
  .passage-content, .passage-content p, .text, .poetry, .line {
    font-family: 'Newsreader', Georgia, serif !important;
    font-size: 18px !important;
    line-height: 1.6 !important;
    color: ${_hex(c.ink)} !important;
  }
  h1, h2, h3, h4, .passage-display-bcv, .dropdown-display-text {
    font-family: 'Newsreader', Georgia, serif !important;
    font-weight: 500 !important;
    color: ${_hex(c.ink)} !important;
  }
  h3, h4 { font-size: 15px !important; color: ${_hex(c.muted)} !important; }
  .versenum, .chapternum, sup.versenum, .verse-num, .verse-number {
    font-family: -apple-system, 'Roboto', sans-serif !important;
    font-size: 11px !important;
    font-weight: 600 !important;
    color: ${_hex(c.accent)} !important;
  }
  .chapternum { font-size: 22px !important; margin-right: 4px !important; }
  .footnotes, .crossrefs, .footnotes *, .crossrefs *,
  .publisher-info-bottom, .publisher-info-bottom * {
    font-family: -apple-system, 'Roboto', sans-serif !important;
    font-size: 12px !important;
    color: ${_hex(c.muted)} !important;
  }
  a, a * { color: ${_hex(c.accent)} !important; }
""";

class VerseContainerState extends State<VerseContainer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  AppColors _colors = AppColors.light;
  bool _colorsApplied = false;

  /// Hides the page until it has been restyled, so it never flashes in
  /// Bible Gateway's own colors.
  bool _styled = false;

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
    final AppColors colors = AppColors.of(context);
    if (!_colorsApplied || colors != _colors) {
      _colorsApplied = true;
      _colors = colors;
      _controller.setBackgroundColor(colors.surface);
      // Restyle an already-loaded page when the system theme changes.
      if (!_isLoading) _applyReadingStyle();
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
              _styled = false;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            _applyReadingStyle();
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

  /// Injects the reading stylesheet. Uses a fixed element id so repeated
  /// calls replace the style instead of stacking copies.
  Future<void> _applyReadingStyle() async {
    final css = _readingCss(_colors).replaceAll('`', '');
    final script = '''
      (function() {
        var style = document.getElementById('$_readingStyleId');
        if (!style) {
          style = document.createElement('style');
          style.id = '$_readingStyleId';
          (document.head || document.documentElement).appendChild(style);
        }
        style.innerHTML = `$css`;
      })();
    ''';
    try {
      await _controller.runJavaScript(script);
    } catch (_) {
      // Page may have navigated away or not be scriptable; styling is
      // re-applied on the next onPageFinished.
    }
    if (mounted && !_styled) setState(() => _styled = true);
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

  /// Re-applies the reading stylesheet (e.g. after a theme change).
  void applyDarkMode() {
    _applyReadingStyle();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: _styled ? 1 : 0,
          child: WebViewWidget(controller: _controller),
        ),
        if (!_styled)
          Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _colors.muted),
            ),
          ),
      ],
    );
  }
}
