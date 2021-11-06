import 'dart:async';

import 'package:homiletics/classes/passage_schedule.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'passage_schedule.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE passage_schedule (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              reference TEXT,
              rollout TEXT
            )
            ''');
    },
    version: 1,
  );
});

Future<List<PassageSchedule>> getPassageSchedules() async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('passage_schedule');

  if (maps.isEmpty) {
    return [];
  }

  return List.generate(
      maps.length, (index) => PassageSchedule.fromJson(maps[index]));
}

Future<void> putNewSchedules(List<PassageSchedule> schedules) async {
  final Database db = await database;

  Batch batch = db.batch();
  batch.delete('passage_schedule');
  for (PassageSchedule schedule in schedules) {
    batch.insert('passage_schedule', schedule.toJson());
  }

  await batch.commit();
}
