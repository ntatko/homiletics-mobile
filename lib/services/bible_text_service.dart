import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show ValueNotifier, compute;
import 'package:hive/hive.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/services/bible_text.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the offline texts built by tool/build_bibles.py are published
/// (same repository as the suggested passages).
const String kBibleDataBaseUrl =
    'https://raw.githubusercontent.com/ntatko/homiletics-mobile/refs/heads/main/data/bibles/';

/// Downloads, stores and loads the offline Bible texts
/// (data/bibles/<code>.json.gz) in the app support directory.
///
/// Files are only ever renamed into place after they downloaded completely
/// and decoded, so a file that exists is a usable Bible.
class BibleTextService {
  BibleTextService({
    Future<Directory> Function()? directory,
    http.Client Function()? client,
    this.baseUrl = kBibleDataBaseUrl,
    Future<BibleText> Function(List<int> bytes)? decoder,
    this.timeout = const Duration(seconds: 60),
    this.minBytes = 100 * 1024,
    this.maxBytes = 20 * 1024 * 1024,
  })  : _directory = directory ?? _defaultDirectory,
        _client = client ?? http.Client.new,
        _decoder = decoder ?? _decodeInBackground;

  /// The app-wide instance.
  static BibleTextService instance = BibleTextService();

  /// Downloads above this are refused (the real files are ~1.3 MB).
  final int maxBytes;

  /// Anything this small is an error page, not a Bible.
  final int minBytes;

  final String baseUrl;
  final Duration timeout;
  final Future<Directory> Function() _directory;
  final http.Client Function() _client;
  final Future<BibleText> Function(List<int> bytes) _decoder;

  /// Bumped whenever a download starts, progresses, finishes or is
  /// deleted, so pickers and the verse panel can rebuild.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Set<String>? _downloaded;
  final Map<String, double?> _progress = {};
  final Map<String, Future<bool>> _inFlight = {};
  final Set<String> _autoTried = {};

  /// One decoded text is kept in memory (they are a few MB each).
  BibleText? _cached;

