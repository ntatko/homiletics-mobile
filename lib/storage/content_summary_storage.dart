import 'dart:async';

import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/sync_push_for_homiletic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _sumUuid = Uuid();

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
              homiletic_id INTEGER,
              uuid TEXT
            )
            ''');
    },
    version: 2,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE content_summaries ADD COLUMN uuid TEXT');
        final rows = await db.query('content_summaries');
        for (final row in rows) {
          await db.update(
            'content_summaries',
            {'uuid': _sumUuid.v4()},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      }
    },
  );
});

Future<List<ContentSummary>> getSummariesByHomileticId(int? id) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'content_summaries',
      where: 'homiletic_id = ?',
      whereArgs: [id],
      orderBy: 'COALESCE(sort, id) ASC, id ASC',
    );

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

Future<void> updateSummarySortOrder(
    int homileticId, List<ContentSummary> summaries) async {
  try {
    final Database db = await database;
    for (var i = 0; i < summaries.length; i++) {
      final summary = summaries[i];
      summary.sort = i;
      if (summary.id == null) {
        await summary.update();
      }
      await db.update(
        'content_summaries',
        {'sort': i},
        where: 'id = ? AND homiletic_id = ?',
        whereArgs: [summary.id, homileticId],
      );
    }
    await triggerSyncPushForHomileticId(homileticId);
  } catch (error) {
    sendError(error, "updateSummarySortOrder");
    throw Exception("Failed to update summary sort order");
  }
}

Future<List<ContentSummary>> dedupeSummariesByHomileticId(int id) async {
  try {
    final Database db = await database;
    final summaries = await getSummariesByHomileticId(id);
    if (summaries.length < 2) return summaries;

    final seen = <String, ContentSummary>{};
    final duplicateIds = <int>[];

    for (final summary in summaries) {
      final key =
          '${summary.passage.trim()}\u0000${summary.summary.trim()}';
      final existing = seen[key];
      if (existing == null) {
        seen[key] = summary;
        continue;
      }
      if (summary.id != null) {
        duplicateIds.add(summary.id!);
      }
    }

    if (duplicateIds.isNotEmpty) {
      final batch = db.batch();
      for (final duplicateId in duplicateIds) {
        batch.delete(
          'content_summaries',
          where: 'id = ?',
          whereArgs: [duplicateId],
        );
      }
      await batch.commit(noResult: true);
    }

    return seen.values.toList();
  } catch (error) {
    sendError(error, "dedupeSummariesByHomileticId");
    throw Exception("Failed to dedupe summaries");
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
              homiletic_id INTEGER,
              uuid TEXT
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
    if (summary.uuid == null || summary.uuid!.trim().isEmpty) {
      summary.uuid = _sumUuid.v4();
    }

    final id = await db.insert('content_summaries', summary.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await triggerSyncPushForHomileticId(summary.homileticId);
    return id;
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
    await triggerSyncPushForHomileticId(summary.homileticId);
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
    await triggerSyncPushForHomileticId(summary.homileticId);
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
