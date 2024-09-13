import 'dart:convert';

import 'package:homiletics/classes/translation.dart';
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

  factory Passage.fromQuery(String key, String value) {
    return Passage(
        chapter: int.parse(key.split(' ')[1].split(':')[0]),
        verse: int.parse(key.split(' ')[1].split(':')[1]),
        text: value.replaceAll("<b>", "").replaceAll("</b>", ""),
        book: key.split(' ')[0]);
  }
}

Future<PassageResponse> fetchPassage(
    String reference, Translation? version) async {
  try {
    var response = await http.get(Uri.parse(
        'https://homiletics-api.cloud.plodamouse.com/passages?passage=$reference&version=${version?.code ?? 'web'}'));

    if (response.statusCode == 200) {
      return PassageResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load passage');
    }
  } catch (e) {
    throw Exception('Failed to load passage');
  }
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
      throw Exception('Failed to load passage');
    }
  }
}
