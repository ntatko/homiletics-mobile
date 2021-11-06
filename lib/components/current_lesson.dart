import 'dart:convert';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/rounded_button.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:homiletics/storage/passage_schedule_storage.dart';
import 'package:loggy/loggy.dart';
import 'package:flutter/services.dart';

class CurrentLesson extends StatelessWidget {
  final PassageSchedule schedule;
  final bool disabled;

  const CurrentLesson({Key? key, required this.schedule, this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // status bar color
    ));

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "This week's passage:",
                    style: TextStyle(color: Colors.white),
                  ),
                  disabled
                      ? Container(
                          color: Colors.grey,
                          width: 120,
                          height: 50,
                        )
                      : Text(
                          schedule.reference,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 30),
                        )
                ],
              )),
          Column(
            children: [
              RoundedButton(
                  shadow: false,
                  onClick: disabled
                      ? () {}
                      : () {
                          Homiletic homilet =
                              Homiletic(passage: schedule.reference);
                          homilet.update();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomileticEditor(homiletic: homilet)));
                        },
                  child: const Text("Start Homiletics")),
              RoundedButton(
                  shadow: false,
                  onClick: disabled
                      ? () {}
                      : () {
                          LectureNote note =
                              LectureNote(passage: schedule.reference);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotesEditor(note: note)));
                        },
                  child: const Text("Take notes"))
            ],
          )
        ],
      ),
    );
  }
}

class LoadingLesson extends StatelessWidget {
  const LoadingLesson({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurrentLesson(
      schedule: PassageSchedule(rollout: DateTime.now(), reference: ''),
      disabled: true,
    );
  }
}

Future<PassageSchedule> getPassage() async {
  List<PassageSchedule> passages = await getPassageSchedules();

  passages.sort((a, b) => a.rollout.compareTo(b.rollout));
  return passages
      .firstWhere((element) => element.rollout.compareTo(DateTime.now()) == 1);
}

Future<PassageSchedule> loadPassages() async {
  final response = await http.get(Uri.parse(
      'https://homiletics.cloud.zipidy.org/items/assigned_passages?limit=-1'));

  if (response.statusCode == 200) {
    List<PassageSchedule> schedules = List<PassageSchedule>.from(
        jsonDecode(response.body)['data']
            .map((x) => PassageSchedule.fromJson(x)));

    await putNewSchedules(schedules);

    schedules.sort((a, b) => a.rollout.compareTo(b.rollout));
    return schedules.firstWhere(
        (element) => element.rollout.compareTo(DateTime.now()) == 1);
  } else {
    throw Exception('Failed to load scheduled passages');
  }
}

class CurrentLessonActions extends StatelessWidget {
  const CurrentLessonActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            const EdgeInsets.only(top: 30, bottom: 30, left: 13, right: 13),
        decoration: BoxDecoration(
            color: Colors.blue,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[400]!,
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.elliptical(100, 40),
                bottomRight: Radius.elliptical(100, 40))),
        child: FutureBuilder<PassageSchedule>(
            future: loadPassages(),
            builder: (context, htmlSnapshot) {
              if (htmlSnapshot.hasError) logError("${htmlSnapshot.error}");

              if (htmlSnapshot.hasData) {
                return CurrentLesson(schedule: htmlSnapshot.data!);
              }
              return FutureBuilder<PassageSchedule>(
                  future: getPassage(),
                  builder: (context, sqlSnapshot) {
                    if (sqlSnapshot.hasError) logError("${sqlSnapshot.error}");
                    if (sqlSnapshot.hasData) {
                      return CurrentLesson(schedule: sqlSnapshot.data!);
                    }
                    return const LoadingLesson();
                  });
            }));
  }
}
