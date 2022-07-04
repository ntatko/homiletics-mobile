import 'dart:async';

import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/common/report_error.dart';
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
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('divisions', where: 'homiletic_id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => Division.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getDivisionsByHomileticId");
    throw Exception("Failed to get Divisions By Homiletic Id");
  }
}

Future<void> resetDivisionsTable() async {
  try {
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
  } catch (error) {
    sendError(error, "resetDivisionsTable");
    throw Exception("Failed to reset divisions table");
  }
}

Future<int> insertDivision(Division division) async {
  try {
    final Database db = await database;

    return await db.insert('divisions', division.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertDivision");
    throw Exception("Failed to insert division");
  }
}

Future<void> updateDivision(Division division) async {
  try {
    final Database db = await database;

    await db.update('divisions', division.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [division.id]);
  } catch (error) {
    sendError(error, "updateDivision");
    throw Exception("Failed to update division");
  }
}

Future<void> deleteDivision(Division division) async {
  try {
    final Database db = await database;

    await db.delete('divisions', where: 'id = ?', whereArgs: [division.id]);
  } catch (error) {
    sendError(error, "deleteDivision");
    throw Exception("Failed to delete division");
  }
}

Future<List<Division>> deleteDivisionByHomileticId(int id) async {
  try {
    final Database db = await database;

    List<Division> divisions = await getDivisionsByHomileticId(id);

    await db.delete('divisions', where: 'homiletic_id = ?', whereArgs: [id]);
    return divisions;
  } catch (error) {
    sendError(error, "deleteDivisionByHomileticId");
    throw Exception("Failed to delete divisions by homiletics");
  }
}

Future<List<Division>> getDivisionByText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('divisions', where: 'title LIKE ?', whereArgs: ['%$text%']);

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => Division.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getDivisionByText");
    throw Exception("Failed to get Division By Text");
  }
}
