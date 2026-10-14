import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/relative_time.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:homiletics/theme/home_widgets.dart';

/// A saved lecture note in a list. Opens the notes editor.
class NotesListItem extends StatelessWidget {
  final LectureNote note;
  final bool divider;

  const NotesListItem({Key? key, required this.note, this.divider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    return StudyListRow(
      key: Key("${note.id}"),
      leading: const StudyKindTile(StudyKind.lecture),
      title: note.passage.isNotEmpty
          ? l.studiesLectureTitle(note.passage)
          : l.studiesLectureUntitled,
      subtitle: l.studiesLectureSubtitle(
          relativeTime(context, note.time ?? DateTime.now())),
      divider: divider,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NotesEditor(note: note)));
      },
    );
  }
}
