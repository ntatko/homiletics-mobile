import 'dart:convert';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/report_error.dart';
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
          ? widget.schedules
              .firstWhere((element) => element.expires.compareTo(DateTime.now()) == 1, orElse: () => widget.schedules.last)
          : null;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
        child: Card(
            color: Colors.blue[200],
            child: Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Current Lesson", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                widget.schedules.isEmpty
                    ? SizedBox(
                        width: 200,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [CircularProgressIndicator(), Text(" Loading...")]))
                    : DropdownButton(
                        itemHeight: 55,
                        borderRadius: BorderRadius.circular(30),
                        dropdownColor: Colors.blue[400],
                        iconEnabledColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            selectedSchedule = widget.schedules.firstWhere((element) => element.reference == value);
                          });
                        },
                        value: selectedSchedule!.reference,
                        items: widget.schedules.map((schedule) {
                          return DropdownMenuItem(
                              value: schedule.reference,
                              child: Text(
                                schedule.reference,
                                textAlign: TextAlign.center,
                                textWidthBasis: TextWidthBasis.parent,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ));
                        }).toList(),
                      ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                        child: const Text("Start Homiletics"),
                        onPressed: widget.schedules.isNotEmpty
                            ? () async {
                                Homiletic homiletic = Homiletic(passage: selectedSchedule!.reference);
                                await homiletic.update();
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => HomileticEditor(homiletic: homiletic)));
                              }
                            : null),
                    ElevatedButton(
                        child: const Text("Start Lecture Note"),
                        onPressed: widget.schedules.isNotEmpty
                            ? () async {
                                LectureNote note = LectureNote(passage: selectedSchedule!.reference);
                                await note.update();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NotesEditor(
                                              note: note,
                                            )));
                              }
                            : null)
                  ],
                )
              ]),
            )));
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

  final response = await client.get(Uri.parse('https://homiletics.cloud.zipidy.org/items/assigned_passages?limit=-1'));

  if (response.statusCode == 200) {
    List<PassageSchedule> schedules =
        List<PassageSchedule>.from(jsonDecode(response.body)['data'].map((x) => PassageSchedule.fromJson(x)));

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
    return FutureBuilder<List<PassageSchedule>>(
        future: getWebPassages(),
        builder: (context, htmlSnapshot) {
          if (htmlSnapshot.hasError) {
            logError("${htmlSnapshot.error}");
          }

          if (htmlSnapshot.hasData) {
            return CurrentLesson(schedules: htmlSnapshot.data!);
          }

          return const LoadingLesson();
        });
  }
}
