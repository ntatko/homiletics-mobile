import 'package:homiletics/common/start_passage_item_flow.dart';
import 'package:homiletics/services/suggested_passages_repository.dart';
import 'package:homiletics/utils/study_launch_uri.dart';
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

  @override
  void didUpdateWidget(CurrentLesson oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameScheduleList(oldWidget.schedules, widget.schedules)) {
      _selectedStudy = null;
      _filteredSchedules = widget.schedules;
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: 0.85,
        initialPage: _getInitialPage(),
      );
    }
  }

  bool _sameScheduleList(
      List<PassageSchedule> a, List<PassageSchedule> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].passage != b[i].passage ||
          a[i].rollout != b[i].rollout ||
          a[i].lesson != b[i].lesson ||
          a[i].study != b[i].study) {
        return false;
      }
    }
    return true;
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
                  onPressed: () => startHomileticForPassage(
                        context,
                        schedule.passage,
                      ),
                  child: const Text("Homiletics"),
                ),
                ElevatedButton(
                  onPressed: () => startLectureNoteForPassage(
                        context,
                        schedule.passage,
                      ),
                  child: const Text("Lecture Note"),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await launchUrl(studyLaunchUri(schedule.study));
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

class CurrentLessonActions extends StatefulWidget {
  const CurrentLessonActions({Key? key}) : super(key: key);

  @override
  State<CurrentLessonActions> createState() => _CurrentLessonActionsState();
}

class _CurrentLessonActionsState extends State<CurrentLessonActions> {
  List<PassageSchedule> _schedules = [];
  bool _waitingForFirstPayload = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await SuggestedPassagesRepository.loadWithCallback(
      onData: (schedules) {
        if (!mounted) return;
        setState(() {
          _schedules = schedules;
          _waitingForFirstPayload = false;
        });
      },
      onError: (e, st) {
        logError('$e\n$st');
        if (!mounted) return;
        setState(() => _waitingForFirstPayload = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForFirstPayload && _schedules.isEmpty) {
      return const LoadingLesson();
    }
    return CurrentLesson(schedules: _schedules);
  }
}
