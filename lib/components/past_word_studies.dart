import 'package:flutter/material.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/common/word_study_list_item.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:loggy/loggy.dart';

class PastWordStudies extends StatelessWidget {
  const PastWordStudies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WordStudy>>(
      future: getAllWordStudies(),
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");

        List<WordStudy> studies = snapshot.data?.reversed.toList() ?? [];

        return snapshot.hasData && studies.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 20, bottom: 10),
                child: Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueGrey[900]
                        : Colors.blueGrey[100],
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const HomeHeader(
                                title: "Past Word Studies", onExpand: null),
                            ...studies.map((study) {
                              return WordStudyListItem(study: study);
                            })
                          ],
                        ))))
            : const SizedBox.shrink();
      },
    );
  }
}
