import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/common/notes_list_item.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:loggy/loggy.dart';

class PastLectureNotes extends StatelessWidget {
  const PastLectureNotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LectureNote>>(
      future: getLectureNotes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");

        List<LectureNote> notes = snapshot.data?.reversed.toList() ?? [];

        return snapshot.hasData && notes.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
                child: Card(
                    color: Colors.orange[100],
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const HomeHeader(title: "Past Notes", onExpand: null),
                            ...notes.map((note) {
                              return NotesListItem(note: note);
                            })
                          ],
                        ))))
            : const SizedBox.shrink();
      },
    );
  }
}
