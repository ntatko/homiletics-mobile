import 'dart:async';

import 'package:homiletics/classes/lecture_note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'lectures.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE lectures (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              note TEXT,
              passage TEXT,
              time TEXT
            )
            ''');
    },
    version: 1,
  );
});

Future<List<LectureNote>> getLectureNotes() async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('lectures');

  if (maps.isEmpty) {
    return [];
  }

  print("other maps $maps");
  return List.generate(
      maps.length, (index) => LectureNote.fromJson(maps[index]));
}

Future<void> resetLectureNoteTable() async {
  final Database db = await database;
  await db.execute("DROP TABLE IF EXISTS lectures ");
  await db.execute('''
            CREATE TABLE lectures (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              note TEXT,
              passage TEXT,
              time TEXT
            )
            ''');
}

Future<int> insertLectureNote(LectureNote note) async {
  final Database db = await database;
  note.time = DateTime.now();

  return await db.insert('lectures', note.toJson()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> updateLectureNote(LectureNote note) async {
  final Database db = await database;
  note.time = DateTime.now();

  await db.update('lectures', note.toJson()..remove('id'),
      where: 'id = ?', whereArgs: [note.id]);
}

Future<void> deleteLectureNote(LectureNote note) async {
  final Database db = await database;

  await db.delete('lectures', where: 'id = ?', whereArgs: [note.id]);
}
