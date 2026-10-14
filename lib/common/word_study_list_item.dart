import 'package:flutter/material.dart';
import 'package:homiletics/common/passage_badge.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/pages/word_study_editor.dart';
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
                PassageBadge(passage: study.passage),
                Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(study.word.isNotEmpty ? study.word : study.passage,
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
