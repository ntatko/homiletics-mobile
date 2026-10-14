import 'dart:async';

import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:sqflite/sqflite.dart';

/// The database holding the `divisions` table (see [AppStorage]).
Future<Database> _db() => AppStorage.database('divisions');

Future<List<Division>> getDivisionsByHomileticId(int? id) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db.query('divisions',
        where: 'homiletic_id = ?', whereArgs: [id], orderBy: 'id');

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

Future<int> insertDivision(Division division) async {
  try {
    final Database db = await _db();

    return await db.insert('divisions', division.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertDivision");
    throw Exception("Failed to insert division");
  }
}

Future<void> updateDivision(Division division) async {
  try {
    final Database db = await _db();

    await db.update('divisions', division.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [division.id]);
  } catch (error) {
    sendError(error, "updateDivision");
    throw Exception("Failed to update division");
  }
}

Future<void> deleteDivision(Division division) async {
  try {
    final Database db = await _db();

    await db.delete('divisions', where: 'id = ?', whereArgs: [division.id]);
  } catch (error) {
    sendError(error, "deleteDivision");
    throw Exception("Failed to delete division");
  }
}

Future<void> deleteDivisionByHomileticId(int id) async {
  try {
    final Database db = await _db();

    await db.delete('divisions', where: 'homiletic_id = ?', whereArgs: [id]);
  } catch (error) {
    sendError(error, "deleteDivisionByHomileticId");
    throw Exception("Failed to delete divisions by homiletics");
  }
}

Future<List<Division>> getDivisionByText(String text) async {
  try {
    final Database db = await _db();

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
