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
    print("are they in here ${widget.schedules}");
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("This week's passage:",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              widget.schedules.isEmpty
                  ? Container(
                      padding: const EdgeInsets.only(top: 12),
                      width: 150,
                      child: const Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      )))
                  : Container(
                      padding: const EdgeInsets.only(left: 6, right: 6),
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blue[400],
                      ),
                      width: MediaQuery.of(context).size.width - 200,
                      child: DropdownButton(
                        itemHeight: 65,
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
                              child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 240,
                                  child: Flexible(
                                      child: Text(
                                    schedule.reference,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ))));
                        }).toList(),
                      ))
            ],
          )),
          Column(
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
                  child: const Text("Start Homiletics")),
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
    return const CurrentLesson(schedules: []);
  }
}

Future<List<PassageSchedule>> getWebPassages() async {
  print("do we ever do this?");
  final response = await http.get(Uri.parse(
      'https://homiletics.cloud.zipidy.org/items/assigned_passages?limit=-1'));

  if (response.statusCode == 200) {
    List<PassageSchedule> schedules = List<PassageSchedule>.from(
        jsonDecode(response.body)['data']
            .map((x) => PassageSchedule.fromJson(x)));

    print("we're in this now");

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
        child: FutureBuilder<List<PassageSchedule>>(
            future: getWebPassages(),
            builder: (context, htmlSnapshot) {
              if (htmlSnapshot.hasError) logError("${htmlSnapshot.error}");

              if (htmlSnapshot.hasData) {
                print("sql stuff ${htmlSnapshot.data!}");
                return CurrentLesson(schedules: htmlSnapshot.data!);
              }

              return const LoadingLesson();
            }));
  }
}
