import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';

enum _DuplicatePassageChoice { editExisting, createNew }

Future<void> startHomileticForPassage(BuildContext context, String passage) async {
  if (kIsWeb) {
    await _openNewHomiletic(context, passage);
    return;
  }

  final List<Homiletic> matches = await getHomileticsMatchingPassageReference(passage);
  if (matches.isEmpty) {
    await _openNewHomiletic(context, passage);
    return;
  }

  if (!context.mounted) return;

  final Homiletic latest = matches.first;
  final _DuplicatePassageChoice? choice = await showDialog<_DuplicatePassageChoice>(
    context: context,
    builder: (BuildContext ctx) {
      final String extra = matches.length > 1
          ? '\n\nYou have ${matches.length} homiletics for this passage; opening the most recent.'
          : '';
      return AlertDialog(
        title: const Text('Already have a homiletic for this passage?'),
        content: Text('$passage$extra'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _DuplicatePassageChoice.createNew),
            child: const Text('Create new'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, _DuplicatePassageChoice.editExisting),
            child: const Text('Edit existing'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;

  if (choice == _DuplicatePassageChoice.editExisting) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext c) => HomileticEditor(homiletic: latest),
      ),
    );
  } else if (choice == _DuplicatePassageChoice.createNew) {
    await _openNewHomiletic(context, passage);
  }
}

Future<void> startLectureNoteForPassage(BuildContext context, String passage) async {
  if (kIsWeb) {
    await _openNewLectureNote(context, passage);
    return;
  }

  final List<LectureNote> matches = await getLectureNotesMatchingPassageReference(passage);
  if (matches.isEmpty) {
    await _openNewLectureNote(context, passage);
    return;
  }

  if (!context.mounted) return;

  final LectureNote latest = matches.first;
  final _DuplicatePassageChoice? choice = await showDialog<_DuplicatePassageChoice>(
    context: context,
    builder: (BuildContext ctx) {
      final String extra = matches.length > 1
          ? '\n\nYou have ${matches.length} lecture notes for this passage; opening the most recent.'
          : '';
      return AlertDialog(
        title: const Text('Already have lecture notes for this passage?'),
        content: Text('$passage$extra'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _DuplicatePassageChoice.createNew),
            child: const Text('Create new'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, _DuplicatePassageChoice.editExisting),
            child: const Text('Edit existing'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;

  if (choice == _DuplicatePassageChoice.editExisting) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext c) => NotesEditor(note: latest),
      ),
    );
  } else if (choice == _DuplicatePassageChoice.createNew) {
    await _openNewLectureNote(context, passage);
  }
}

Future<void> _openNewHomiletic(BuildContext context, String passage) async {
  final Homiletic homiletic = Homiletic(passage: passage);
  await homiletic.update();
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext c) => HomileticEditor(homiletic: homiletic),
    ),
  );
}

Future<void> _openNewLectureNote(BuildContext context, String passage) async {
  final LectureNote note = LectureNote(passage: passage);
  await note.update();
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext c) => NotesEditor(note: note),
    ),
  );
}
