import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:homiletics/common/report_error.dart';

/// Which on-device model will format a transcript.
enum FormatterBackend {
  /// Apple's built-in Foundation Models (iOS 26+, Apple Intelligence on).
  appleIntelligence,

  /// The downloadable Qwen model, run through flutter_gemma.
  localModel,

  /// Nothing available: not downloaded, or an unsupported platform.
  none,
}

/// Qwen2.5 1.5B Instruct is ungated on Hugging Face (Gemma models there
/// require accepting a license, so end users can't download them) and is
/// strong enough to fix punctuation and paragraphing without rewriting what
/// the speaker said. The "ekv4096" build gives a 4K-token context window.
const String _localModelUrl =
    'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.task';
const ModelType _localModelType = ModelType.qwen;
const String localModelSizeLabel = '~1.6GB';

/// Both backends have ~4K-token windows shared between prompt and response,
/// so ~350 words in (~470 tokens) leaves plenty of room for the rewrite.
const int _chunkWords = 350;

const String _instructions =
    'You format transcripts of Bible study lectures. You fix punctuation, '
    'capitalization and paragraph breaks. You never summarize, shorten, '
    'explain, or add anything of your own.';

String _promptFor(String chunk) => '''
Format this section of a lecture transcript.

Rules:
- Keep the speaker's words and their order. Do not summarize or add anything.
- Fix punctuation and capitalization.
- Remove filler words (um, uh, you know) and accidentally repeated words.
- Write scripture references in standard form, e.g. "Romans chapter eight verse twenty eight" becomes "Romans 8:28".
- Start a new paragraph when the speaker moves to a new thought. Separate paragraphs with a blank line.
- Reply with only the formatted text.

Transcript:
$chunk''';

/// Formats raw Whisper transcripts into readable paragraphs with an
/// on-device language model, preferring Apple Intelligence where it exists
/// (no download) and falling back to a downloadable Qwen model.
class TranscriptFormatterService {
  static const MethodChannel _appleChannel =
      MethodChannel('homiletics/foundation_models');

  static String get _localModelFileName =>
      Uri.parse(_localModelUrl).pathSegments.last;

  /// flutter_gemma's `.task` runtime is mobile-only.
  static bool get isLocalModelSupported => Platform.isAndroid || Platform.isIOS;

  /// Must run once before any other call touches flutter_gemma.
  static Future<void> initialize() async {
    if (!isLocalModelSupported) return;
    try {
      await FlutterGemma.initialize();
    } catch (error) {
      sendError(error, "TranscriptFormatterService.initialize");
    }
  }

