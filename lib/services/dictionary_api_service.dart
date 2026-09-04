import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryApiService {
  static const String _baseUrl =
      'https://freedictionaryapi.com/api/v1/entries/en/';

  /// Fetches candidate definitions for [word] from a free public dictionary
  /// API. Returns a flat list of plain-English definition strings.
  static Future<List<String>> fetchDefinitions(String word) async {
    final response = await http.get(
      Uri.parse('$_baseUrl${Uri.encodeComponent(word.trim().toLowerCase())}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load definitions: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> entries = data['entries'] as List<dynamic>? ?? [];

    final List<String> definitions = [];
    for (final entry in entries) {
      final List<dynamic> senses = entry['senses'] as List<dynamic>? ?? [];
      for (final sense in senses) {
        final String? definition = sense['definition'] as String?;
        if (definition != null && definition.trim().isNotEmpty) {
          definitions.add(definition.trim());
        }
      }
    }

    return definitions;
  }
}
