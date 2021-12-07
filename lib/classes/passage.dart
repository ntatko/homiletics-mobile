import 'package:http/http.dart' as http;
import 'dart:convert';

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
        chapter: json['chapter'],
        verse: json['verse'],
        text: json['text'],
        book: json['book_name']);
  }
}

Future<List<Passage>> fetchPassage(String reference) async {
  final response = await http.get(
      Uri.parse('https://bible-api.com/${reference.replaceAll(' ', '+')}'));

  if (response.statusCode == 200) {
    return List<Passage>.from(
        jsonDecode(response.body)['verses'].map((x) => Passage.fromJson(x)));
  } else {
    throw Exception('Failed to load scheduled passages');
  }
}
