import 'dart:async';

import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/passage_reference.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:sqflite/sqflite.dart';

/// The database holding the `lectures` table (see [AppStorage]).
Future<Database> _db() => AppStorage.database('lectures');

Future<List<LectureNote>> getLectureNotes() async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db.query('lectures');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => LectureNote.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getLectureNotes");
    throw Exception("failed to get lecture notes");
  }
}

Future<int> insertLectureNote(LectureNote note) async {
  try {
    final Database db = await _db();
    note.time = DateTime.now();

    return await db.insert('lectures', note.toJson()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertLectureNote");
    throw Exception("failed to insert lecture note");
  }
}

Future<void> updateLectureNote(LectureNote note) async {
  try {
    final Database db = await _db();
    note.time = DateTime.now();

    await db.update('lectures', note.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [note.id]);
  } catch (error) {
    sendError(error, "updateLectureNote");
    throw Exception("failed to update lecture note");
  }
}

/// Clears note [id]'s recording file name, leaving everything else —
/// including its time, since the note itself didn't change.
Future<void> clearLectureRecordingPath(int id) async {
  try {
    final Database db = await _db();

    await db.update('lectures', {'recording_path': null},
        where: 'id = ?', whereArgs: [id]);
  } catch (error) {
    sendError(error, "clearLectureRecordingPath");
    throw Exception("failed to clear lecture recording path");
  }
}

Future<void> deleteLectureNote(LectureNote note) async {
  try {
    final Database db = await _db();

    await db.delete('lectures', where: 'id = ?', whereArgs: [note.id]);
  } catch (error) {
    sendError(error, "deleteLectureNote");
    throw Exception("failed to delete lecture note");
  }
}

/// Lecture notes whose [passage] matches [passage] after [normalizePassageReference],
/// newest [LectureNote.time] first.
Future<List<LectureNote>> getLectureNotesMatchingPassageReference(
    String passage) async {
  try {
    final String key = normalizePassageReference(passage);
    if (key.isEmpty) {
      return [];
    }
    final List<LectureNote> all = await getLectureNotes();
    final List<LectureNote> matches = all
        .where((LectureNote n) => normalizePassageReference(n.passage) == key)
        .toList();
    matches.sort((LectureNote a, LectureNote b) {
      final DateTime ta = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime tb = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
    return matches;
  } catch (error) {
    sendError(error, "getLectureNotesMatchingPassageReference");
    throw Exception("failed to get lecture notes by passage reference");
  }
}

/// Lecture notes whose [note] or [transcript] contains [text].
Future<List<LectureNote>> getLectureNotesByText(String text) async {
  try {
    final Database db = await _db();

    final String like = '%$text%';
    final List<Map<String, dynamic>> maps = await db.query('lectures',
        where:
            'note LIKE ? OR transcript LIKE ? OR formatted_transcript LIKE ?',
        whereArgs: [like, like, like]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => LectureNote.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getLectureNotesByText");
    throw Exception("failed to get lecture notes by text");
  }
}
