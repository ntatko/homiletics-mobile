import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/notes_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:loggy/loggy.dart';

/// Every saved lecture note, newest first (the "Lectures" tab of
/// [LessonPage]).
class PastLectureNotes extends StatelessWidget {
  const PastLectureNotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudyDataBuilder<List<LectureNote>>(
      load: getLectureNotes,
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");
        if (!snapshot.hasData) return const StudyListLoading();

        final List<LectureNote> notes = snapshot.data!.reversed.toList();
        if (notes.isEmpty) {
          return const StudyListEmpty('No lecture notes yet.');
        }
        return ListView.builder(
          padding: studyListPadding,
          itemCount: notes.length,
          itemBuilder: (context, index) => NotesListItem(
            note: notes[index],
            divider: index < notes.length - 1,
          ),
        );
      },
    );
  }
}
