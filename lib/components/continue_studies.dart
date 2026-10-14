import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/common/homiletic_list_item.dart';
import 'package:homiletics/common/notes_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/common/word_study_list_item.dart';
import 'package:homiletics/pages/lesson_page.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:loggy/loggy.dart';

/// One saved study of any kind, with the time it was last touched.
class _RecentStudy {
  final DateTime time;
  final Object study;

  _RecentStudy(DateTime? time, this.study)
      : time = time ?? DateTime.fromMillisecondsSinceEpoch(0);
}

/// Home's "Continue" section: the most recently edited homiletics, lecture
/// notes and word studies in one list. "See all" opens [LessonPage].
class ContinueStudies extends StatelessWidget {
  /// How many recent studies Home shows.
  static const int count = 5;

  /// Around the section when it shows (it collapses entirely when empty).
  final EdgeInsetsGeometry padding;

  const ContinueStudies({Key? key, this.padding = EdgeInsets.zero})
      : super(key: key);

  static Future<List<_RecentStudy>> _load() async {
    final List<Homiletic> homiletics = await getAllHomiletics();
    final List<LectureNote> notes = await getLectureNotes();
    final List<WordStudy> studies = await getAllWordStudies();
    return [
      for (final h in homiletics) _RecentStudy(h.updatedAt, h),
      for (final n in notes) _RecentStudy(n.time, n),
      for (final s in studies) _RecentStudy(s.updatedAt, s),
    ]..sort((a, b) => b.time.compareTo(a.time));
  }

  Widget _row(Object study, bool divider) {
    if (study is Homiletic) {
      return HomileticListItem(
          key: ValueKey('h${study.id}'), homiletic: study, divider: divider);
    }
    if (study is LectureNote) {
      return NotesListItem(
          key: ValueKey('n${study.id}'), note: study, divider: divider);
    }
    final WordStudy wordStudy = study as WordStudy;
    return WordStudyListItem(
        key: ValueKey('w${wordStudy.id}'), study: wordStudy, divider: divider);
  }

  @override
  Widget build(BuildContext context) {
    return StudyDataBuilder<List<_RecentStudy>>(
      load: _load,
      builder: (context, snapshot) {
        if (snapshot.hasError) logError('${snapshot.error}');
        final List<_RecentStudy> recent = snapshot.data ?? const [];
        if (recent.isEmpty) return const SizedBox.shrink();

        final List<_RecentStudy> shown = recent.take(count).toList();
        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionHeader(
                context.l10n.homeContinue,
                actionLabel: context.l10n.homeSeeAll,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LessonPage()),
                  );
                },
              ),
              for (int i = 0; i < shown.length; i++)
                _row(shown[i].study, i < shown.length - 1),
            ],
          ),
        );
      },
    );
  }
}
