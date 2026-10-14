import 'package:flutter/material.dart';
import 'package:homiletics/common/passage_badge.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomileticListItem extends StatelessWidget {
  final Homiletic homiletic;
  const HomileticListItem({Key? key, required this.homiletic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        key: Key("${homiletic.id}"),
        margin: const EdgeInsets.only(top: 5),
        // height: 80,
        child: GestureDetector(
            onTapUp: (_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomileticEditor(homiletic: homiletic)));
            },
            child: Card(
              surfaceTintColor: Colors.blue,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                PassageBadge(passage: homiletic.passage),
                Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(homiletic.passage,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                        Text(timeago.format(
                            homiletic.updatedAt ?? DateTime.now(),
                            locale: 'en_short')),
                      ],
                    ))
              ]),
            )));
  }
}
