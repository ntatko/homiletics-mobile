import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/common/passage_reference.dart';

void main() {
  test('normalizePassageReference trims, collapses spaces, lowercases', () {
    expect(normalizePassageReference('  John  3:16  '), 'john 3:16');
    expect(normalizePassageReference('Romans 8:28'), 'romans 8:28');
  });
}
