import 'dart:async';
import 'dart:io';

import 'package:homiletics/common/report_error.dart';
import 'package:http/http.dart' as http;
import 'package:whisper_ggml/whisper_ggml.dart';

/// The one Whisper model this app offers. `base.en` trades a larger
/// download (~140MB) for meaningfully better accuracy than `tiny.en` on a
/// full-length lecture recording.
const WhisperModel kTranscriptionModel = WhisperModel.baseEn;

const String _initialPrompt =
    "Welcome back, everyone. Tonight we're continuing our study in Romans. "
    "Turn with me to chapter 8, verse 28, where Paul writes about God's "
    "purpose for those who love Him.";

/// A pause at least this long between Whisper segments is treated as a
/// likely paragraph break.
const Duration _paragraphPause = Duration(milliseconds: 1200);

/// Paragraphs shorter than this don't break on a pause (speakers pause
/// mid-thought all the time); paragraphs longer than [_maxParagraphWords]
/// break at the next sentence end regardless.
const int _minParagraphWords = 40;
const int _maxParagraphWords = 160;

/// Whisper sometimes emits long stretches with no sentence punctuation at
/// all; break those anyway so one paragraph can't swallow the lecture.
const int _hardMaxParagraphWords = 320;

/// No bytes for this long means the connection is dead.
const Duration _downloadStallTimeout = Duration(seconds: 60);
const Duration _downloadOverallTimeout = Duration(hours: 1);

/// Joins Whisper segments into paragraphs, breaking on long pauses and on
/// sentence ends once a paragraph gets long. Gives a readable transcript
/// even without the formatting model, and gives the formatter natural
/// chunk boundaries.
String paragraphsFromSegments(
    List<({String text, Duration from, Duration to})> segments) {
  final List<String> paragraphs = [];
  final StringBuffer current = StringBuffer();
  int wordCount = 0;
  Duration? previousEnd;

  void flush() {
    final String text = current.toString().trim();
    if (text.isNotEmpty) paragraphs.add(text);
    current.clear();
    wordCount = 0;
  }

  for (final segment in segments) {
    final String text = segment.text.trim();
    if (text.isEmpty || text.startsWith('[')) continue; // [BLANK_AUDIO] etc.

    final bool longPause =
        previousEnd != null && segment.from - previousEnd >= _paragraphPause;
    final bool endsSentence =
        RegExp(r'[.?!]["”’]?$').hasMatch(current.toString().trim());
    if ((longPause && wordCount >= _minParagraphWords && endsSentence) ||
        (wordCount >= _maxParagraphWords && endsSentence) ||
        wordCount >= _hardMaxParagraphWords) {
      flush();
    }

    if (current.isNotEmpty) current.write(' ');
    current.write(text);
    wordCount += text.split(RegExp(r'\s+')).length;
    previousEnd = segment.to;
  }
  flush();
  return paragraphs.join('\n\n');
}

/// Single shared place for downloading/deleting/using the on-device Whisper
/// model, so the Settings screen and the in-editor "download model?" prompt
/// share one implementation instead of two.
class WhisperModelService {
  static final WhisperController _controller = WhisperController();

  static Future<String> _modelFilePath() =>
      _controller.getPath(kTranscriptionModel);

  static Future<bool> isModelDownloaded() async {
    return File(await _modelFilePath()).existsSync();
  }

  /// Size of the downloaded model file, or null if it isn't downloaded.
  static Future<int?> modelSizeBytes() async {
    final File file = File(await _modelFilePath());
    if (!file.existsSync()) return null;
    return file.lengthSync();
  }

  static Future<void>? _inFlightDownload;
  static final Set<void Function(double progress)> _progressListeners = {};

  /// Whether a download is currently running (from any caller).
  static bool get isDownloading => _inFlightDownload != null;

  /// Downloads the model from Hugging Face if it isn't already present.
  /// Reports progress as 0.0-1.0 via [onProgress] when the response
  /// includes a content-length header. Concurrent callers (Settings and the
  /// editor prompt) share one download.
  static Future<void> downloadModel(
      {void Function(double progress)? onProgress}) async {
    if (onProgress != null) _progressListeners.add(onProgress);
    _inFlightDownload ??= _download().whenComplete(() {
      _inFlightDownload = null;
      _progressListeners.clear();
    });
    try {
      await _inFlightDownload;
    } finally {
      if (onProgress != null) _progressListeners.remove(onProgress);
    }
  }

  /// Streams into `<model>.part` and only renames it into place once it's
  /// complete, so an interrupted download never looks like a downloaded
  /// model.
  static Future<void> _download() async {
    final File file = File(await _modelFilePath());
    if (file.existsSync()) return;
    await file.parent.create(recursive: true);
    final File partFile = File('${file.path}.part');
    if (partFile.existsSync()) await partFile.delete();

    final http.Client client = http.Client();
    IOSink? sink;
    try {
      final http.StreamedResponse response = await client
          .send(http.Request('GET', kTranscriptionModel.modelUri))
          .timeout(_downloadStallTimeout);
      if (response.statusCode != 200) {
        throw Exception('Failed to download model: ${response.statusCode}');
      }

      final int total = response.contentLength ?? 0;
      int received = 0;
      final Stopwatch stopwatch = Stopwatch()..start();
      sink = partFile.openWrite();
      await for (final List<int> chunk
          in response.stream.timeout(_downloadStallTimeout)) {
        if (stopwatch.elapsed > _downloadOverallTimeout) {
          throw TimeoutException('Model download took too long');
        }
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) {
          for (final listener in _progressListeners.toList()) {
            listener(received / total);
          }
        }
      }
      await sink.close();
      sink = null;

      if (total > 0 && received != total) {
        throw Exception('Model download incomplete: $received of $total bytes');
      }
      await partFile.rename(file.path);
    } catch (_) {
      await sink?.close().catchError((_) {});
      if (partFile.existsSync()) await partFile.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Deletes the downloaded model file to free device storage. Safe to
  /// call when nothing is downloaded.
  static Future<void> deleteModel() async {
    final File file = File(await _modelFilePath());
    if (file.existsSync()) await file.delete();
  }

  /// Transcribes the audio file at [audioPath]. Returns null if the model
  /// isn't downloaded or transcription fails (errors are reported via
  /// [sendError], not thrown, since a failed transcription shouldn't be
  /// treated as fatal by callers).
  static Future<String?> transcribe(String audioPath,
      {void Function(int percent)? onProgress}) async {
    if (!await isModelDownloaded()) return null;
    try {
      final result = await _controller.transcribe(
        model: kTranscriptionModel,
        audioPath: audioPath,
        lang: 'en',
        // Whisper imitates the style of its prompt, so a well-punctuated
        // sentence in the lecture's register nudges it toward proper
        // sentences and Bible vocabulary instead of run-on lowercase text.
        initialPrompt: _initialPrompt,
        suppressNonSpeechTokens: true,
        withSegments: true,
        onProgress: onProgress,
      );
      if (result == null) return null;
      final segments = result.transcription.segments;
      if (segments == null || segments.isEmpty) {
        return result.transcription.text;
      }
      return paragraphsFromSegments(segments
          .map((s) => (text: s.text, from: s.fromTs, to: s.toTs))
          .toList());
    } catch (error) {
      sendError(error, "WhisperModelService.transcribe");
      return null;
    }
  }
}
