import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/components/past_lecture_notes.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/components/past_word_studies.dart';

/// Every saved study, one tab per kind: homiletics, lecture notes, word
/// studies. Reached from Home's "Continue" → "See all".
class LessonPage extends StatelessWidget {
  /// Shown in the Homiletics tab until its own (refreshable) query comes
  /// back.
  final List<Homiletic>? homiletics;

  /// 0 = Homiletics, 1 = Lectures, 2 = Word studies.
  final int initialTab;

  const LessonPage({Key? key, this.homiletics, this.initialTab = 0})
      : super(key: key);

  static const double _maxWidth = 720;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.studiesTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.studiesTabHomiletics),
              Tab(text: context.l10n.studiesTabLectures),
              Tab(text: context.l10n.studiesTabWordStudies),
            ],
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: TabBarView(
              children: [
                PastLessons(initialData: homiletics),
                const PastLectureNotes(),
                const PastWordStudies(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
