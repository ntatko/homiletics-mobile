import 'dart:async';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'homiletics.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE homiletics (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              passage TEXT,
              subject_sentence TEXT,
              aim TEXT,
              updated_at TEXT
            )
            ''');
    },
    version: 1,
  );
});

Future<List<Homiletic>> getAllHomiletics() async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('homiletics');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => Homiletic.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getAllHomiletics");
    throw Exception("Failed to get all homiletics");
  }
}

Future<Homiletic> getHomileticById(int id) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('homiletics', where: 'id = ?', whereArgs: [id]);
    return Homiletic.fromJson(maps[0]);
  } catch (error) {
    sendError(error, "getHomileticById");
    throw Exception("Failed to get homiletics by id");
  }
}

Future<void> resetTable() async {
  try {
    final Database db = await database;
    await db.execute("DROP TABLE IF EXISTS homiletics ");
    await db.execute('''
            CREATE TABLE homiletics (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              passage TEXT,
              subject_sentence TEXT,
              aim TEXT,
              updated_at TEXT
            )
            ''');
  } catch (error) {
    sendError(error, "resetTable");
    throw Exception("Failed to resetTable");
  }
}

Future<int> insertHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await database;
    homiletic.updatedAt = DateTime.now();

    return await db.insert('homiletics', homiletic.toJson()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertHomiletic");
    throw Exception("Failed to insert homiletic");
  }
}

Future<void> updateHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await database;
    homiletic.updatedAt = DateTime.now();

    await db.update('homiletics', homiletic.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [homiletic.id]);
  } catch (error) {
    sendError(error, "updateHomiletic");
    throw Exception("Failed to update homiletic");
  }
}

Future<void> deleteHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await database;

    await db.delete('homiletics', where: 'id = ?', whereArgs: [homiletic.id]);
  } catch (error) {
    sendError(error, "deleteHomiletic");
    throw Exception("Failed to delete homiletic");
  }
}

Future<List<Homiletic>> getHomileticsByPassageText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('homiletics', where: 'passage LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByText");
    throw Exception("Failed to get homiletics by text");
  }
}

Future<List<Homiletic>> getHomileticsBySummarySentenceText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('homiletics',
        where: 'subject_sentence LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByText");
    throw Exception("Failed to get homiletics by text");
  }
}

Future<List<Homiletic>> getHomileticsByAimText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('homiletics', where: 'aim LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByText");
    throw Exception("Failed to get homiletics by text");
  }
}
