import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/common/homiletic_list_item.dart';
import 'package:homiletics/pages/lesson_page.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:loggy/loggy.dart';

class PastLessons extends StatelessWidget {
  const PastLessons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Homiletic>>(
        future: getAllHomiletics(),
        builder: (context, snapshot) {
          if (snapshot.hasError) logError('${snapshot.error}');

          return snapshot.hasData
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DisplayLessons(snapshot.data?.reversed.toList() ?? []))
              : const SizedBox.shrink();
        });
  }
}

class DisplayLessons extends StatelessWidget {
  final List<Homiletic> homiletics;

  const DisplayLessons(this.homiletics, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return homiletics.isNotEmpty
        ? Card(
            color: Colors.blue[100],
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeHeader(
                    title: "Past Homiletics",
                    onExpand: homiletics.length > 4
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LessonPage(homiletics: homiletics),
                              ),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: 2),
                  ...homiletics.take(6).map((homiletic) {
                    return HomileticListItem(
                      homiletic: homiletic,
                    );
                  }).toList(),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
