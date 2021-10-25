import 'dart:async';

import 'package:homiletics/classes/application.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'applications.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE applications (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              text TEXT,
              homiletic_id INTEGER
            )
            ''');
    },
    version: 1,
  );
});

Future<List<Application>> getApplicationsByHomileticId(int? id) async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db
      .query('applications', where: 'homiletic_id = ?', whereArgs: [id]);

  if (maps.isEmpty) {
    return [];
  }
  return List.generate(
      maps.length, (index) => Application.fromJson(maps[index]));
}

Future<void> resetApplicationsTable() async {
  final Database db = await database;
  await db.execute("DROP TABLE IF EXISTS applications ");
  await db.execute('''
            CREATE TABLE applications (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              text TEXT,
              homiletic_id INTEGER
            )
            ''');
}

Future<int> insertApplication(Application application) async {
  final Database db = await database;

  return await db.insert('applications', application.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> updateApplication(Application application) async {
  final Database db = await database;

  await db.update('applications', application.toJson()..remove('id'),
      where: 'id = ?', whereArgs: [application.id]);
}

Future<void> deleteApplication(Application application) async {
  final Database db = await database;

  await db.delete('applications', where: 'id = ?', whereArgs: [application.id]);
}

Future<List<Application>> deleteApplicationByHomileticId(int id) async {
  final Database db = await database;

  List<Application> things = await getApplicationsByHomileticId(id);

  await db.delete('applications', where: 'homiletic_id = ?', whereArgs: [id]);
  return things;
}
