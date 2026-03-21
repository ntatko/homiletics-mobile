import 'dart:async';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/passage_match.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/sync_trigger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final Future<Database> database = getDatabasesPath().then((String path) {
  return openDatabase(
    join(path, 'homiletics.db'),
    onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE homiletics (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              uuid TEXT,
              passage TEXT,
              subject_sentence TEXT,
              aim TEXT,
              updated_at TEXT,
              fcf TEXT DEFAULT ''
            )
            ''');
    },
    version: 3,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db
            .execute('ALTER TABLE homiletics ADD COLUMN fcf TEXT DEFAULT ""');
      }
      if (oldVersion < 3) {
        await db.execute('ALTER TABLE homiletics ADD COLUMN uuid TEXT');
      }
    },
  );
});

Future<List<Homiletic>> getAllHomiletics() async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('homiletics');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => Homiletic.fromJson(maps[index]));
  } catch (error) {
    sendError(error, "getAllHomiletics");
    throw Exception("Failed to get all homiletics");
  }
}

Future<List<Homiletic>> ensureAllHomileticsHaveUuids() async {
  try {
    final db = await database;
    final homiletics = await getAllHomiletics();
    var changed = false;
    for (final homiletic in homiletics) {
      if (homiletic.uuid != null && homiletic.uuid!.trim().isNotEmpty) {
        continue;
      }
      homiletic.uuid = _uuid.v4();
      await db.update(
        'homiletics',
        {'uuid': homiletic.uuid},
        where: 'id = ?',
        whereArgs: [homiletic.id],
      );
      changed = true;
    }
    if (changed) {
      triggerSyncPush();
    }
    return homiletics;
  } catch (error) {
    sendError(error, "ensureAllHomileticsHaveUuids");
    throw Exception("Failed to ensure homiletic UUIDs");
  }
}

Future<Homiletic> getHomileticById(int id) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('homiletics', where: 'id = ?', whereArgs: [id]);
    return Homiletic.fromJson(maps[0]);
  } catch (error) {
    sendError(error, "getHomileticById");
    throw Exception("Failed to get homiletics by id");
  }
}

Future<Homiletic?> getHomileticByUuid(String uuid) async {
  try {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'homiletics',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Homiletic.fromJson(maps[0]);
  } catch (error) {
    sendError(error, "getHomileticByUuid");
    return null;
  }
}

Future<void> resetTable() async {
  try {
    final Database db = await database;
    await db.execute("DROP TABLE IF EXISTS homiletics ");
    await db.execute('''
            CREATE TABLE homiletics (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              uuid TEXT,
              passage TEXT,
              subject_sentence TEXT,
              aim TEXT,
              updated_at TEXT,
              fcf TEXT DEFAULT ''
            )
            ''');
  } catch (error) {
    sendError(error, "resetTable");
    throw Exception("Failed to resetTable");
  }
}

Future<int> insertHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await database;
    homiletic.updatedAt = DateTime.now();
    if (homiletic.uuid == null || homiletic.uuid!.isEmpty) {
      homiletic.uuid = _uuid.v4();
    }

    final id = await db.insert('homiletics', homiletic.toJson()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
    triggerSyncPush(homileticUuid: homiletic.uuid);
    return id;
  } catch (error) {
    sendError(error, "insertHomiletic");
    throw Exception("Failed to insert homiletic");
  }
}

Future<void> updateHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await database;
    homiletic.updatedAt = DateTime.now();
    if (homiletic.uuid == null || homiletic.uuid!.isEmpty) {
      homiletic.uuid = _uuid.v4();
    }

    await db.update('homiletics', homiletic.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [homiletic.id]);
    triggerSyncPush(homileticUuid: homiletic.uuid);
  } catch (error) {
    sendError(error, "updateHomiletic");
    throw Exception("Failed to update homiletic");
  }
}

Future<void> deleteHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await database;
    final u = homiletic.uuid?.trim();

    await db.delete('homiletics', where: 'id = ?', whereArgs: [homiletic.id]);
    if (u != null && u.isNotEmpty) {
      triggerSyncPush(homileticUuid: u, removed: true);
    } else {
      triggerSyncPush();
    }
  } catch (error) {
    sendError(error, "deleteHomiletic");
    throw Exception("Failed to delete homiletic");
  }
}

Future<List<Homiletic>> getHomileticsByPassageText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('homiletics', where: 'passage LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByText");
    throw Exception("Failed to get homiletics by text");
  }
}

/// Most recently updated homiletic whose passage matches [passage] (normalized), or null.
Future<Homiletic?> getHomileticForPassageIfExists(String passage) async {
  try {
    final target = normalizePassageRef(passage);
    final all = await getAllHomiletics();
    Homiletic? best;
    for (final h in all) {
      if (normalizePassageRef(h.passage) != target) continue;
      if (best == null) {
        best = h;
        continue;
      }
      final a = h.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final b = best.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (a.isAfter(b)) best = h;
    }
    return best;
  } catch (error) {
    sendError(error, "getHomileticForPassageIfExists");
    return null;
  }
}

Future<List<Homiletic>> getHomileticsBySummarySentenceText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('homiletics',
        where: 'subject_sentence LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByText");
    throw Exception("Failed to get homiletics by text");
  }
}

Future<List<Homiletic>> getHomileticsByAimText(String text) async {
  try {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query('homiletics', where: 'aim LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByText");
    throw Exception("Failed to get homiletics by text");
  }
}
