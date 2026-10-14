import 'dart:async';

import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:sqflite/sqflite.dart';

/// The database holding the `applications` table (see [AppStorage]).
Future<Database> _db() => AppStorage.database('applications');

Future<List<Application>> getApplicationsByHomileticId(int? id) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db.query('applications',
        where: 'homiletic_id = ?', whereArgs: [id], orderBy: 'id');

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => Application.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getApplicationsByHomileticId");
    throw Exception("Failed to fetch Applications");
  }
}

Future<int> insertApplication(Application application) async {
  try {
    final Database db = await _db();

    return await db.insert('applications', application.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertApplication");
    throw Exception("Failed to insert Application");
  }
}

Future<void> updateApplication(Application application) async {
  try {
    final Database db = await _db();

    await db.update('applications', application.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [application.id]);
  } catch (error) {
    sendError(error, "updateApplication");
    throw Exception("Failed to update application");
  }
}

Future<void> deleteApplication(Application application) async {
  try {
    final Database db = await _db();

    await db
        .delete('applications', where: 'id = ?', whereArgs: [application.id]);
  } catch (error) {
    sendError(error, "deleteApplication");
    throw Exception("Failed to delete application");
  }
}

Future<void> deleteApplicationByHomileticId(int id) async {
  try {
    final Database db = await _db();

    await db.delete('applications', where: 'homiletic_id = ?', whereArgs: [id]);
  } catch (error) {
    sendError(error, "deleteApplicationByHomileticId");
    throw Exception("Failed to delete applications by homiletic ID");
  }
}

Future<List<Application>> getAllApplications() async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db.query('applications');

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => Application.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getAllApplications");
    throw Exception("Failed to get all applications");
  }
}

/// Like [getAllApplications] but sets [Application.homileticPassage] for each row
/// (homiletics live in a separate DB, so this does one lookup per distinct homiletic id).
Future<List<Application>> getAllApplicationsWithPassages() async {
  final apps = await getAllApplications();
  if (apps.isEmpty) return apps;

  final ids = apps.map((a) => a.homileticsId).toSet();
  final passageById = <int, String>{};
  for (final id in ids) {
    try {
      final h = await getHomileticById(id);
      passageById[id] = h.passage.trim();
    } catch (_) {
      passageById[id] = '';
    }
  }
  for (final a in apps) {
    final p = passageById[a.homileticsId];
    a.homileticPassage = (p != null && p.isNotEmpty) ? p : null;
  }
  return apps;
}

Future<List<Application>> getApplicationsByText(String text) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db
        .query('applications', where: 'text LIKE ?', whereArgs: ['%$text%']);

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(
        maps.length, (index) => Application.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getApplicationsByText");
    throw Exception("Failed to get applications by text");
  }
}
