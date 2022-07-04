import 'dart:async';

import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'contentSummaries.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE content_summaries (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              summary TEXT,
              passage TEXT,
              sort INTEGER,
              homiletic_id INTEGER
            )
            ''');
    },
    version: 1,
  );
});

Future<List<ContentSummary>> getSummariesByHomileticId(int? id) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('content_summaries', where: 'homiletic_id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => ContentSummary.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getSummariesByHomileticId");
    throw Exception("Failed to get Summaries by Homiletic ID");
  }
}

Future<void> resetSummariesTable() async {
  try {
    final Database db = await database;
    await db.execute("DROP TABLE IF EXISTS content_summaries ");
    await db.execute('''
            CREATE TABLE content_summaries (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              summary TEXT,
              passage TEXT,
              sort INTEGER,
              homiletic_id INTEGER
            )
            ''');
  } catch (error) {
    sendError(error, "resetSummariesTable");
    throw Exception("Failed to reset summaries table");
  }
}

Future<int> insertSummary(ContentSummary summary) async {
  try {
    final Database db = await database;

    return await db.insert('content_summaries', summary.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertSummary");
    throw Exception("Failed to insert summary");
  }
}

Future<void> updateSummary(ContentSummary summary) async {
  try {
    final Database db = await database;

    await db.update('content_summaries', summary.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [summary.id]);
  } catch (error) {
    sendError(error, "updateSummary");
    throw Exception("Failed to update summary");
  }
}

Future<void> deleteSummary(ContentSummary summary) async {
  try {
    final Database db = await database;

    await db
        .delete('content_summaries', where: 'id = ?', whereArgs: [summary.id]);
  } catch (error) {
    sendError(error, "deleteSummary");
    throw Exception("Failed to delete summary");
  }
}

Future<List<ContentSummary>> deleteSummaryByHomileticId(int id) async {
  try {
    final Database db = await database;

    List<ContentSummary> summaries = await getSummariesByHomileticId(id);

    await db.delete('content_summaries',
        where: 'homiletic_id = ?', whereArgs: [id]);
    return summaries;
  } catch (error) {
    sendError(error, "deleteSummaryByHomileticId");
    throw Exception("Failed to delete summaries");
  }
}

Future<List<ContentSummary>> getSummaryByText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('content_summaries',
        where: 'summary LIKE ?', whereArgs: ['%$text%']);
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => ContentSummary.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getSummaryByText");
    throw Exception("Failed to get summaries by text");
  }
}