  static Future<bool> isAppleIntelligenceAvailable() async {
    if (!Platform.isIOS) return false;
    try {
      return await _appleChannel.invokeMethod<String>('checkAvailability') ==
          'available';
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isLocalModelDownloaded() async {
    if (!isLocalModelSupported) return false;
    try {
      return await FlutterGemma.isModelInstalled(_localModelFileName);
    } catch (_) {
      return false;
    }
  }

  static Future<FormatterBackend> availableBackend() async {
    if (await isAppleIntelligenceAvailable()) {
      return FormatterBackend.appleIntelligence;
    }
    if (await isLocalModelDownloaded()) return FormatterBackend.localModel;
    return FormatterBackend.none;
  }

  /// Downloads the local model. Reports progress as 0.0-1.0.
  static Future<void> downloadLocalModel(
      {void Function(double progress)? onProgress}) async {
    await FlutterGemma.installModel(modelType: _localModelType)
        .fromNetwork(_localModelUrl)
        .withProgress((percent) => onProgress?.call(percent / 100))
        .install();
  }

  static Future<void> deleteLocalModel() async {
    if (!await isLocalModelDownloaded()) return;
    await FlutterGemma.uninstallModel(_localModelFileName);
  }

  /// Formats [transcript], reporting chunk progress via [onProgress].
  /// Returns null when no backend is available (including the local model
  /// having been deleted since [availableBackend]); it never starts a
  /// download itself. Chunks the model fails on
  /// (or mangles) are kept as the raw text, so the result is never missing
  /// part of the lecture.
  static Future<String?> format(String transcript,
      {void Function(int done, int total)? onProgress}) async {
    final FormatterBackend backend = await availableBackend();
    if (backend == FormatterBackend.none) return null;

    final List<String> chunks = chunkTranscript(transcript);
    final List<String> formatted = [];
    InferenceModel? localModel;
    try {
      if (backend == FormatterBackend.localModel) {
        // install() on an installed model skips the download and just marks
        // it active, which flutter_gemma doesn't remember across launches.
        // Re-check right before so a model deleted from Settings in the
        // meantime doesn't turn this into a silent 1.6GB download.
        if (!await isLocalModelDownloaded()) return null;
        await downloadLocalModel();
        localModel = await FlutterGemma.getActiveModel(maxTokens: 4096);
      }

      for (int i = 0; i < chunks.length; i++) {
        onProgress?.call(i, chunks.length);
        String? output;
        try {
          output = backend == FormatterBackend.appleIntelligence
              ? await _generateApple(chunks[i])
              : await _generateLocal(localModel!, chunks[i]);
        } catch (error) {
          sendError(error, "TranscriptFormatterService.format chunk");
        }
        formatted.add(acceptFormattedChunk(chunks[i], output));
      }
      onProgress?.call(chunks.length, chunks.length);
    } catch (error) {
      sendError(error, "TranscriptFormatterService.format");
      return null;
    } finally {
      await localModel?.close();
    }
    return formatted.join('\n\n');
  }

  static Future<String?> _generateApple(String chunk) {
    return _appleChannel.invokeMethod<String>('generate', {
      'prompt': _promptFor(chunk),
      'instructions': _instructions,
      'temperature': 0.2,
    });
  }

  static Future<String> _generateLocal(
      InferenceModel model, String chunk) async {
    final session = await model.createSession(
      temperature: 0.2,
      topK: 1,
      systemInstruction: _instructions,
    );
    try {
      await session
          .addQueryChunk(Message.text(text: _promptFor(chunk), isUser: true));
      return await session.getResponse();
    } finally {
      await session.close();
    }
  }
}

int _wordCount(String text) =>
    text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

/// Splits [transcript] into ~[_chunkWords]-word chunks, keeping existing
/// paragraphs together where possible and otherwise splitting on sentence
/// ends (or, for unpunctuated runs, every [_chunkWords] words).
List<String> chunkTranscript(String transcript) {
  // Each piece remembers its paragraph so pieces split out of one paragraph
  // are re-joined with a space rather than turned into new paragraphs.
  final List<({String text, int paragraph})> pieces = [];
  final List<String> paragraphs = transcript.split(RegExp(r'\n\s*\n'));
  for (int p = 0; p < paragraphs.length; p++) {
    final String paragraph = paragraphs[p].trim();
    if (paragraph.isEmpty) continue;
    if (_wordCount(paragraph) <= _chunkWords) {
      pieces.add((text: paragraph, paragraph: p));
      continue;
    }
    for (final String sentence in paragraph.split(RegExp(r'(?<=[.?!])\s+'))) {
      if (sentence.isEmpty) continue;
      final List<String> words = sentence.split(RegExp(r'\s+'));
      for (int i = 0; i < words.length; i += _chunkWords) {
        pieces.add((
          text: words.sublist(i, min(i + _chunkWords, words.length)).join(' '),
          paragraph: p,
        ));
      }
    }
  }

  final List<String> chunks = [];
  final StringBuffer current = StringBuffer();
  int currentWords = 0;
  int? currentParagraph;
  for (final piece in pieces) {
    final int words = _wordCount(piece.text);
    if (currentWords > 0 && currentWords + words > _chunkWords) {
      chunks.add(current.toString());
      current.clear();
      currentWords = 0;
      currentParagraph = null;
    }
    if (currentParagraph != null) {
      current.write(currentParagraph == piece.paragraph ? ' ' : '\n\n');
    }
    current.write(piece.text);
    currentWords += words;
    currentParagraph = piece.paragraph;
  }
  if (current.isNotEmpty) chunks.add(current.toString());
  return chunks;
}

/// Cleans up a model's response and returns it, or returns [raw] when the
/// response looks like the model summarized, rambled, or refused rather
/// than reformatting.
String acceptFormattedChunk(String raw, String? output) {
  if (output == null) return raw;
  String text = output.trim();
  // Strip code fences and "Here is the formatted text:" style preambles.
  text = text.replaceAll(RegExp(r'^```[a-z]*\s*|\s*```$'), '').trim();
  text = text
      .replaceFirst(
          RegExp(r'^(here is|here.s|sure|formatted)[^\n]*:\s*\n',
              caseSensitive: false),
          '')
      .trim();

  final int rawWords = _wordCount(raw);
  final int outWords = _wordCount(text);
  // Filler removal legitimately trims some words; losing more than a
  // quarter means content was dropped.
  if (rawWords == 0 ||
      outWords < rawWords * 0.75 ||
      outWords > rawWords * 1.2) {
    return raw;
  }
  return text;
}
