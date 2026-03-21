import 'dart:async';

import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/sync_push_for_homiletic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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
              homiletic_id INTEGER,
              uuid TEXT
            )
            ''');
    },
    version: 2,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE divisions ADD COLUMN uuid TEXT');
        final rows = await db.query('divisions');
        for (final row in rows) {
          await db.update(
            'divisions',
            {'uuid': _uuid.v4()},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      }
    },
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
              homiletic_id INTEGER,
              uuid TEXT
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
    if (division.uuid == null || division.uuid!.trim().isEmpty) {
      division.uuid = _uuid.v4();
    }

    final id = await db.insert('divisions', division.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await triggerSyncPushForHomileticId(division.homileticId);
    return id;
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
    await triggerSyncPushForHomileticId(division.homileticId);
  } catch (error) {
    sendError(error, "updateDivision");
    throw Exception("Failed to update division");
  }
}

Future<void> deleteDivision(Division division) async {
  try {
    final Database db = await database;

    await db.delete('divisions', where: 'id = ?', whereArgs: [division.id]);
    await triggerSyncPushForHomileticId(division.homileticId);
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
