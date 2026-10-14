import 'dart:async';

import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/common/passage_reference.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:sqflite/sqflite.dart';

/// The database holding the `word_studies` table (see [AppStorage]).
Future<Database> _db() => AppStorage.database('word_studies');

Future<List<WordStudy>> getAllWordStudies() async {
  try {
    final Database db = await _db();

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

Future<int> insertWordStudy(WordStudy study) async {
  try {
    final Database db = await _db();
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
    final Database db = await _db();
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
    final Database db = await _db();

    await db.delete('word_studies', where: 'id = ?', whereArgs: [study.id]);
  } catch (error) {
    sendError(error, "deleteWordStudy");
    throw Exception("failed to delete word study");
  }
}

/// Word studies whose [passage] matches [passage] after [normalizePassageReference],
/// newest [WordStudy.updatedAt] first.
Future<List<WordStudy>> getWordStudiesMatchingPassageReference(
    String passage) async {
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

/// Word studies whose word, definition, other usage, contextual meaning,
/// deeper meaning, or application contains [text].
Future<List<WordStudy>> getWordStudiesByText(String text) async {
  try {
    final Database db = await _db();

    final String like = '%$text%';
    final List<Map<String, dynamic>> maps = await db.query('word_studies',
        where:
            'word LIKE ? OR definition LIKE ? OR other_usage LIKE ? OR contextual_meaning LIKE ? OR deeper_meaning LIKE ? OR application LIKE ?',
        whereArgs: [like, like, like, like, like, like]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => WordStudy.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getWordStudiesByText");
    throw Exception("failed to get word studies by text");
  }
}
