import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every translation must have every English string, with the same
/// placeholders, so a new or renamed string can't silently fall back to
/// English (or crash on a missing placeholder) in one language.
void main() {
  final Map<String, dynamic> english =
      jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync());
  final List<String> keys =
      english.keys.where((k) => !k.startsWith('@')).toList();

  final RegExp placeholder = RegExp(r'\{(\w+)[,}]');
  const Set<String> icuWords = {
    'plural',
    'select',
    'other',
    'zero',
    'one',
    'two',
    'few',
    'many'
  };
  Set<String> placeholdersIn(String message) => placeholder
      .allMatches(message)
      .map((m) => m.group(1)!)
      .where((name) => !icuWords.contains(name))
      .toSet();

  final List<File> translations = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'))
      .toList();

  test('there are translations to check', () {
    expect(translations, isNotEmpty);
  });

  for (final File file in translations) {
    final String name = file.uri.pathSegments.last;
    final Map<String, dynamic> translated = jsonDecode(file.readAsStringSync());

    test('$name has every English string', () {
      final List<String> missing =
          keys.where((k) => !translated.containsKey(k)).toList();
      expect(missing, isEmpty);
    });

    test('$name keeps every placeholder', () {
      final List<String> mismatched = [
        for (final String key in keys)
          if (translated[key] is String &&
              !placeholdersIn(english[key] as String)
                  .containsAll(placeholdersIn(translated[key] as String)))
            key,
        for (final String key in keys)
          if (translated[key] is String &&
              !placeholdersIn(translated[key] as String)
                  .containsAll(placeholdersIn(english[key] as String)))
            key,
      ];
      expect(mismatched, isEmpty);
    });
  }
}
