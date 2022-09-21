import 'dart:async';

import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'lectures.db'),
    onUpgrade: onUpgrade,
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE lectures (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              note TEXT,
              passage TEXT,
              time TEXT,
              recording_path TEXT
            )
            ''');
    },
    version: 2,
  );
});

Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  for (var version = oldVersion + 1; version <= newVersion; version++) {
    switch (version) {
      case 1:
        {
          // Version 1 - no changes
          break;
        }
      case 2:
        {
          await db
              .execute('ALTER TABLE lectures ADD COLUMN recording_path TEXT');
          break;
        }
    }
  }
}

Future<List<LectureNote>> getLectureNotes() async {
  try {
    final Database db = await database;

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

Future<void> resetLectureNoteTable() async {
  try {
    final Database db = await database;
    await db.execute("DROP TABLE IF EXISTS lectures ");
    await db.execute('''
            CREATE TABLE lectures (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              note TEXT,
              passage TEXT,
              time TEXT,
              recording_path TEXT
            )
            ''');
  } catch (error) {
    sendError(error, "resetLectureNoteTable");
    throw Exception("failed to reset notes table");
  }
}

Future<int> insertLectureNote(LectureNote note) async {
  try {
    final Database db = await database;
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
    final Database db = await database;
    note.time = DateTime.now();

    await db.update('lectures', note.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [note.id]);
  } catch (error) {
    sendError(error, "updateLectureNote");
    throw Exception("failed to update lecture note");
  }
}

Future<void> deleteLectureNote(LectureNote note) async {
  try {
    final Database db = await database;

    await db.delete('lectures', where: 'id = ?', whereArgs: [note.id]);
  } catch (error) {
    sendError(error, "deleteLectureNote");
    throw Exception("failed to update lecture note");
  }
}

Future<List<LectureNote>> getLectureNoteByText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('lectures', where: 'note LIKE ?', whereArgs: ['%$text%']);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => LectureNote.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getLectureNoteByText");
    throw Exception("failed to get lecture notes");
  }
}
