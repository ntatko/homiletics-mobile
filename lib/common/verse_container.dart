import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homiletics/common/bible_reference.dart';
import 'package:homiletics/components/bible/bible_passage_view.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/bible_text.dart';
import 'package:homiletics/services/bible_text_service.dart';
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

  /// Called with "4" (or "3:4" when the passage spans chapters) when a
  /// verse number is tapped. Without it verse numbers aren't tappable.
  final ValueChanged<String>? onVerseTap;

  /// Offline texts; tests pass their own.
  final BibleTextService? bibleTextService;

  const VerseContainer(
      {Key? key,
      required this.passage,
      this.translation,
      this.onTranslationTap,
      this.onVerseTap,
      this.bibleTextService})
      : super(key: key);

  @override
  VerseContainerState createState() => VerseContainerState();
}

/// The Bible Gateway version code for [translation], stored on the
/// translation itself (e.g. 'oeb-us' -> 'OEB', 'nvi-pt' -> 'NVI-PT').
/// A translation Bible Gateway doesn't host (an offline-only text) falls
/// back to its language's default there (e.g. Bíblia Livre -> NVI-PT).
String getBibleGatewayVersion(Translation translation) {
  final String code = translation.bibleGatewayCode;
  if (code.isNotEmpty) return code;
  final String fallback = Translation.webFallbackFor(translation.languageCode,
          scriptCode: translation.scriptCode)
      .bibleGatewayCode;
  return fallback.isEmpty ? 'NIV' : fallback;
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
  .homiletics-verse-tap .versenum, .homiletics-verse-tap .chapternum {
    cursor: pointer;
    padding: 6px 2px;
    margin: -6px 0;
  }
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

/// What the panel is showing.
enum _PanelMode {
  /// Working out whether an offline text can be used.
  resolving,

  /// The offline text, drawn natively.
  native,

  /// Bible Gateway in the web view.
  web,

  /// An offline-only translation that isn't downloaded yet.
  needsDownload,

  /// The web view couldn't load (no connection).
  offline,

  /// An offline-only translation that doesn't have this passage.
  notFound,
}

/// Matches Bible Gateway's per-verse class, e.g. "text Rom-3-4".
const String _verseClassPattern = r'(?:^|\s)([A-Za-z0-9]+)-(\d+)-(\d+)(?:\s|$)';

class VerseContainerState extends State<VerseContainer> {
  WebViewController? _controller;
  bool _isLoading = true;
  AppColors _colors = AppColors.light;
  bool _colorsApplied = false;

  /// Hides the page until it has been restyled, so it never flashes in
  /// Bible Gateway's own colors.
  bool _styled = false;

  /// URL most recently requested, used to skip redundant reloads.
  String? _loadedUrl;

  /// Translation of the passage being shown, for the in-page header.
  late Translation _loadedTranslation;

  _PanelMode _mode = _PanelMode.resolving;
  List<PassageChapter>? _chapters;
  String _copyright = '';

  /// Bumped on every resolve, so a slow load can't overwrite a newer one.
  int _generation = 0;

  BibleTextService get _service =>
      widget.bibleTextService ?? BibleTextService.instance;

  @override
  void initState() {
    super.initState();
    _loadedTranslation = widget.translation ?? Preferences.translation;
    _service.changes.addListener(_onServiceChanged);
    _resolve(_loadedTranslation);
  }

  @override
  void dispose() {
    _service.changes.removeListener(_onServiceChanged);
    super.dispose();
  }

  /// Translation this panel auto-downloaded while showing the web view;
  /// its arrival doesn't swap the text under the reader.
  String? _autoDownloadCode;

  void _onServiceChanged() {
    if (!mounted) return;
    final Translation t = _loadedTranslation;
    final bool nowDownloaded =
        _service.isDownloadedNow(t) == true && !_service.isDownloading(t);
    if (nowDownloaded &&
        _mode != _PanelMode.native &&
        _mode != _PanelMode.resolving &&
        !(_mode == _PanelMode.web && _autoDownloadCode == t.code)) {
      // Downloaded from the picker (or the download button): show it.
      _resolve(t);
      return;
    }
    // Progress / download state for the message views.
    if (_mode == _PanelMode.needsDownload || _mode == _PanelMode.offline) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppColors colors = AppColors.of(context);
    if (!_colorsApplied || colors != _colors) {
      _colorsApplied = true;
      _colors = colors;
      _controller?.setBackgroundColor(colors.surface);
      // Restyle an already-loaded page when the system theme changes.
      if (_mode == _PanelMode.web && !_isLoading) _applyReadingStyle();
    }
  }

  @override
  void didUpdateWidget(covariant VerseContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passage != widget.passage ||
        oldWidget.translation?.code != widget.translation?.code) {
      _resolve(widget.translation ?? Preferences.translation);
    }
  }

  /// Shows [translation]'s passage natively when its offline text is
  /// downloaded and the reference parses, else in the web view.
  Future<void> _resolve(Translation translation, {bool force = false}) async {
    final int generation = ++_generation;
    final String passage = widget.passage;
    _loadedTranslation = translation;

    if (translation.offlineAvailable) {
      final BibleText? text = await _service.load(translation);
      if (!mounted || generation != _generation) return;
      if (text != null) {
        final BibleReference? reference =
            BibleReference.parse(passage, extraNames: text.bookNames);
        final List<PassageChapter>? chapters =
            reference == null ? null : text.select(reference);
        if (chapters != null) {
          setState(() {
            _mode = _PanelMode.native;
            _chapters = chapters;
            _copyright = text.copyright;
          });
          return;
        }
        if (translation.offlineOnly) {
          setState(() => _mode = _PanelMode.notFound);
          return;
        }
      } else {
        _startAutoDownload(translation);
        if (translation.offlineOnly) {
          setState(() => _mode = _PanelMode.needsDownload);
          return;
        }
      }
    }
    // An offline-only text never reaches the web view (it has no Bible
    // Gateway code).
    if (!translation.webAvailable) {
      setState(() => _mode = _PanelMode.notFound);
      return;
    }
    _showWeb(translation, force: force);
  }

  /// First time this translation is shown without its offline text,
  /// fetch it in the background. Offline-only texts (and a web view that
  /// failed to load) switch to it as soon as it arrives; otherwise the
  /// web view stays until the next passage, so the text doesn't jump
  /// while being read.
  void _startAutoDownload(Translation translation) {
    if (!_service.isDownloading(translation)) {
      _autoDownloadCode = translation.code;
    }
    _service.autoDownload(translation).then((bool ok) {
      if (!ok || !mounted || _loadedTranslation.code != translation.code) {
        return;
      }
      if (_mode != _PanelMode.web) _resolve(translation);
    });
  }

  Future<void> _download() async {
    final Translation translation = _loadedTranslation;
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);
    final String failed = context.l10n.bibleDownloadFailed(translation.short);
    final bool ok = await _service.download(translation);
    if (!mounted) return;
    if (ok) {
      if (_loadedTranslation.code == translation.code) _resolve(translation);
    } else {
      messenger?.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  void _showWeb(Translation translation, {bool force = false}) {
    final bool wasWeb = _mode == _PanelMode.web;
    setState(() {
      _mode = _PanelMode.web;
      _chapters = null;
    });
    _ensureController();
    _loadPassage(translation, force: force || !wasWeb);
  }

  void _ensureController() {
    if (_controller != null) return;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(_colors.surface)
      ..addJavaScriptChannel('HomileticsReader',
          onMessageReceived: _onReaderMessage)
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
          onWebResourceError: (WebResourceError error) {
            if (!mounted || error.isForMainFrame == false) return;
            if (_mode != _PanelMode.web) return;
            setState(() => _mode = _PanelMode.offline);
          },
        ),
      );
  }

  void _onReaderMessage(JavaScriptMessage message) {
    final String m = message.message;
    if (m == 'translation') {
      widget.onTranslationTap?.call();
    } else if (m.startsWith('verse:')) {
      // verse:<chapter>:<verse>:<1 when the page spans chapters>
      final List<String> parts = m.split(':');
      if (parts.length != 4) return;
      final String reference =
          parts[3] == '1' ? '${parts[1]}:${parts[2]}' : parts[2];
      widget.onVerseTap?.call(reference);
    }
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
    final WebViewController? controller = _controller;
    if (controller == null) return;
    final css = _readingCss(_colors).replaceAll('`', '');
    final Translation translation = _loadedTranslation;
    final String showHeader = jsonEncode(widget.onTranslationTap != null);
    final String verseTap = jsonEncode(widget.onVerseTap != null);
    final String translationName = jsonEncode(translation.name);
    final String translationShort = jsonEncode(translation.short);
    final String changeLabel = jsonEncode(context.l10n.editorChangeTranslation);
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
              '<button type="button">' +
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
          header.querySelector('button').setAttribute('aria-label',
            $changeLabel);
        }
        // Tapping a verse (or chapter) number reports it to the app.
        document.body.classList.toggle('homiletics-verse-tap', $verseTap);
        if ($verseTap && !window.homileticsVerseTap) {
          window.homileticsVerseTap = true;
          var pattern = new RegExp('$_verseClassPattern');
          document.addEventListener('click', function (e) {
            if (!document.body.classList.contains('homiletics-verse-tap')) {
              return;
            }
            var num = e.target.closest && e.target.closest('.versenum, .chapternum');
            if (!num) return;
            var verse = num.closest('.text');
            var m = verse && pattern.exec(verse.className);
            if (!m) return;
            var chapters = {};
            document.querySelectorAll('.text').forEach(function (el) {
              var k = pattern.exec(el.className);
              if (k) chapters[k[1] + '-' + k[2]] = true;
            });
            var multi = Object.keys(chapters).length > 1 ? '1' : '0';
            e.preventDefault();
            HomileticsReader.postMessage(
              'verse:' + m[2] + ':' + (num.classList.contains('chapternum') ? '1' : m[3]) + ':' + multi);
          }, true);
        }
      })();
    ''';
    try {
      await controller.runJavaScript(script);
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
    _controller?.loadRequest(Uri.parse(url));
  }

  /// Reloads the passage using the user's *current* [Preferences.translation].
  ///
  /// Editors call this right after the preference changes, before their own
  /// rebuild has handed this widget the new [VerseContainer.translation], so
  /// the live preference is read here rather than the (possibly stale) widget
  /// value. The later rebuild then finds the same passage and translation
  /// and only re-resolves (cheap: the text is cached).
  void reloadPassage() {
    _resolve(Preferences.translation, force: true);
  }

  /// Re-applies the reading stylesheet (e.g. after a theme change).
  void applyDarkMode() {
    if (_mode == _PanelMode.web) _applyReadingStyle();
  }

  Widget _header() {
    final VoidCallback? onTap = widget.onTranslationTap;
    if (onTap == null) return const SizedBox.shrink();
    return BibleReaderHeader(
        name: _loadedTranslation.name,
        short: _loadedTranslation.short,
        onTap: onTap);
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String message,
    bool offerDownload = false,
    VoidCallback? onRetry,
  }) {
    final AppColors c = _colors;
    final AppLocalizations l = context.l10n;
    final Translation t = _loadedTranslation;
    final bool downloading = _service.isDownloading(t);
    final double? progress = _service.progress(t);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
      children: [
        _header(),
        const SizedBox(height: 20),
        Icon(icon, size: 28, color: c.muted),
        const SizedBox(height: 10),
        Text(title,
            textAlign: TextAlign.center,
            style: AppText.title.copyWith(fontSize: 18, color: c.ink)),
        const SizedBox(height: 6),
        Text(message,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: c.muted)),
        if (t.attribution != null && offerDownload) ...[
          const SizedBox(height: 8),
          Text(t.attribution!,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(fontSize: 12, color: c.muted)),
        ],
        const SizedBox(height: 16),
        if (offerDownload)
          Center(
            child: downloading
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      width: 160,
                      child: LinearProgressIndicator(
                          value: progress,
                          color: c.accent,
                          backgroundColor: c.surfaceSunken),
                    ),
                    const SizedBox(height: 8),
                    Text(l.bibleDownloading,
                        style: AppText.caption.copyWith(color: c.muted)),
                  ])
                : FilledButton.icon(
                    style:
                        FilledButton.styleFrom(minimumSize: const Size(44, 44)),
                    onPressed: _download,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: Text(l.bibleDownloadAction),
                  ),
          ),
        if (onRetry != null)
          Center(
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              onPressed: onRetry,
              child: Text(l.bibleTryAgain),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    final Translation t = _loadedTranslation;
    switch (_mode) {
      case _PanelMode.resolving:
        return _spinner();
      case _PanelMode.native:
        return BiblePassageView(
          key: ValueKey('${t.code} ${widget.passage}'),
          chapters: _chapters!,
          translationName: t.name,
          translationShort: t.short,
          copyright: _copyright,
          onTranslationTap: widget.onTranslationTap,
          onVerseTap: widget.onVerseTap,
        );
      case _PanelMode.needsDownload:
        return _message(
          icon: Icons.download_for_offline_outlined,
          title: l.bibleNeedsDownloadTitle(t.short),
          message:
              l.bibleNeedsDownloadMessage(formatBibleSize(t.offlineBytes ?? 0)),
          offerDownload: true,
        );
      case _PanelMode.notFound:
        if (widget.passage.trim().isEmpty) {
          return ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [_header()]);
        }
        return _message(
          icon: Icons.search_off_rounded,
          title: widget.passage,
          message: l.bibleNotInTranslation(t.name),
        );
      case _PanelMode.offline:
        return _message(
          icon: Icons.cloud_off_rounded,
          title: l.bibleOfflineTitle,
          message: t.offlineAvailable
              ? l.bibleOfflineMessage(t.short)
              : l.bibleOfflineNoDownloadMessage,
          offerDownload: t.offlineAvailable,
          onRetry: () => _resolve(t, force: true),
        );
      case _PanelMode.web:
        return Stack(
          children: [
            Opacity(
              opacity: _styled ? 1 : 0,
              child: WebViewWidget(controller: _controller!),
            ),
            if (!_styled) _spinner(),
          ],
        );
    }
  }

  Widget _spinner() => Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child:
              CircularProgressIndicator(strokeWidth: 2, color: _colors.muted),
        ),
      );
}
