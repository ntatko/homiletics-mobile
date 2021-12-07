import 'dart:async';

import 'package:homiletics/classes/content_summary.dart';
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
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db
      .query('content_summaries', where: 'homiletic_id = ?', whereArgs: [id]);

  if (maps.isEmpty) {
    return [];
  }
  return List.generate(
      maps.length, (index) => ContentSummary.fromJson(maps[index]));
}

Future<void> resetSummariesTable() async {
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
}

Future<int> insertSummary(ContentSummary summary) async {
  final Database db = await database;

  return await db.insert('content_summaries', summary.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> updateSummary(ContentSummary summary) async {
  final Database db = await database;

  await db.update('content_summaries', summary.toJson()..remove('id'),
      where: 'id = ?', whereArgs: [summary.id]);
}

Future<void> deleteSummary(ContentSummary summary) async {
  final Database db = await database;

  await db
      .delete('content_summaries', where: 'id = ?', whereArgs: [summary.id]);
}

Future<List<ContentSummary>> deleteSummaryByHomileticId(int id) async {
  final Database db = await database;

  List<ContentSummary> summaries = await getSummariesByHomileticId(id);

  await db
      .delete('content_summaries', where: 'homiletic_id = ?', whereArgs: [id]);
  return summaries;
}
