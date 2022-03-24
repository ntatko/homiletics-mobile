// ignore_for_file: library_prefixes

import 'package:homiletics/classes/translation.dart';
import 'package:bible/bible.dart' as Bible;

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

  factory Passage.fromQuery(String key, String value) {
    return Passage(
        chapter: int.parse(key.split(' ')[1].split(':')[0]),
        verse: int.parse(key.split(' ')[1].split(':')[1]),
        text: value.replaceAll("<b>", "").replaceAll("</b>", ""),
        book: key.split(' ')[0]);
  }
}

Future<List<Passage>> fetchPassage(
    String reference, Translation? version) async {
  var passage = await Bible.queryPassage(reference,
      providerName: version?.source ?? 'bibleapi',
      version: version?.code ?? 'web');

  if (passage != null && passage.verses != null && passage.verses!.isNotEmpty) {
    return passage.verses!.values.map((value) {
      String key = passage.verses!.keys
          .toList()[passage.verses!.values.toList().indexOf(value)];
      return Passage.fromQuery(key, value!);
    }).toList();
  } else {
    throw Exception('Failed to load scheduled passages');
  }
}
