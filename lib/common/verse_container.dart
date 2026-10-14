import 'dart:convert';

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

  /// Called when the translation button at the top of the passage is
  /// tapped. The button is drawn inside the page so it scrolls away with
  /// the text; without this callback it isn't shown.
  final VoidCallback? onTranslationTap;

  const VerseContainer(
      {Key? key,
      required this.passage,
      this.translation,
      this.onTranslationTap})
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
  #homiletics-reader-header {
    display: flex; align-items: center; justify-content: space-between;
    gap: 12px; padding: 12px 0 6px;
    font-family: -apple-system, 'Roboto', sans-serif !important;
  }
  #homiletics-reader-header .label {
    font-size: 11px; font-weight: 600; letter-spacing: 0.08em;
    text-transform: uppercase; color: ${_hex(c.muted)} !important;
  }
  #homiletics-reader-header button {
    display: inline-flex; align-items: center; gap: 2px;
    height: 30px; padding: 0 10px; border-radius: 8px;
    border: 1px solid ${_hex(c.line)} !important;
    background: transparent !important; color: ${_hex(c.ink)} !important;
    font: 500 12px -apple-system, 'Roboto', sans-serif;
  }
  #homiletics-reader-header button, #homiletics-reader-header button * {
    color: ${_hex(c.ink)} !important; fill: none !important;
    stroke: currentColor !important;
  }
  #homiletics-reader-header .short { stroke: none !important; }
  #homiletics-reader-header svg { width: 16px; height: 16px; }
  #homiletics-reader, .passage-text, .passage-content,
  .passage-content > div { margin-top: 0 !important; padding-top: 0 !important; }
  .passage-content > div > :first-child { margin-top: 4px !important; }
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

  /// Translation of the page being shown, for the in-page header.
  Translation _loadedTranslation = Preferences.translation;

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
      ..addJavaScriptChannel('HomileticsReader',
          onMessageReceived: (JavaScriptMessage message) {
        if (message.message == 'translation') {
          widget.onTranslationTap?.call();
        }
      })
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
    final Translation translation = _loadedTranslation;
    final String showHeader = jsonEncode(widget.onTranslationTap != null);
    final String translationName = jsonEncode(translation.name);
    final String translationShort = jsonEncode(translation.short);
    final script = '''
      (function() {
        var style = document.getElementById('$_readingStyleId');
        if (!style) {
          style = document.createElement('style');
          style.id = '$_readingStyleId';
          (document.head || document.documentElement).appendChild(style);
        }
        style.innerHTML = `$css`;
        // Keep only the scripture (and its copyright notice): the print
        // view still carries Bible Gateway's logo, menus and title table.
        var text = document.querySelector('.passage-text');
        if (text && !document.getElementById('homiletics-reader')) {
          var reader = document.createElement('div');
          reader.id = 'homiletics-reader';
          reader.appendChild(text);
          var notice = document.querySelector('.publisher-info-bottom');
          if (notice) reader.appendChild(notice);
          var keep = style;
          Array.prototype.slice.call(document.body.children).forEach(
            function (el) { if (el !== keep) el.remove(); });
          document.body.appendChild(reader);
        }
        var reader = document.getElementById('homiletics-reader');
        if (reader && $showHeader) {
          var header = document.getElementById('homiletics-reader-header');
          if (!header) {
            header = document.createElement('div');
            header.id = 'homiletics-reader-header';
            header.innerHTML = '<span class="label"></span>' +
              '<button type="button" aria-label="Change translation">' +
              '<span class="short"></span>' +
              '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" ' +
              'stroke-width="2" stroke-linecap="round" aria-hidden="true">' +
              '<path d="M7 10l5 5 5-5"/></svg></button>';
            header.querySelector('button').addEventListener('click',
              function () { HomileticsReader.postMessage('translation'); });
            reader.insertBefore(header, reader.firstChild);
          }
          header.querySelector('.label').textContent = $translationName;
          header.querySelector('.short').textContent = $translationShort;
        }
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
    _loadedTranslation = translation;
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
