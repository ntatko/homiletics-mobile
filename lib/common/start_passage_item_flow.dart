import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';

enum _DuplicatePassageChoice { editExisting, createNew }

/// Opens a homiletic for [passage]: a new one if none exists. When one
/// does, asks whether to edit it or start another — unless
/// [askIfExisting] is false (a "Continue" button), which opens the latest
/// directly.
Future<void> startHomileticForPassage(BuildContext context, String passage,
    {bool askIfExisting = true}) async {
  final List<Homiletic> matches =
      await getHomileticsMatchingPassageReference(passage);
  if (matches.isEmpty) {
    await _openNewHomiletic(context, passage);
    return;
  }

  if (!context.mounted) return;

  final Homiletic latest = matches.first;
  if (!askIfExisting) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext c) => HomileticEditor(homiletic: latest),
      ),
    );
    return;
  }
  final _DuplicatePassageChoice? choice =
      await showDialog<_DuplicatePassageChoice>(
    context: context,
    builder: (BuildContext ctx) {
      final AppLocalizations l = ctx.l10n;
      return AlertDialog(
        title: Text(l.startDuplicateHomileticTitle),
        content: Text(matches.length > 1
            ? l.startDuplicateHomileticMany(passage, matches.length)
            : passage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, _DuplicatePassageChoice.createNew),
            child: Text(l.startCreateNew),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, _DuplicatePassageChoice.editExisting),
            child: Text(l.startEditExisting),
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

Future<void> startLectureNoteForPassage(
    BuildContext context, String passage) async {
  final List<LectureNote> matches =
      await getLectureNotesMatchingPassageReference(passage);
  if (matches.isEmpty) {
    await _openNewLectureNote(context, passage);
    return;
  }

  if (!context.mounted) return;

  final LectureNote latest = matches.first;
  final _DuplicatePassageChoice? choice =
      await showDialog<_DuplicatePassageChoice>(
    context: context,
    builder: (BuildContext ctx) {
      final AppLocalizations l = ctx.l10n;
      return AlertDialog(
        title: Text(l.startDuplicateLectureTitle),
        content: Text(matches.length > 1
            ? l.startDuplicateLectureMany(passage, matches.length)
            : passage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, _DuplicatePassageChoice.createNew),
            child: Text(l.startCreateNew),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, _DuplicatePassageChoice.editExisting),
            child: Text(l.startEditExisting),
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

Future<void> startWordStudyForPassage(
    BuildContext context, String passage) async {
  final List<WordStudy> matches =
      await getWordStudiesMatchingPassageReference(passage);
  if (matches.isEmpty) {
    await _openNewWordStudy(context, passage);
    return;
  }

  if (!context.mounted) return;

  final WordStudy latest = matches.first;
  final _DuplicatePassageChoice? choice =
      await showDialog<_DuplicatePassageChoice>(
    context: context,
    builder: (BuildContext ctx) {
      final AppLocalizations l = ctx.l10n;
      return AlertDialog(
        title: Text(l.startDuplicateWordStudyTitle),
        content: Text(matches.length > 1
            ? l.startDuplicateWordStudyMany(passage, matches.length)
            : passage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, _DuplicatePassageChoice.createNew),
            child: Text(l.startCreateNew),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, _DuplicatePassageChoice.editExisting),
            child: Text(l.startEditExisting),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;

  if (choice == _DuplicatePassageChoice.editExisting) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext c) => WordStudyEditor(study: latest),
      ),
    );
  } else if (choice == _DuplicatePassageChoice.createNew) {
    await _openNewWordStudy(context, passage);
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

Future<void> _openNewWordStudy(BuildContext context, String passage) async {
  final WordStudy study = WordStudy(passage: passage);
  await study.update();
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext c) => WordStudyEditor(study: study),
    ),
  );
}
