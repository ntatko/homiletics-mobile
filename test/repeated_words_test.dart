import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/services/repeated_words.dart';

void main() {
  test('counts repeated words, most used first, without small words', () {
    const String text =
        'Therefore, since we have been justified through faith, '
        'we have peace with God through our Lord Jesus Christ. Faith '
        'brings peace, and faith brings hope; hope does not put us to shame.';
    expect(repeatedWords(text), const [
      RepeatedWord('faith', 3),
      RepeatedWord('brings', 2),
      RepeatedWord('hope', 2),
      RepeatedWord('peace', 2),
    ]);
  });

  test('leaves out the names on every page but keeps others', () {
    const String text = 'God promised Abraham. The LORD spoke to Abraham, '
        'and God blessed Israel. Israel believed God.';
    expect(repeatedWords(text), const [RepeatedWord('Abraham', 2)]);
  });

  test("possessives count as the word; all-caps counts as lowercase", () {
    expect(repeatedWords("the servant's master; the SERVANT obeyed"),
        const [RepeatedWord('servant', 2)]);
  });

  test('respects minCount and limit', () {
    const String text = 'grace grace grace love love joy';
    expect(repeatedWords(text, minCount: 3), const [RepeatedWord('grace', 3)]);
    expect(repeatedWords(text, limit: 1), const [RepeatedWord('grace', 3)]);
  });

  test('uses the passage language', () {
    const String text = 'Dios es amor. El amor de Dios es grande, y el amor '
        'permanece.';
    expect(repeatedWords(text, languageCode: 'es'),
        const [RepeatedWord('amor', 3)]);
  });

  test('Chinese, written without spaces, has none', () {
    expect(repeatedWords('神爱世人，甚至将他的独生子赐给他们', languageCode: 'zh'), isEmpty);
  });
}
