import 'package:flutter/material.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class WordStudyListItem extends StatelessWidget {
  final WordStudy study;
  const WordStudyListItem({Key? key, required this.study}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        key: Key("${study.id}"),
        margin: const EdgeInsets.only(top: 5),
        child: GestureDetector(
            onTapUp: (_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WordStudyEditor(study: study)));
            },
            child: Card(
              surfaceTintColor: Colors.purple,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(StringToHex.toColor(study.passage
                          .padLeft(3)
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^\w\s]+'), '')
                          .substring(0, 3))),
                    ),
                    child: Center(
                      child: Text(
                        study.passage
                            .replaceAll(RegExp(r'\s'), '')
                            .padRight(3)
                            .substring(0, 3),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                            study.word.isNotEmpty
                                ? study.word
                                : study.passage,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                        Text(timeago.format(study.updatedAt ?? DateTime.now(),
                            locale: 'en_short')),
                      ],
                    ))
              ]),
            )));
  }
}
