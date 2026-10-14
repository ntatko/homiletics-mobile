import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// A font for a script the bundled PDF fonts (Newsreader, Public Sans,
/// Ubuntu) don't cover. These are too large to bundle (the Chinese ones are
/// 7-11 MB each), so they're downloaded the first time a handout needs one.
enum PdfScriptFont {
  /// Noto Sans SC: Simplified Chinese (also covers kana and most
  /// Traditional characters). Regular weight, about 10.5 MB.
  chineseSimplified(
    family: 'Noto Sans SC',
    fileName: 'NotoSansSC-Regular.ttf',
    url: 'https://fonts.gstatic.com/s/notosanssc/v41/'
        'k3kCo84MPvpLmixcA63oeAL7Iqp5IZJF9bmaG9_FnYw.ttf',
  ),

  /// Noto Sans TC: Traditional Chinese. Regular weight, about 7.1 MB.
  chineseTraditional(
    family: 'Noto Sans TC',
    fileName: 'NotoSansTC-Regular.ttf',
    url: 'https://fonts.gstatic.com/s/notosanstc/v40/'
        '-nFuOG829Oofr2wohFbTp9ifNAn722rq0MXz76Cy_Co.ttf',
  ),

  /// Noto Naskh Arabic. Regular weight, about 200 KB.
  arabic(
    family: 'Noto Naskh Arabic',
    fileName: 'NotoNaskhArabic-Regular.ttf',
    url: 'https://fonts.gstatic.com/s/notonaskharabic/v44/'
        'RrQ5bpV-9Dd1b1OAGA6M9PkyDuVBePeKNaxcsss0Y7bwvc5krA.ttf',
  );

  /// The Google Fonts family name, used to look up a fresh URL if the
  /// pinned [url] stops working.
  final String family;
  final String fileName;

  /// A static TrueType file on fonts.gstatic.com (as listed by the Google
  /// Fonts CSS API for a non-woff2 browser).
  final String url;

  const PdfScriptFont(
      {required this.family, required this.fileName, required this.url});
}

/// Whether [rune] is a Han ideograph, kana or CJK punctuation / full-width
/// form, i.e. something only a CJK font draws.
bool _isCjk(int rune) =>
    (rune >= 0x2E80 && rune <= 0x2FDF) || // radicals
    (rune >= 0x3000 && rune <= 0x30FF) || // CJK punctuation, kana
    (rune >= 0x3100 && rune <= 0x31FF) || // bopomofo, kana extensions
    (rune >= 0x3400 && rune <= 0x4DBF) || // extension A
    (rune >= 0x4E00 && rune <= 0x9FFF) || // unified ideographs
    (rune >= 0xF900 && rune <= 0xFAFF) || // compatibility ideographs
    (rune >= 0xFE30 && rune <= 0xFE4F) || // compatibility forms
    (rune >= 0xFF00 && rune <= 0xFFEF) || // full-width forms
    (rune >= 0x20000 && rune <= 0x3FFFF); // extensions B and later

bool _isArabic(int rune) =>
    (rune >= 0x0600 && rune <= 0x06FF) ||
    (rune >= 0x0750 && rune <= 0x077F) ||
    (rune >= 0x08A0 && rune <= 0x08FF) ||
    (rune >= 0xFB50 && rune <= 0xFDFF) ||
    (rune >= 0xFE70 && rune <= 0xFEFF);

/// The script fonts needed to draw [texts]. Chinese text gets the
/// Traditional font when [preferTraditional] (the app is in Traditional
/// Chinese), otherwise the Simplified one.
Set<PdfScriptFont> scriptFontsFor(Iterable<String> texts,
    {bool preferTraditional = false}) {
  bool cjk = false;
  bool arabic = false;
  for (final String text in texts) {
    for (final int rune in text.runes) {
      if (rune < 0x0600) continue; // Fast path for Latin, Greek, Cyrillic...
      cjk = cjk || _isCjk(rune);
      arabic = arabic || _isArabic(rune);
      if (cjk && arabic) break;
    }
    if (cjk && arabic) break;
  }
  return {
    if (cjk)
      preferTraditional
          ? PdfScriptFont.chineseTraditional
          : PdfScriptFont.chineseSimplified,
    if (arabic) PdfScriptFont.arabic,
  };
}

/// Downloads [PdfScriptFont]s on demand into the app support directory
/// (`pdf_fonts/`) and keeps them there for later exports.
class PdfFontService {
  /// Where fonts are kept; replaceable in tests.
  static Future<Directory> Function() directory = () async =>
      Directory('${(await getApplicationSupportDirectory()).path}/pdf_fonts');

