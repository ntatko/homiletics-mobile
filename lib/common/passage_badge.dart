import 'package:flutter/material.dart';
import 'package:string_to_hex/string_to_hex.dart';

final RegExp _punctuation = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
final RegExp _whitespace = RegExp(r'\s');

/// The colored square at the start of a study list item: a color derived
/// from the passage and its first three characters. Safe for any passage,
/// including empty, short ("1:1") and non-ASCII ones.
class PassageBadge extends StatelessWidget {
  final String passage;

  const PassageBadge({Key? key, required this.passage}) : super(key: key);

  /// Strips punctuation first so the 3-character color key always exists.
  static int colorFor(String passage) {
    final String key = passage
        .toLowerCase()
        .replaceAll(_punctuation, '')
        .padLeft(3)
        .characters
        .take(3)
        .toString();
    return StringToHex.toColor(key);
  }

  static String labelFor(String passage) {
    return passage
        .replaceAll(_whitespace, '')
        .characters
        .take(3)
        .toString()
        .padRight(3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(colorFor(passage)),
        ),
        child: Center(
          child: Text(
            labelFor(passage),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ));
  }
}
