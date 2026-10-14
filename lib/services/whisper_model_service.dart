import 'dart:async';
import 'dart:io';

import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

/// Whisper models this app offers. `base` trades a larger download
/// (~140MB) for meaningfully better accuracy than `tiny` on a full-length
/// lecture recording. English uses the English-only build (more accurate
/// for English); every other app language uses the multilingual one.
const WhisperModel kEnglishTranscriptionModel = WhisperModel.baseEn;
const WhisperModel kMultilingualTranscriptionModel = WhisperModel.base;

/// Every model [WhisperModelService] may download, for Settings.
const List<WhisperModel> kTranscriptionModels = [
  kEnglishTranscriptionModel,
  kMultilingualTranscriptionModel,
];

/// The model that transcribes lectures in [language].
WhisperModel whisperModelFor(Language language) =>
    language.locale.languageCode == 'en'
        ? kEnglishTranscriptionModel
        : kMultilingualTranscriptionModel;

/// Whisper's language code for [language] ('zh' for both Chinese scripts).
String whisperLanguageCode(Language language) => language.locale.languageCode;

/// Whisper imitates the style of its prompt, so a well-punctuated sentence
/// in the lecture's register nudges it toward proper sentences and Bible
/// vocabulary instead of run-on lowercase text. For Chinese the prompt is
/// also how the script is chosen: Whisper's `zh` output is often
/// Traditional unless the prompt is Simplified.
String whisperInitialPrompt(Language language) => switch (language.code) {
      'es' => 'Bienvenidos de nuevo a todos. Esta noche continuamos nuestro '
          'estudio de Romanos. Abran conmigo en el capítulo 8, versículo 28, '
          'donde Pablo escribe sobre el propósito de Dios para los que lo '
          'aman. ¿Están listos? ¡Comencemos!',
      'zh_Hans' => '以下是普通话的句子。欢迎大家回来。今晚我们继续学习罗马书。'
          '请和我一起翻到第8章第28节，保罗在这里写到神对爱祂之人的旨意。',
      'zh_Hant' => '以下是普通話的句子。歡迎大家回來。今晚我們繼續學習羅馬書。'
          '請和我一起翻到第8章第28節，保羅在這裡寫到神對愛祂之人的旨意。',
      'fr' => 'Bon retour à tous. Ce soir, nous poursuivons notre étude de '
          "l'épître aux Romains. Ouvrez avec moi au chapitre 8, verset 28, "
          "où Paul parle du dessein de Dieu pour ceux qui l'aiment.",
      'pt' => 'Bem-vindos de volta a todos. Esta noite continuamos o nosso '
          'estudo em Romanos. Abram comigo no capítulo 8, versículo 28, onde '
          'Paulo escreve sobre o propósito de Deus para aqueles que o amam.',
      'sw' => 'Karibuni tena nyote. Leo usiku tunaendelea na somo letu la '
          'Warumi. Fungueni pamoja nami sura ya 8, mstari wa 28, ambapo '
          'Paulo anaandika kuhusu kusudi la Mungu kwa wale wampendao.',
      _ => "Welcome back, everyone. Tonight we're continuing our study in "
          "Romans. Turn with me to chapter 8, verse 28, where Paul writes "
          "about God's purpose for those who love Him.",
    };

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
/// chunk boundaries. Chinese is measured by characters and ends sentences
/// with `。！？` (see [transcriptWordWeight]).
String paragraphsFromSegments(
    List<({String text, Duration from, Duration to})> segments) {
  final List<String> paragraphs = [];
  String current = '';
  double wordCount = 0;
  Duration? previousEnd;

  void flush() {
    final String text = current.trim();
    if (text.isNotEmpty) paragraphs.add(text);
    current = '';
    wordCount = 0;
  }

  for (final segment in segments) {
    final String text = segment.text.trim();
    if (text.isEmpty || text.startsWith('[')) continue; // [BLANK_AUDIO] etc.

    final bool longPause =
        previousEnd != null && segment.from - previousEnd >= _paragraphPause;
    final bool endsSentence = sentenceEndPattern.hasMatch(current.trim());
    if ((longPause && wordCount >= _minParagraphWords && endsSentence) ||
        (wordCount >= _maxParagraphWords && endsSentence) ||
        wordCount >= _hardMaxParagraphWords) {
      flush();
    }

    // No space between Chinese segments.
    current = joinTranscriptText(current, text);
    wordCount += transcriptWordWeight(text);
    previousEnd = segment.to;
  }
  flush();
  return paragraphs.join('\n\n');
}

/// Single shared place for downloading/deleting/using the on-device Whisper
/// models, so the Settings screen and the in-editor "download model?" prompt
/// share one implementation instead of two.
///
/// Each model is its own file. Calls that take an optional `model` default
/// to [requiredModel], the one for the app language at the time of the
/// call.
class WhisperModelService {
  static final WhisperController _controller = WhisperController();

