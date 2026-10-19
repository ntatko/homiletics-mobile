import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';

String words(int n, [String word = 'word']) => List.filled(n, word).join(' ');

({String text, Duration from, Duration to}) seg(
        String text, int fromMs, int toMs) =>
    (
      text: text,
      from: Duration(milliseconds: fromMs),
      to: Duration(milliseconds: toMs)
    );

void main() {
  group('paragraphsFromSegments', () {
    test('breaks on a long pause once the paragraph is long enough', () {
      final result = paragraphsFromSegments([
        seg('${words(45)}.', 0, 10000),
        seg('Next thought.', 12000, 13000),
      ]);
      expect(result.split('\n\n'), hasLength(2));
    });

    test('does not break on a pause in a short paragraph', () {
      final result = paragraphsFromSegments([
        seg('Short opener.', 0, 1000),
        seg('Still the same thought.', 3000, 4000),
      ]);
      expect(result, 'Short opener. Still the same thought.');
    });

    test('does not break mid-sentence even on a pause', () {
      final result = paragraphsFromSegments([
        seg(words(45), 0, 10000),
        seg('continues here.', 12000, 13000),
      ]);
      expect(result.split('\n\n'), hasLength(1));
    });

    test('breaks a long run with no sentence punctuation', () {
      final result = paragraphsFromSegments(
          List.generate(20, (i) => seg(words(30), i * 1000, i * 1000 + 900)));
      final paragraphs = result.split('\n\n');
      expect(paragraphs.length, greaterThan(1));
      for (final paragraph in paragraphs) {
        expect(paragraph.split(' ').length, lessThanOrEqualTo(350));
      }
      expect(result.split(RegExp(r'\s+')), hasLength(600));
    });

    test('drops non-speech markers', () {
      final result = paragraphsFromSegments([
        seg('[BLANK_AUDIO]', 0, 1000),
        seg('Hello.', 1000, 2000),
      ]);
      expect(result, 'Hello.');
    });
  });

  group('chunkTranscript', () {
    test('keeps paragraphs together up to the chunk size', () {
      final chunks =
          chunkTranscript('${words(200)}.\n\n${words(100)}.\n\n${words(200)}.');
      expect(chunks, hasLength(2));
      expect(chunks.first.split('\n\n'), hasLength(2));
    });

    test('splits an oversized paragraph on sentence ends', () {
      final paragraph = List.generate(10, (_) => '${words(59)} end.').join(' ');
      final chunks = chunkTranscript(paragraph);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.trim(), endsWith('end.'));
      }
    });

    test('re-joins sentences of one paragraph with a space', () {
      final paragraph = List.generate(10, (_) => '${words(59)} end.').join(' ');
      for (final chunk in chunkTranscript(paragraph)) {
        expect(chunk, isNot(contains('\n')));
      }
    });

    test('keeps paragraph breaks between different paragraphs', () {
      final chunks =
          chunkTranscript('${words(500, 'a')}.\n\n${words(10, 'b')}.');
      expect(chunks.last, contains('\n\nb'));
    });

    test('hard-splits an oversized run with no punctuation', () {
      final chunks = chunkTranscript(words(1000));
      expect(chunks, hasLength(3));
      for (final chunk in chunks) {
        expect(chunk.split(' ').length, lessThanOrEqualTo(350));
      }
      expect(chunks.join(' ').split(' '), hasLength(1000));
    });

    test('loses no words', () {
      final text = '${words(500, 'a')}.\n\n${words(120, 'b')}.';
      final rejoined = chunkTranscript(text).join(' ');
      expect(RegExp(r'\b[ab]\b').allMatches(rejoined), hasLength(620));
    });
  });

  group('acceptFormattedChunk', () {
    final raw = words(100);

    test('keeps a faithful rewrite', () {
      final out = 'Word ${words(94)}.\n\n${words(5)}.';
      expect(acceptFormattedChunk(raw, out), out);
    });

    test('strips preambles and code fences', () {
      final body = words(100);
      expect(acceptFormattedChunk(raw, 'Here is the formatted text:\n$body'),
          body);
      expect(acceptFormattedChunk(raw, '```\n$body\n```'), body);
    });

    test('falls back to raw when the model summarizes', () {
      expect(acceptFormattedChunk(raw, words(40)), raw);
    });

    test('falls back to raw when the model rambles', () {
      expect(acceptFormattedChunk(raw, words(150)), raw);
    });

    test('falls back to raw on failure', () {
      expect(acceptFormattedChunk(raw, null), raw);
    });
  });

  group('Chinese', () {
    // 28 characters and a full stop, no spaces (~19 "words").
    const String sentence = '我们今天继续学习罗马书保罗写到神的旨意因为爱神的人得益处。';

    test('counts CJK characters, not whitespace runs', () {
      expect(transcriptWordCount('罗马书八章'), 4); // 5 chars / 1.5, rounded up
      expect(transcriptWordCount('我们 Romans 8:28'), 4);
      expect(transcriptWordWeight('。，？！'), 0);
    });

    test('splits an unspaced paragraph into several chunks', () {
      final String paragraph = sentence * 60; // ~1700 characters
      final chunks = chunkTranscript(paragraph);
      expect(chunks.length, greaterThan(2));
      for (final chunk in chunks) {
        expect(transcriptWordWeight(chunk), lessThanOrEqualTo(350));
        expect(chunk, endsWith('。'));
        expect(chunk, isNot(contains(' ')));
        expect(chunk, isNot(contains('\n')));
      }
      expect(chunks.join(), paragraph);
    });

    test('splits on ！ and ？ too', () {
      final String paragraph =
          List.generate(40, (i) => i.isEven ? sentence : '你们明白吗？对！').join();
      final chunks = chunkTranscript(paragraph);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk, matches(RegExp(r'[。！？]$')));
      }
      expect(chunks.join(), paragraph);
    });

    test('hard-splits unpunctuated Chinese by characters', () {
      final String run = '我' * 2000;
      final chunks = chunkTranscript(run);
      expect(chunks.length, greaterThan(3));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(525));
      }
      expect(chunks.join(), run);
    });

    test('paragraphsFromSegments joins segments without spaces', () {
      final result = paragraphsFromSegments([
        seg('欢迎大家。', 0, 1000),
        seg('今晚我们学习罗马书。', 1000, 2000),
      ]);
      expect(result, '欢迎大家。今晚我们学习罗马书。');
    });

    test('paragraphsFromSegments breaks long Chinese text', () {
      final result = paragraphsFromSegments(
          List.generate(40, (i) => seg(sentence, i * 1000, i * 1000 + 900)));
      expect(result.split('\n\n').length, greaterThan(1));
    });

    test('rejects a chunk translated into English', () {
      final String raw = sentence * 3;
      expect(acceptFormattedChunk(raw, words(55)), raw);
      expect(acceptFormattedChunk(raw, raw.replaceAll('。', '，')),
          raw.replaceAll('。', '，'));
    });
  });

  group('Spanish punctuation', () {
    test('splits on ? and ! and keeps the opening marks', () {
      final String paragraph = List.generate(
              12,
              (i) =>
                  i.isEven ? '¿${words(40, 'qué')}?' : '¡${words(40, 'sí')}!')
          .join(' ');
      final chunks = chunkTranscript(paragraph);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk, matches(RegExp(r'^[¿¡]')));
        expect(chunk, matches(RegExp(r'[?!]$')));
      }
      expect(chunks.join(' '), paragraph);
    });

    test('paragraphsFromSegments treats ? and ! as sentence ends', () {
      final result = paragraphsFromSegments([
        seg('¿${words(45, 'qué')}?', 0, 10000),
        seg('¡Sí!', 12000, 13000),
      ]);
      expect(result.split('\n\n'), ['¿${words(45, 'qué')}?', '¡Sí!']);
    });
  });

  group('formatter prompt', () {
    test('names the transcript language and forbids translating', () {
      for (final language in Language.all) {
        final prompt = formatterPrompt('texto', language);
        final instructions = formatterInstructions(language);
        expect(prompt, contains('Do not translate'));
        expect(instructions, contains('never translate'));
      }
      expect(formatterPrompt('x', Language.spanish), contains('in Spanish'));
      expect(formatterPrompt('x', Language.spanish), contains('¿'));
      expect(formatterPrompt('x', Language.chineseSimplified),
          contains('Simplified Chinese'));
      expect(formatterInstructions(Language.chineseTraditional),
          contains('Traditional Chinese'));
      expect(formatterPrompt('x', Language.swahili), contains('Swahili'));
      expect(formatterPrompt('x', Language.english), contains('in English'));
    });
  });

  group('whisper language', () {
    test('English uses the English model, others the multilingual one', () {
      expect(whisperModelFor(Language.english), kEnglishTranscriptionModel);
      for (final language in Language.all.skip(1)) {
        expect(whisperModelFor(language), kMultilingualTranscriptionModel);
      }
    });

    test('passes Whisper language codes', () {
      expect(Language.all.map(whisperLanguageCode),
          ['en', 'es', 'zh', 'zh', 'fr', 'pt', 'sw']);
    });

    test('prompts Chinese in the right script', () {
      expect(whisperInitialPrompt(Language.chineseSimplified),
          startsWith('以下是普通话的句子。'));
      expect(whisperInitialPrompt(Language.chineseTraditional),
          startsWith('以下是普通話的句子。'));
    });
  });

  group('iosMajorVersion', () {
    test('reads the major version', () {
      expect(
          TranscriptFormatterService.iosMajorVersion(
              'Version 15.8.4 (Build 19H390)'),
          15);
      expect(
          TranscriptFormatterService.iosMajorVersion(
              'Version 26.0 (Build 23A341)'),
          26);
    });

    test('is 0 when there is no version', () {
      expect(TranscriptFormatterService.iosMajorVersion(''), 0);
    });
  });
}
