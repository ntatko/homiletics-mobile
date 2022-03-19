import 'dart:async';

import 'package:homiletics/classes/homiletic.dart';
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
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('homiletics');

  if (maps.isEmpty) {
    return [];
  }

  return List.generate(maps.length, (index) => Homiletic.fromJson(maps[index]));
}

Future<Homiletic> getHomileticById(int id) async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps =
      await db.query('homiletics', where: 'id = ?', whereArgs: [id]);
  return Homiletic.fromJson(maps[0]);
}

Future<void> resetTable() async {
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
}

Future<int> insertHomiletic(Homiletic homiletic) async {
  final Database db = await database;
  homiletic.updatedAt = DateTime.now();

  return await db.insert('homiletics', homiletic.toJson()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> updateHomiletic(Homiletic homiletic) async {
  final Database db = await database;
  homiletic.updatedAt = DateTime.now();

  await db.update('homiletics', homiletic.toJson()..remove('id'),
      where: 'id = ?', whereArgs: [homiletic.id]);
}

Future<void> deleteHomiletic(Homiletic homiletic) async {
  final Database db = await database;

  await db.delete('homiletics', where: 'id = ?', whereArgs: [homiletic.id]);
}