  static Future<Directory> _defaultDirectory() async {
    final Directory support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'bibles'));
  }

  static Future<BibleText> _decodeInBackground(List<int> bytes) =>
      compute(BibleText.decodeGzip, bytes);

  Future<File> _file(String code) async =>
      File(p.join((await _directory()).path, '$code.json.gz'));

  Future<Set<String>> _scan() async {
    if (_downloaded != null) return _downloaded!;
    final Set<String> found = {};
    try {
      final Directory dir = await _directory();
      if (await dir.exists()) {
        await for (final FileSystemEntity e in dir.list()) {
          final String name = p.basename(e.path);
          if (e is File && name.endsWith('.json.gz')) {
            found.add(name.substring(0, name.length - '.json.gz'.length));
          }
        }
      }
    } catch (_) {
      // No storage: nothing is downloaded.
    }
    return _downloaded = found;
  }

  void _notify() => changes.value++;

  Future<bool> isDownloaded(Translation t) async =>
      t.offlineAvailable && (await _scan()).contains(t.code);

  /// Synchronous answer once the directory has been scanned (null before).
  bool? isDownloadedNow(Translation t) => _downloaded?.contains(t.code);

  bool isDownloading(Translation t) => _inFlight.containsKey(t.code);

  /// 0..1 while downloading with a known size, else null.
  double? progress(Translation t) => _progress[t.code];

  /// Size on disk of a downloaded text, or null.
  Future<int?> downloadedSize(Translation t) async {
    if (!await isDownloaded(t)) return null;
    try {
      return await (await _file(t.code)).length();
    } catch (_) {
      return null;
    }
  }

  /// The downloaded text for [t], or null when it isn't downloaded (or the
  /// file turned out unreadable, in which case it is removed).
  Future<BibleText?> load(Translation t) async {
    if (!await isDownloaded(t)) return null;
    final BibleText? cached = _cached;
    if (cached != null && cached.code == t.code) return cached;
    try {
      final List<int> bytes = await (await _file(t.code)).readAsBytes();
      final BibleText text = await _decoder(bytes);
      _cached = text;
      return text;
    } catch (_) {
      await delete(t);
      return null;
    }
  }

  /// Downloads [t]'s text. Concurrent calls share one download. Returns
  /// whether the text is now available.
  Future<bool> download(Translation t) {
    if (!t.offlineAvailable) return Future.value(false);
    return _inFlight[t.code] ??= _download(t).whenComplete(() {
      _inFlight.remove(t.code);
      _progress.remove(t.code);
      _notify();
    });
  }

  /// Downloads [t] in the background the first time it's needed in this
  /// session (not again after a failure until the app restarts).
  /// The files are ~1.3 MB, smaller than a single Bible Gateway page with
  /// its scripts, so this doesn't wait for Wi-Fi.
  Future<bool> autoDownload(Translation t) async {
    if (!t.offlineAvailable || await isDownloaded(t)) return false;
    if (!_autoTried.add(t.code)) {
      return _inFlight[t.code] ?? Future.value(false);
    }
    return download(t);
  }

  Future<bool> _download(Translation t) async {
    _progress[t.code] = null;
    _notify();
    final http.Client client = _client();
    File? part;
    try {
      final Directory dir = await _directory();
      await dir.create(recursive: true);
      final File target = await _file(t.code);
      part = File('${target.path}.part');
      final http.StreamedResponse response = await client
          .send(http.Request('GET', Uri.parse('$baseUrl${t.code}.json.gz')))
          .timeout(timeout);
      if (response.statusCode != 200) return false;
      final int? total = response.contentLength;
      if (total != null && total > maxBytes) return false;

      final BytesBuilder builder = BytesBuilder(copy: false);
      final Completer<void> done = Completer<void>();
      late final StreamSubscription<List<int>> sub;
      sub = response.stream.timeout(timeout).listen(
        (chunk) {
          builder.add(chunk);
          if (builder.length > maxBytes) {
            sub.cancel();
            if (!done.isCompleted) {
              done.completeError(const FileSystemException('Too large'));
            }
            return;
          }
          if (total != null && total > 0) {
            _progress[t.code] = (builder.length / total).clamp(0.0, 1.0);
            _notify();
          }
        },
        onError: (Object e) {
          if (!done.isCompleted) done.completeError(e);
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
        cancelOnError: true,
      );
      await done.future;
      final Uint8List bytes = builder.takeBytes();
      if (bytes.length < minBytes) return false;

      // Only a file that decodes into this translation is kept.
      final BibleText text = await _decoder(bytes);
      if (text.code != t.code) return false;

      await part.writeAsBytes(bytes, flush: true);
      await part.rename(target.path);
      (await _scan()).add(t.code);
      _cached = text;
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close();
      try {
        if (part != null && await part.exists()) await part.delete();
      } catch (_) {}
    }
  }

  /// Removes [t]'s downloaded text.
  Future<void> delete(Translation t) async {
    try {
      final File f = await _file(t.code);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Already gone.
    }
    (await _scan()).remove(t.code);
    if (_cached?.code == t.code) _cached = null;
    _notify();
  }
}

/// "1.3 MB" for a byte count.
String formatBibleSize(int bytes) {
  final double mb = bytes / (1024 * 1024);
  return mb >= 10 ? '${mb.round()} MB' : '${mb.toStringAsFixed(1)} MB';
}

/// Remembers whether the user has tapped a verse number to start a content
/// summary, so the tip about it stops showing afterwards.
class VerseTapTip {
  static const String _boxKey = 'user';
  static const String _key = 'hasUsedVerseTap';
  static bool _usedThisSession = false;

  static bool get hasUsed {
    if (_usedThisSession) return true;
    if (!Hive.isBoxOpen(_boxKey)) return false;
    return Hive.box(_boxKey).get(_key) == true;
  }

  static void markUsed() {
    _usedThisSession = true;
    if (Hive.isBoxOpen(_boxKey)) Hive.box(_boxKey).put(_key, true);
  }
}
