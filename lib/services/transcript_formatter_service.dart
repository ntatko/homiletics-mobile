import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
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
/// Chinese is measured at ~1.5 characters per word (see
/// [transcriptWordWeight]), i.e. ~525 characters per chunk.
const int _chunkWords = 350;

/// The transcript language's name in English, for the (English) prompt.
/// Naming it explicitly keeps small models from "helpfully" translating a
/// non-English transcript into English.
String _languageName(Language language) => switch (language.code) {
      'es' => 'Spanish',
      'zh_Hans' => 'Simplified Chinese',
      'zh_Hant' => 'Traditional Chinese',
      'fr' => 'French',
      'pt' => 'Portuguese',
      'sw' => 'Swahili',
      _ => 'English',
    };

/// A spoken-out scripture reference and its standard written form, in the
/// transcript's language.
String _scriptureExample(Language language) => switch (language.code) {
      'es' =>
        '"Romanos capítulo ocho versículo veintiocho" becomes "Romanos 8:28"',
      'zh_Hans' => '"罗马书第八章第二十八节" becomes "罗马书 8:28"',
      'zh_Hant' => '"羅馬書第八章第二十八節" becomes "羅馬書 8:28"',
      'fr' =>
        '"Romains chapitre huit verset vingt-huit" becomes "Romains 8:28"',
      'pt' =>
        '"Romanos capítulo oito versículo vinte e oito" becomes "Romanos 8:28"',
      'sw' =>
        '"Warumi sura ya nane mstari wa ishirini na nane" becomes "Warumi 8:28"',
      _ => '"Romans chapter eight verse twenty eight" becomes "Romans 8:28"',
    };

/// Extra rules for languages whose punctuation differs from English.
String _languageRules(Language language) => switch (language.code) {
      'es' =>
        '- Use Spanish punctuation, including the opening ¿ and ¡ marks.\n',
      'zh_Hans' => '- Write in Simplified Chinese characters; convert any '
          'Traditional characters to Simplified.\n'
          '- Use Chinese full-width punctuation (，。？！：；“”) and no spaces '
          'between Chinese characters.\n',
      'zh_Hant' => '- Write in Traditional Chinese characters; convert any '
          'Simplified characters to Traditional.\n'
          '- Use Chinese full-width punctuation (，。？！：；「」) and no spaces '
          'between Chinese characters.\n',
      'fr' => '- Use French punctuation and spacing conventions.\n',
      'pt' => '- Use Portuguese punctuation conventions.\n',
      _ => '',
    };

/// System instructions for formatting a transcript in [language].
@visibleForTesting
String formatterInstructions(Language language) {
  final String name = _languageName(language);
  return 'You format transcripts of Bible study lectures. You fix '
      'punctuation, capitalization and paragraph breaks. You never '
      'summarize, shorten, explain, or add anything of your own. The '
      'transcript is in $name: always reply in $name and never translate it.';
}

/// The user prompt for formatting [chunk], a piece of a transcript in
/// [language].
@visibleForTesting
String formatterPrompt(String chunk, Language language) {
  final String name = _languageName(language);
  return '''
Format this section of a lecture transcript. The transcript is in $name.

Rules:
- Keep the transcript in $name. Do not translate it.
- Keep the speaker's words and their order. Do not summarize or add anything.
- Fix punctuation and capitalization.
${_languageRules(language)}- Remove filler words (such as um, uh, you know, or their $name equivalents) and accidentally repeated words.
- Write scripture references in standard form, e.g. ${_scriptureExample(language)}.
- Start a new paragraph when the speaker moves to a new thought. Separate paragraphs with a blank line.
- Reply with only the formatted text, in $name.

Transcript:
$chunk''';
}

/// Formats raw Whisper transcripts into readable paragraphs with an
/// on-device language model, preferring Apple Intelligence where it exists
/// (no download) and falling back to a downloadable Qwen model.
class TranscriptFormatterService {
  static const MethodChannel _appleChannel =
      MethodChannel('homiletics/foundation_models');

  static String get _localModelFileName =>
      Uri.parse(_localModelUrl).pathSegments.last;

  /// flutter_gemma's `.task` runtime is mobile-only. On iOS it's limited to
  /// 16+: the app still runs on iPadOS 15 for older iPads, which don't have
  /// the memory for a 1.6GB model anyway.
  static bool get isLocalModelSupported =>
      Platform.isAndroid || (Platform.isIOS && iosMajorVersion() >= 16);

