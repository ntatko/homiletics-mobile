import 'dart:async';

import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:sqflite/sqflite.dart';

/// The database holding the `content_summaries` table (see [AppStorage]).
Future<Database> _db() => AppStorage.database('content_summaries');

Future<List<ContentSummary>> getSummariesByHomileticId(int? id) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db.query('content_summaries',
        where: 'homiletic_id = ?', whereArgs: [id], orderBy: 'id');

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

Future<int> insertSummary(ContentSummary summary) async {
  try {
    final Database db = await _db();

    return await db.insert('content_summaries', summary.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertSummary");
    throw Exception("Failed to insert summary");
  }
}

Future<void> updateSummary(ContentSummary summary) async {
  try {
    final Database db = await _db();

    await db.update('content_summaries', summary.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [summary.id]);
  } catch (error) {
    sendError(error, "updateSummary");
    throw Exception("Failed to update summary");
  }
}

Future<void> deleteSummary(ContentSummary summary) async {
  try {
    final Database db = await _db();

    await db
        .delete('content_summaries', where: 'id = ?', whereArgs: [summary.id]);
  } catch (error) {
    sendError(error, "deleteSummary");
    throw Exception("Failed to delete summary");
  }
}

Future<void> deleteSummaryByHomileticId(int id) async {
  try {
    final Database db = await _db();

    await db.delete('content_summaries',
        where: 'homiletic_id = ?', whereArgs: [id]);
  } catch (error) {
    sendError(error, "deleteSummaryByHomileticId");
    throw Exception("Failed to delete summaries");
  }
}

Future<List<ContentSummary>> getSummaryByText(String text) async {
  try {
    final Database db = await _db();

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
