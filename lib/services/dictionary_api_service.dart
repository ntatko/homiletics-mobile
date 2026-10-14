import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryApiService {
  static const String _baseUrl =
      'https://freedictionaryapi.com/api/v1/entries/en/';

  static const Duration _timeout = Duration(seconds: 15);

  /// Fetches candidate definitions for [word] from a free public dictionary
  /// API. Returns a flat list of plain-English definition strings, or an empty
  /// list when the word is unknown (HTTP 404).
  ///
  /// Throws on network failure, timeout, other HTTP errors, or a malformed
  /// response.
  static Future<List<String>> fetchDefinitions(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl${Uri.encodeComponent(trimmed)}'),
      headers: {'Accept': 'application/json'},
    ).timeout(_timeout);

    if (response.statusCode == 404) {
      return [];
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load definitions: ${response.statusCode}');
    }

    final dynamic data = json.decode(response.body);
    if (data is! Map) {
      throw const FormatException('Unexpected dictionary response');
    }
    final dynamic entries = data['entries'];
    if (entries is! List) return [];

    final List<String> definitions = [];
    for (final entry in entries) {
      if (entry is! Map) continue;
      final dynamic senses = entry['senses'];
      if (senses is! List) continue;
      for (final sense in senses) {
        if (sense is! Map) continue;
        final dynamic definition = sense['definition'];
        if (definition is String && definition.trim().isNotEmpty) {
          definitions.add(definition.trim());
        }
      }
    }

    return definitions;
  }
}
