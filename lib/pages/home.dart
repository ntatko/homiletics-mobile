import 'package:flutter/material.dart';
import 'package:homiletics/components/application_list.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/past_lecture_notes.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/components/start_activity.dart';
import 'package:homiletics/pages/search_page.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
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
              Positioned(
                  child: FloatingSearchBar(
                hint: "Search...",
                scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
                transitionDuration: const Duration(milliseconds: 800),
                transitionCurve: Curves.easeInOut,
                physics: const BouncingScrollPhysics(),
                axisAlignment: isPortrait ? 0.0 : -1.0,
                openAxisAlignment: 0.0,
                width: isPortrait ? 600 : 500,
                debounceDelay: const Duration(milliseconds: 500),
                onQueryChanged: (query) {
                  setState(() {
                    _searchString = query;
                  });
                },
                transition: CircularFloatingSearchBarTransition(),
                actions: [
                  FloatingSearchBarAction.searchToClear(
                    showIfClosed: false,
                  ),
                ],
                builder: (context, transition) {
                  return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      height: MediaQuery.of(context).size.height / 2,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _searchString.isEmpty
                          ? const Center(child: Text("Type to search..."))
                          : ListView(
                              children: [
                                const SizedBox(height: 16),
                                ContentSearches(searchString: _searchString),
                                DivisionSearches(searchString: _searchString),
                                ApplicationSearches(
                                    searchString: _searchString),
                                AimSearches(searchString: _searchString),
                                SummarySentenceSearches(
                                    searchString: _searchString),
                                PassageSearches(searchString: _searchString),
                                const SizedBox(height: 16),
                              ],
                            ));
                },
              )),
            ])));
  }
}
