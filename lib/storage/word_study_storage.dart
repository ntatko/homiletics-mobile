import 'dart:async';

import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/common/passage_reference.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'word_studies.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE word_studies (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              passage TEXT,
              word TEXT,
              definition TEXT,
              other_usage TEXT,
              contextual_meaning TEXT,
              deeper_meaning TEXT,
              application TEXT,
              updated_at TEXT
            )
            ''');
    },
    version: 1,
  );
});

Future<List<WordStudy>> getAllWordStudies() async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('word_studies');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => WordStudy.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getAllWordStudies");
    throw Exception("failed to get word studies");
  }
}

Future<void> resetWordStudyTable() async {
  try {
    final Database db = await database;
    await db.execute("DROP TABLE IF EXISTS word_studies ");
    await db.execute('''
            CREATE TABLE word_studies (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              passage TEXT,
              word TEXT,
              definition TEXT,
              other_usage TEXT,
              contextual_meaning TEXT,
              deeper_meaning TEXT,
              application TEXT,
              updated_at TEXT
            )
            ''');
  } catch (error) {
    sendError(error, "resetWordStudyTable");
    throw Exception("failed to reset word studies table");
  }
}

Future<int> insertWordStudy(WordStudy study) async {
  try {
    final Database db = await database;
    study.updatedAt = DateTime.now();

    return await db.insert('word_studies', study.toJson()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
  } catch (error) {
    sendError(error, "insertWordStudy");
    throw Exception("failed to insert word study");
  }
}

Future<void> updateWordStudy(WordStudy study) async {
  try {
    final Database db = await database;
    study.updatedAt = DateTime.now();

    await db.update('word_studies', study.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [study.id]);
  } catch (error) {
    sendError(error, "updateWordStudy");
    throw Exception("failed to update word study");
  }
}

Future<void> deleteWordStudy(WordStudy study) async {
  try {
    final Database db = await database;

    await db.delete('word_studies', where: 'id = ?', whereArgs: [study.id]);
  } catch (error) {
    sendError(error, "deleteWordStudy");
    throw Exception("failed to delete word study");
  }
}

/// Word studies whose [passage] matches [passage] after [normalizePassageReference],
/// newest [WordStudy.updatedAt] first.
Future<List<WordStudy>> getWordStudiesMatchingPassageReference(String passage) async {
  try {
    final String key = normalizePassageReference(passage);
    if (key.isEmpty) {
      return [];
    }
    final List<WordStudy> all = await getAllWordStudies();
    final List<WordStudy> matches = all
        .where((WordStudy s) => normalizePassageReference(s.passage) == key)
        .toList();
    matches.sort((WordStudy a, WordStudy b) {
      final DateTime ta = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime tb = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
    return matches;
  } catch (error) {
    sendError(error, "getWordStudiesMatchingPassageReference");
    throw Exception("failed to get word studies by passage reference");
  }
}
