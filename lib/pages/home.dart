import 'package:flutter/material.dart';
import 'package:homiletics/components/application_list.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/past_lecture_notes.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/components/search_bar.dart';
import 'package:homiletics/components/start_activity.dart';
import 'package:homiletics/pages/search_page.dart';
// import 'package:homiletics/storage/application_storage.dart';
// import 'package:homiletics/storage/content_summary_storage.dart';
// import 'package:homiletics/storage/division_storage.dart';
// import 'package:homiletics/storage/homiletic_storage.dart';
// import 'package:homiletics/storage/lecture_note_storage.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Homiletics')),
      // bottomNavigationBar: BottomAppBar(
      //   shape: const CircularNotchedRectangle(),
      //   child: TextButton(
      //     child: const Text("reset the data"),
      //     onPressed: () async {
      //       await resetTable();
      //       await resetApplicationsTable();
      //       await resetDivisionsTable();
      //       await resetSummariesTable();
      //       await resetLectureNoteTable();
      //     },
      //   ),
      // ),
      body: SafeArea(
          bottom: false,
          child: ListView(children: [
            GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage())),
                child: const SearchBar()),
            const CurrentLessonActions(),
            const StartActivity(),
            const ApplicationList(),
            const PastLessons(),
            const PastLectureNotes(),
            const HelpMenu(),
            // RoundedButton(
            //     child: Text("Reset Tables"),
            //     onClick: () async {
            //       resetScheduleTable();
            //     })
          ])),
    );
  }
}