  /// No bytes for this long means the connection is dead.
  static const Duration stallTimeout = Duration(seconds: 20);

  /// A font that takes longer than this is abandoned (the handout is made
  /// without it).
  static const Duration overallTimeout = Duration(minutes: 3);

  /// Anything smaller is not a real font file (e.g. an error page).
  static const int _minBytes = 50 * 1024;

  static final Map<PdfScriptFont, Future<Uint8List>> _inFlight = {};

  static Future<File> _file(PdfScriptFont font) async =>
      File('${(await directory()).path}/${font.fileName}');

  /// Whether [font] has already been downloaded.
  static Future<bool> isDownloaded(PdfScriptFont font) async =>
      (await _file(font)).existsSync();

  /// The bytes of [font], downloading it first if needed. Concurrent
  /// callers share one download. Throws if it can't be fetched.
  static Future<Uint8List> load(PdfScriptFont font) {
    return _inFlight[font] ??= _load(font).whenComplete(() {
      _inFlight.remove(font);
    });
  }

  /// Deletes a stored [font] (e.g. one that failed to parse) so the next
  /// [load] downloads it again.
  static Future<void> delete(PdfScriptFont font) async {
    final File file = await _file(font);
    if (file.existsSync()) await file.delete();
  }

  static Future<Uint8List> _load(PdfScriptFont font) async {
    final File file = await _file(font);
    if (file.existsSync()) return file.readAsBytes();
    await file.parent.create(recursive: true);

    final http.Client client = http.Client();
    try {
      try {
        await _download(client, Uri.parse(font.url), file)
            .timeout(overallTimeout);
      } on _NotFound {
        // Google bumps the version in the URL from time to time; ask the
        // CSS API for the current one.
        final Uri? fresh = await _currentUrl(client, font);
        if (fresh == null) rethrow;
        await _download(client, fresh, file).timeout(overallTimeout);
      }
    } finally {
      client.close();
    }
    return file.readAsBytes();
  }

  /// Streams [uri] into `<file>.part` and renames it into place only once
  /// it's complete, so an interrupted download never looks like a font.
  static Future<void> _download(http.Client client, Uri uri, File file) async {
    final File part = File('${file.path}.part');
    if (part.existsSync()) await part.delete();
    IOSink? sink;
    try {
      final http.StreamedResponse response =
          await client.send(http.Request('GET', uri)).timeout(stallTimeout);
      if (response.statusCode == 404 || response.statusCode == 410) {
        throw const _NotFound();
      }
      if (response.statusCode != 200) {
        throw HttpException('Font download failed: ${response.statusCode}',
            uri: uri);
      }
      // gstatic gzips fonts and the client unzips them, so Content-Length
      // (the compressed size) is only checked for an uncompressed body.
      final String encoding =
          response.headers['content-encoding']?.toLowerCase() ?? 'identity';
      final int? total = encoding == 'identity' ? response.contentLength : null;
      int received = 0;
      sink = part.openWrite();
      await for (final List<int> chunk
          in response.stream.timeout(stallTimeout)) {
        received += chunk.length;
        sink.add(chunk);
      }
      await sink.close();
      sink = null;
      if ((total != null && received != total) || received < _minBytes) {
        throw HttpException('Font download incomplete: $received bytes',
            uri: uri);
      }
      await part.rename(file.path);
    } catch (_) {
      await sink?.close().catchError((_) {});
      if (part.existsSync()) await part.delete();
      rethrow;
    }
  }

  /// Asks the Google Fonts CSS API for [font]'s current TrueType URL. An
  /// old browser user agent makes it answer with .ttf instead of woff2.
  static Future<Uri?> _currentUrl(
      http.Client client, PdfScriptFont font) async {
    final Uri css = Uri.https(
        'fonts.googleapis.com', '/css2', {'family': '${font.family}:wght@400'});
    final http.Response response = await client
        .get(css, headers: {'User-Agent': 'Mozilla/4.0'}).timeout(stallTimeout);
    if (response.statusCode != 200) return null;
    final Match? match =
        RegExp(r'url\((https://fonts\.gstatic\.com/[^)]+\.ttf)\)')
            .firstMatch(response.body);
    return match == null ? null : Uri.parse(match[1]!);
  }
}

class _NotFound implements Exception {
  const _NotFound();
}
