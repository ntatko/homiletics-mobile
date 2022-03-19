import 'dart:convert';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/rounded_button.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:loggy/loggy.dart';

class CurrentLesson extends StatefulWidget {
  final List<PassageSchedule> schedules;

  const CurrentLesson({Key? key, required this.schedules}) : super(key: key);

  @override
  State<CurrentLesson> createState() => _CurrentLessonState();
}

class _CurrentLessonState extends State<CurrentLesson> {
  PassageSchedule? selectedSchedule;

  @override
  void initState() {
    setState(() {
      selectedSchedule = widget.schedules.isNotEmpty
          ? widget.schedules.firstWhere(
              (element) => element.expires.compareTo(DateTime.now()) == 1,
              orElse: () => widget.schedules.last)
          : null;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("This week's passage:",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  widget.schedules.isEmpty
                      ? Container(
                          width: 150,
                          padding: const EdgeInsets.only(top: 12),
                          child: const Center(
                              child: CircularProgressIndicator(
                            color: Colors.white,
                          )))
                      : Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.blue[400],
                          ),
                          child: DropdownButton(
                            itemHeight: 55,
                            borderRadius: BorderRadius.circular(30),
                            dropdownColor: Colors.blue[400],
                            iconEnabledColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                selectedSchedule = widget.schedules.firstWhere(
                                    (element) => element.reference == value);
                              });
                            },
                            value: selectedSchedule!.reference,
                            items: widget.schedules.map((schedule) {
                              return DropdownMenuItem(
                                  value: schedule.reference,
                                  child: Container(
                                      child: Text(
                                    schedule.reference,
                                    textAlign: TextAlign.center,
                                    textWidthBasis: TextWidthBasis.parent,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )));
                            }).toList(),
                          ))
                ],
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RoundedButton(
                  shadow: false,
                  onClick: widget.schedules.isEmpty
                      ? () {}
                      : () {
                          Homiletic homilet =
                              Homiletic(passage: selectedSchedule!.reference);
                          homilet.update();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomileticEditor(homiletic: homilet)));
                        },
                  child: const Text(
                    "Start Homiletics",
                    textAlign: TextAlign.center,
                  )),
              RoundedButton(
                  shadow: false,
                  onClick: widget.schedules.isEmpty
                      ? () {}
                      : () {
                          LectureNote note =
                              LectureNote(passage: selectedSchedule!.reference);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotesEditor(note: note)));
                        },
                  child: const Text(
                    "Take notes",
                    textAlign: TextAlign.center,
                  ))
            ],
          )
        ]);
  }
}

class LoadingLesson extends StatelessWidget {
  const LoadingLesson({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CurrentLesson(schedules: []);
  }
}

Future<List<PassageSchedule>> getWebPassages() async {
  var client = http.Client();

  final response = await client.get(Uri.parse(
      'https://homiletics.cloud.zipidy.org/items/assigned_passages?limit=-1'));

  if (response.statusCode == 200) {
    List<PassageSchedule> schedules = List<PassageSchedule>.from(
        jsonDecode(response.body)['data']
            .map((x) => PassageSchedule.fromJson(x)));

    schedules.sort((a, b) => a.expires.compareTo(b.expires));
    return schedules;
  } else {
    throw Exception('Failed to load scheduled passages');
  }
}

class CurrentLessonActions extends StatefulWidget {
  const CurrentLessonActions({Key? key}) : super(key: key);

  @override
  State<CurrentLessonActions> createState() => _CurrentLessonActionsState();
}

class _CurrentLessonActionsState extends State<CurrentLessonActions> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 13, right: 13),
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: kElevationToShadow[4],
          // borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.elliptical(100, 40),
          //     bottomRight: Radius.elliptical(100, 40))
        ),
        child: FutureBuilder<List<PassageSchedule>>(
            future: getWebPassages(),
            builder: (context, htmlSnapshot) {
              if (htmlSnapshot.hasError) logError("${htmlSnapshot.error}");

              if (htmlSnapshot.hasData) {
                return CurrentLesson(schedules: htmlSnapshot.data!);
              }

              return const LoadingLesson();
            }));
  }
}