  /// The model needed to transcribe in the current app language.
  static WhisperModel get requiredModel =>
      whisperModelFor(Preferences.effectiveLanguage);

  static Future<String> _modelFilePath(WhisperModel model) =>
      _controller.getPath(model);

  /// Whether [model] (default: [requiredModel]) is downloaded.
  static Future<bool> isModelDownloaded({WhisperModel? model}) async {
    return File(await _modelFilePath(model ?? requiredModel)).existsSync();
  }

  /// Size of the downloaded [model] file (default: [requiredModel]), or
  /// null if it isn't downloaded.
  static Future<int?> modelSizeBytes({WhisperModel? model}) async {
    final File file = File(await _modelFilePath(model ?? requiredModel));
    if (!file.existsSync()) return null;
    return file.lengthSync();
  }

  static final Map<WhisperModel, Future<void>> _inFlightDownloads = {};
  static final Map<WhisperModel, Set<void Function(double progress)>>
      _progressListeners = {};

  /// Whether any model download is currently running (from any caller).
  static bool get isDownloading => _inFlightDownloads.isNotEmpty;

  /// Whether [model]'s download is currently running (from any caller).
  static bool isDownloadingModel(WhisperModel model) =>
      _inFlightDownloads.containsKey(model);

  /// Downloads [model] (default: [requiredModel]) from Hugging Face if it
  /// isn't already present. Reports progress as 0.0-1.0 via [onProgress]
  /// when the response includes a content-length header. Concurrent
  /// callers (Settings and the editor prompt) share one download per
  /// model.
  static Future<void> downloadModel(
      {void Function(double progress)? onProgress, WhisperModel? model}) async {
    final WhisperModel target = model ?? requiredModel;
    final Set<void Function(double progress)> listeners =
        _progressListeners.putIfAbsent(target, () => {});
    if (onProgress != null) listeners.add(onProgress);
    final Future<void> download = _inFlightDownloads[target] ??=
        _download(target, listeners).whenComplete(() {
      _inFlightDownloads.remove(target);
      _progressListeners.remove(target);
    });
    try {
      await download;
    } finally {
      if (onProgress != null) listeners.remove(onProgress);
    }
  }

  /// Streams into `<model>.part` and only renames it into place once it's
  /// complete, so an interrupted download never looks like a downloaded
  /// model.
  static Future<void> _download(WhisperModel model,
      Set<void Function(double progress)> progressListeners) async {
    final File file = File(await _modelFilePath(model));
    if (file.existsSync()) return;
    await file.parent.create(recursive: true);
    final File partFile = File('${file.path}.part');
    if (partFile.existsSync()) await partFile.delete();

    final http.Client client = http.Client();
    IOSink? sink;
    try {
      final http.StreamedResponse response = await client
          .send(http.Request('GET', model.modelUri))
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
          for (final listener in progressListeners.toList()) {
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

  /// Deletes the downloaded [model] file (default: [requiredModel]) to free
  /// device storage. Safe to call when nothing is downloaded.
  static Future<void> deleteModel({WhisperModel? model}) async {
    final File file = File(await _modelFilePath(model ?? requiredModel));
    if (file.existsSync()) await file.delete();
  }

  /// Transcribes the audio file at [audioPath] in [language] (default: the
  /// app language at the time of the call), using that language's model.
  /// Returns null if that model isn't downloaded or transcription fails
  /// (errors are reported via [sendError], not thrown, since a failed
  /// transcription shouldn't be treated as fatal by callers).
  static Future<String?> transcribe(String audioPath,
      {void Function(int percent)? onProgress, Language? language}) async {
    final Language lang = language ?? Preferences.effectiveLanguage;
    final WhisperModel model = whisperModelFor(lang);
    if (!await isModelDownloaded(model: model)) return null;
    try {
      // A controller per call: WhisperController keeps the model path in a
      // field, so a shared one could race between two models.
      final result = await WhisperController().transcribe(
        model: model,
        audioPath: audioPath,
        lang: whisperLanguageCode(lang),
        initialPrompt: whisperInitialPrompt(lang),
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
    } finally {
      // whisper_ggml converts the recording to "<audioPath>.wav" (about
      // twice the recording's size) and leaves it behind.
      await _deleteQuietly(File('$audioPath.wav'));
    }
  }

  /// Removes conversion files left next to recordings by transcriptions
  /// from before [transcribe] cleaned up after itself. Cheap; safe to run
  /// on every launch.
  static Future<void> cleanUpConversionFiles() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      await for (final FileSystemEntity entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.m4a.wav')) {
          await _deleteQuietly(entity);
        }
      }
    } catch (error) {
      sendError(error, "WhisperModelService.cleanUpConversionFiles");
    }
  }

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best effort: a leftover file only costs space.
    }
  }
}
