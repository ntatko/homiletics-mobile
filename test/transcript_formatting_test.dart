import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';

String words(int n, [String word = 'word']) =>
    List.filled(n, word).join(' ');

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
      final chunks = chunkTranscript(
          '${words(200)}.\n\n${words(100)}.\n\n${words(200)}.');
      expect(chunks, hasLength(2));
      expect(chunks.first.split('\n\n'), hasLength(2));
    });

    test('splits an oversized paragraph on sentence ends', () {
      final paragraph =
          List.generate(10, (_) => '${words(59)} end.').join(' ');
      final chunks = chunkTranscript(paragraph);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.trim(), endsWith('end.'));
      }
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
}
