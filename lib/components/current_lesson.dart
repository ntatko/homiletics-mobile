import 'dart:convert';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:loggy/loggy.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentLesson extends StatefulWidget {
  final List<PassageSchedule> schedules;

  const CurrentLesson({Key? key, required this.schedules}) : super(key: key);

  @override
  State<CurrentLesson> createState() => _CurrentLessonState();
}

class _CurrentLessonState extends State<CurrentLesson> {
  late PageController _pageController;
  String? _selectedStudy;
  late List<PassageSchedule> _filteredSchedules;

  @override
  void initState() {
    super.initState();
    _filteredSchedules = widget.schedules;
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _getInitialPage(),
    );
  }

  int _getInitialPage() {
    if (_filteredSchedules.isEmpty) return 0;
    final now = DateTime.now();
    return _filteredSchedules
        .lastIndexWhere((schedule) => schedule.rollout.isBefore(now));
  }

  List<String> get _uniqueStudies {
    return widget.schedules.map((s) => s.study).toSet().toList()..sort();
  }

  void _filterSchedules(String? study) {
    setState(() {
      _selectedStudy = study;
      _filteredSchedules = study == null
          ? widget.schedules
          : widget.schedules.where((s) => s.study == study).toList();
      _pageController = PageController(
        viewportFraction: 0.85,
        initialPage: _getInitialPage(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Current Lessons",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedStudy,
                      hint: const Text("Filter by study"),
                      onChanged: _filterSchedules,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("All studies"),
                        ),
                        ..._uniqueStudies
                            .map((study) => DropdownMenuItem<String>(
                                  value: study,
                                  child: Text(study),
                                )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 164, // Reduced height
          child: PageView.builder(
            controller: _pageController,
            itemCount: _filteredSchedules.length,
            itemBuilder: (context, index) {
              return _buildLessonCard(_filteredSchedules[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(PassageSchedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  schedule.passage,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  schedule.lesson,
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Homiletic homiletic = Homiletic(passage: schedule.passage);
                    await homiletic.update();
                    if (mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            HomileticEditor(homiletic: homiletic),
                      ));
                    }
                  },
                  child: const Text("Homiletics"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    LectureNote note = LectureNote(passage: schedule.passage);
                    await note.update();
                    if (mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotesEditor(note: note),
                      ));
                    }
                  },
                  child: const Text("Lecture Note"),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final url = Uri.parse("https://${schedule.study}");
                  await launchUrl(url);
                },
                child: Text(schedule.study),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      'https://homiletics-directus.cloud.plodamouse.com/items/suggested_passages?limit=-1'));

  if (response.statusCode == 200) {
    List<PassageSchedule> schedules = List<PassageSchedule>.from(
        jsonDecode(response.body)['data']
            .map((x) => PassageSchedule.fromJson(x)));

    schedules.sort((a, b) => a.rollout.compareTo(b.rollout));
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
