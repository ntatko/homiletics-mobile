import 'dart:async';

import 'package:homiletics/classes/Division.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'divisions.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE divisions (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              title TEXT,
              passage TEXT,
              sort INTEGER,
              homiletic_id INTEGER
            )
            ''');
    },
    version: 1,
  );
});

Future<List<Division>> getDivisionsByHomileticId(int? id) async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps =
      await db.query('divisions', where: 'homiletic_id = ?', whereArgs: [id]);

  if (maps.isEmpty) {
    return [];
  }
  return List.generate(maps.length, (index) => Division.fromJson(maps[index]));
}

Future<void> resetDivisionsTable() async {
  final Database db = await database;
  await db.execute("DROP TABLE IF EXISTS divisions ");
  await db.execute('''
            CREATE TABLE divisions (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              title TEXT,
              passage TEXT,
              sort INTEGER,
              homiletic_id INTEGER
            )
            ''');
}

Future<int> insertDivision(Division division) async {
  final Database db = await database;

  return await db.insert('divisions', division.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> updateDivision(Division division) async {
  final Database db = await database;

  await db.update('divisions', division.toJson()..remove('id'),
      where: 'id = ?', whereArgs: [division.id]);
}

Future<void> deleteDivision(Division division) async {
  final Database db = await database;

  await db.delete('divisions', where: 'id = ?', whereArgs: [division.id]);
}

Future<List<Division>> deleteDivisionByHomileticId(int id) async {
  final Database db = await database;

  List<Division> divisions = await getDivisionsByHomileticId(id);

  await db.delete('divisions', where: 'homiletic_id = ?', whereArgs: [id]);
  return divisions;
}
