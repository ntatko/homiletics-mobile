/// Normalizes a Bible reference string for comparison (not semantic equivalence).
/// Trims, collapses whitespace, lowercases.
String normalizePassageReference(String passage) {
  return passage.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
