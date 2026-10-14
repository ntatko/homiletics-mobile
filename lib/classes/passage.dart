import 'dart:convert';

import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/config/api_config.dart';
import 'package:http/http.dart' as http;

class Passage {
  int chapter;
  int verse;
  String text;
  String book;

  Passage(
      {required this.chapter,
      required this.verse,
      required this.text,
      required this.book});

  factory Passage.fromJson(Map<String, dynamic> json) {
    return Passage(
        chapter: int.parse(json['chapter']),
        verse: int.parse(json['verse']),
        text: json['text'],
        book: json['book_name']);
  }
}

Future<PassageResponse> fetchPassage(
    String reference, Translation? version) async {
  final Uri uri = Uri.parse('$kHomileticsApiBase/passages').replace(
      queryParameters: {
        'passage': reference,
        'version': version?.code ?? 'web'
      });
  final http.Response response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
        'Failed to load passage "$reference": HTTP ${response.statusCode}');
  }
  return PassageResponse.fromJson(jsonDecode(response.body));
}

class PassageResponse {
  final List<Passage> verses;
  final String reference;
  final String text;
  final String versionCode;

  PassageResponse(
      {required this.verses,
      required this.reference,
      required this.text,
      required this.versionCode});

  factory PassageResponse.fromJson(Map<String, dynamic> json) {
    try {
      var list = json['verses'] as List;
      List<Passage> passages = list.map((i) => Passage.fromJson(i)).toList();

      return PassageResponse(
          verses: passages,
          reference: json['reference'].toString(),
          text: json['text'].toString(),
          versionCode: json['translation_id'].toString());
    } catch (error) {
      throw Exception('Failed to parse passage response: $error');
    }
  }
}