  /// The major version in an iOS [Platform.operatingSystemVersion] string
  /// (e.g. "Version 15.8.4 (Build 19H390)"), or 0 if there isn't one.
  @visibleForTesting
  static int iosMajorVersion([String? osVersion]) {
    final Match? match = RegExp(r'(\d+)\.')
        .firstMatch(osVersion ?? Platform.operatingSystemVersion);
    return match == null ? 0 : int.parse(match.group(1)!);
  }

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
  ///
  /// [language] is the transcript's language (defaults to the app
  /// language at the time of the call); the model is told to keep the text
  /// in that language and not translate it.
  static Future<String?> format(String transcript,
      {void Function(int done, int total)? onProgress,
      Language? language}) async {
    final Language lang = language ?? Preferences.effectiveLanguage;
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
              ? await _generateApple(chunks[i], lang)
              : await _generateLocal(localModel!, chunks[i], lang);
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

  static Future<String?> _generateApple(String chunk, Language language) {
    return _appleChannel.invokeMethod<String>('generate', {
      'prompt': formatterPrompt(chunk, language),
      'instructions': formatterInstructions(language),
      'temperature': 0.2,
    });
  }

  static Future<String> _generateLocal(
      InferenceModel model, String chunk, Language language) async {
    final session = await model.createSession(
      temperature: 0.2,
      topK: 1,
      systemInstruction: formatterInstructions(language),
    );
    try {
      await session.addQueryChunk(
          Message.text(text: formatterPrompt(chunk, language), isUser: true));
      return await session.getResponse();
    } finally {
      await session.close();
    }
  }
}

// ---------------------------------------------------------------------------
// Language-aware text measuring. Chinese (and Japanese) have no spaces
// between words, so "split on whitespace" would count a whole paragraph as
// one word. CJK characters are counted individually instead, at roughly
// 1.5 characters per word.

/// Ideographs and kana.
const String _cjkLetters = r'぀-ヿ㐀-䶿一-鿿豈-﫿';

/// CJK letters plus CJK/full-width punctuation: never separated by spaces.
const String _cjkWide = '$_cjkLetters' r'　-〿＀-￯';

const double _cjkCharsPerWord = 1.5;

final RegExp _cjkLetter = RegExp('[$_cjkLetters]');
final RegExp _cjkWideChar = RegExp('[$_cjkWide]');

/// One CJK character, or one run of non-space, non-CJK text (a word).
final RegExp _atom = RegExp('[$_cjkWide]|[^\\s$_cjkWide]+');

/// Sentence-ending punctuation (optionally followed by closing quotes or
/// brackets) at the end of a string. Covers Latin `.?!` (Spanish `¿…?` and
/// `¡…!` end the same way) and the full-width `。！？`.
final RegExp sentenceEndPattern = RegExp(r'[.?!…。！？]["”’»)）」』]*$');

/// Where a sentence ends inside a paragraph: Latin punctuation followed by
/// whitespace, or full-width punctuation followed by anything (Chinese
/// doesn't put a space after a sentence).
final RegExp _sentenceBreak =
    RegExp(r'([.?!…]["”’»)]*)\s+|([。！？][”’」』）"]*)\s*');

double _atomWeight(String atom) {
  if (_cjkLetter.hasMatch(atom)) return 1 / _cjkCharsPerWord;
  if (_cjkWideChar.hasMatch(atom)) return 0; // full-width punctuation
  return 1;
}

/// Approximate word count of [text], counting each CJK character as ~2/3
/// of a word so Chinese is measured comparably to space-separated
/// languages.
double transcriptWordWeight(String text) {
  double weight = 0;
  for (final Match m in _atom.allMatches(text)) {
    weight += _atomWeight(m[0]!);
  }
  return weight;
}

/// [transcriptWordWeight] rounded up to a whole number of words.
int transcriptWordCount(String text) => transcriptWordWeight(text).ceil();

/// Joins two pieces of running text with a space, except where either side
/// is CJK (Chinese doesn't separate words or sentences with spaces).
String joinTranscriptText(String a, String b) {
  if (a.isEmpty) return b;
  if (b.isEmpty) return a;
  final bool noSpace =
      _cjkWideChar.hasMatch(a[a.length - 1]) || _cjkWideChar.hasMatch(b[0]);
  return noSpace ? '$a$b' : '$a $b';
}

/// Splits a paragraph into sentences, keeping their punctuation.
List<String> _sentences(String paragraph) => paragraph
    .replaceAllMapped(_sentenceBreak, (m) => '${m[1] ?? m[2]}\u0000')
    .split('\u0000')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

/// Splits [sentence] into pieces of at most [maxWords] words (by
/// [transcriptWordWeight]), breaking between words or CJK characters.
List<String> _hardSplit(String sentence, int maxWords) {
  final List<String> pieces = [];
  String current = '';
  double weight = 0;
  for (final Match m in _atom.allMatches(sentence)) {
    final String atom = m[0]!;
    final double w = _atomWeight(atom);
    if (weight > 0 && weight + w > maxWords) {
      pieces.add(current);
      current = '';
      weight = 0;
    }
    current = joinTranscriptText(current, atom);
    weight += w;
  }
  if (current.isNotEmpty) pieces.add(current);
  return pieces;
}

/// Splits [transcript] into ~[_chunkWords]-word chunks, keeping existing
/// paragraphs together where possible and otherwise splitting on sentence
/// ends (or, for unpunctuated runs, every [_chunkWords] words). Chinese is
/// measured by characters (see [transcriptWordWeight]) and also splits on
/// `。！？`.
List<String> chunkTranscript(String transcript) {
  // Each piece remembers its paragraph so pieces split out of one paragraph
  // are re-joined (with a space, or nothing between Chinese) rather than
  // turned into new paragraphs.
  final List<({String text, int paragraph})> pieces = [];
  final List<String> paragraphs = transcript.split(RegExp(r'\n\s*\n'));
  for (int p = 0; p < paragraphs.length; p++) {
    final String paragraph = paragraphs[p].trim();
    if (paragraph.isEmpty) continue;
    if (transcriptWordWeight(paragraph) <= _chunkWords) {
      pieces.add((text: paragraph, paragraph: p));
      continue;
    }
    for (final String sentence in _sentences(paragraph)) {
      if (transcriptWordWeight(sentence) <= _chunkWords) {
        pieces.add((text: sentence, paragraph: p));
        continue;
      }
      for (final String piece in _hardSplit(sentence, _chunkWords)) {
        pieces.add((text: piece, paragraph: p));
      }
    }
  }

  final List<String> chunks = [];
  String current = '';
  double currentWords = 0;
  int? currentParagraph;
  for (final piece in pieces) {
    final double words = transcriptWordWeight(piece.text);
    if (currentWords > 0 && currentWords + words > _chunkWords) {
      chunks.add(current);
      current = '';
      currentWords = 0;
      currentParagraph = null;
    }
    if (currentParagraph == null) {
      current = piece.text;
    } else if (currentParagraph == piece.paragraph) {
      current = joinTranscriptText(current, piece.text);
    } else {
      current = '$current\n\n${piece.text}';
    }
    currentWords += words;
    currentParagraph = piece.paragraph;
  }
  if (current.isNotEmpty) chunks.add(current);
  return chunks;
}

/// Cleans up a model's response and returns it, or returns [raw] when the
/// response looks like the model summarized, rambled, or refused rather
/// than reformatting.
String acceptFormattedChunk(String raw, String? output) {
  if (output == null) return raw;
  String text = output.trim();
  // Strip code fences and "Here is the formatted text:" style preambles
  // (including common Spanish/French/Portuguese/Chinese ones).
  text = text.replaceAll(RegExp(r'^```[a-z]*\s*|\s*```$'), '').trim();
  text = text
      .replaceFirst(
          RegExp(
              r'^(here is|here.s|sure|formatted|aquí está|voici|aqui está|'
              r'以下是|这是|這是)[^\n]*[:：]\s*\n',
              caseSensitive: false),
          '')
      .trim();

  final double rawWords = transcriptWordWeight(raw);
  final double outWords = transcriptWordWeight(text);
  // Filler removal legitimately trims some words; losing more than a
  // quarter means content was dropped.
  if (rawWords == 0 ||
      outWords < rawWords * 0.75 ||
      outWords > rawWords * 1.2) {
    return raw;
  }
  // A Chinese chunk that comes back (mostly) without Chinese characters, or
  // the reverse, was translated rather than formatted.
  if ((_cjkShare(raw) - _cjkShare(text)).abs() > 0.5) return raw;
  return text;
}

/// The fraction of [text]'s word weight that is CJK characters.
double _cjkShare(String text) {
  final double total = transcriptWordWeight(text);
  if (total == 0) return 0;
  final int cjk = _cjkLetter.allMatches(text).length;
  return cjk / _cjkCharsPerWord / total;
}
