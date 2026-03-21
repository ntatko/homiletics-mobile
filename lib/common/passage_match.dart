/// Normalizes a passage reference for comparison (whitespace, case).
String normalizePassageRef(String passage) {
  var s = passage
      .trim()
      .toLowerCase()
      .replaceAll('\t', ' ')
      .replaceAll('\n', ' ')
      .replaceAll('\r', ' ');
  while (s.contains('  ')) {
    s = s.replaceAll('  ', ' ');
  }
  return s;
}
