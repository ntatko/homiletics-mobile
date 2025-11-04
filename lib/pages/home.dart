import 'package:flutter/material.dart';
import 'package:homiletics/components/application_list.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/past_lecture_notes.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/components/start_activity.dart';
import 'package:homiletics/components/custom_search_bar.dart';
import 'package:homiletics/components/search_results_widget.dart';
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
  String _searchString = '';

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
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
            child: Stack(children: [
              ListView(children: const [
                SizedBox(height: 50),
                CurrentLessonActions(),
                StartActivity(),
                ApplicationList(),
                PastLessons(),
                PastLectureNotes(),
                HelpMenu(),
                // RoundedButton(
                //     child: Text("Reset Tables"),
                //     onClick: () async {
                //       resetScheduleTable();
                //     })
              ]),
              // Custom Search Bar
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomSearchBar(
                    hint: "Search...",
                    isPortrait: isPortrait,
                    onQueryChanged: (query) {
                      setState(() {
                        _searchString = query;
                      });
                    },
                    searchResultsBuilder: (query) {
                      return SearchResultsWidget(searchString: query);
                    },
                  ),
                ),
              ),
            ])));
  }
}
