import 'dart:async';

import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/passage_reference.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/storage/app_database.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:sqflite/sqflite.dart';

/// The database holding the `homiletics` table (see [AppStorage]).
Future<Database> _db() => AppStorage.database('homiletics');

Future<List<Homiletic>> getAllHomiletics() async {
  try {
    final Database db = await _db();

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

Future<Homiletic> getHomileticById(int id) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps =
        await db.query('homiletics', where: 'id = ?', whereArgs: [id]);
    return Homiletic.fromJson(maps[0]);
  } catch (error) {
    sendError(error, "getHomileticById");
    throw Exception("Failed to get homiletics by id");
  }
}

Future<int> insertHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await _db();
    homiletic.updatedAt = DateTime.now();

    // No REPLACE: with foreign keys on, replacing a homiletic row would
    // cascade-delete its children.
    return await db.insert('homiletics', homiletic.toJson()..remove('id'));
  } catch (error) {
    sendError(error, "insertHomiletic");
    throw Exception("Failed to insert homiletic");
  }
}

Future<void> updateHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await _db();
    homiletic.updatedAt = DateTime.now();

    await db.update('homiletics', homiletic.toJson()..remove('id'),
        where: 'id = ?', whereArgs: [homiletic.id]);
  } catch (error) {
    sendError(error, "updateHomiletic");
    throw Exception("Failed to update homiletic");
  }
}

/// Deletes just the homiletic row. In the single database its content
/// summaries, divisions and applications go with it (ON DELETE CASCADE);
/// prefer [deleteHomileticWithChildren], which does that on legacy storage
/// too.
Future<void> deleteHomiletic(Homiletic homiletic) async {
  try {
    final Database db = await _db();

    await db.delete('homiletics', where: 'id = ?', whereArgs: [homiletic.id]);
  } catch (error) {
    sendError(error, "deleteHomiletic");
    throw Exception("Failed to delete homiletic");
  }
}

/// Thrown by [deleteHomileticWithChildren] when the homiletic row was
/// deleted but some of its rows weren't (only possible while storage is
/// still on the legacy per-table files). Calling it again retries them.
class HomileticPartiallyDeletedException implements Exception {
  final Object cause;
  HomileticPartiallyDeletedException(this.cause);
  @override
  String toString() => 'HomileticPartiallyDeletedException: $cause';
}

/// Deletes the homiletic [id] with its content summaries, divisions and
/// applications, in one transaction — either all of it goes or none of it.
///
/// While storage is still on the legacy per-table files (the migration
/// hasn't succeeded yet; see [AppStorage]) that isn't possible, so the
/// homiletic goes first and then its rows, throwing
/// [HomileticPartiallyDeletedException] if only the first part worked.
Future<void> deleteHomileticWithChildren(int id) async {
  final AppStorage storage = await AppStorage.instance;
  if (storage.isUnified) {
    try {
      final Database db = await storage.databaseFor('homiletics');
      await db.transaction((Transaction txn) async {
        // ON DELETE CASCADE would remove these too; deleting them explicitly
        // keeps this correct even if foreign keys were somehow off.
        for (final String table in kHomileticChildTables) {
          await txn.delete(table, where: 'homiletic_id = ?', whereArgs: [id]);
        }
        await txn.delete('homiletics', where: 'id = ?', whereArgs: [id]);
      });
    } catch (error) {
      sendError(error, "deleteHomileticWithChildren");
      throw Exception("Failed to delete homiletic");
    }
    return;
  }

  try {
    final Database db = await storage.databaseFor('homiletics');
    await db.delete('homiletics', where: 'id = ?', whereArgs: [id]);
  } catch (error) {
    sendError(error, "deleteHomileticWithChildren");
    throw Exception("Failed to delete homiletic");
  }
  try {
    await Future.wait([
      deleteSummaryByHomileticId(id),
      deleteApplicationByHomileticId(id),
      deleteDivisionByHomileticId(id),
    ]);
  } catch (error) {
    throw HomileticPartiallyDeletedException(error);
  }
}

/// Homiletics whose [passage] matches [passage] after [normalizePassageReference],
/// newest [Homiletic.updatedAt] first.
Future<List<Homiletic>> getHomileticsMatchingPassageReference(
    String passage) async {
  try {
    final String key = normalizePassageReference(passage);
    if (key.isEmpty) {
      return [];
    }
    final List<Homiletic> all = await getAllHomiletics();
    final List<Homiletic> matches = all
        .where((Homiletic h) => normalizePassageReference(h.passage) == key)
        .toList();
    matches.sort((Homiletic a, Homiletic b) {
      final DateTime ta = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime tb = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
    return matches;
  } catch (error) {
    sendError(error, "getHomileticsMatchingPassageReference");
    throw Exception("Failed to get homiletics by passage reference");
  }
}

Future<List<Homiletic>> getHomileticsByPassageText(String text) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db
        .query('homiletics', where: 'passage LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByPassageText");
    throw Exception("Failed to get homiletics by passage text");
  }
}

Future<List<Homiletic>> getHomileticsBySummarySentenceText(String text) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db.query('homiletics',
        where: 'subject_sentence LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsBySummarySentenceText");
    throw Exception("Failed to get homiletics by subject sentence text");
  }
}

Future<List<Homiletic>> getHomileticsByAimText(String text) async {
  try {
    final Database db = await _db();

    final List<Map<String, dynamic>> maps = await db
        .query('homiletics', where: 'aim LIKE ?', whereArgs: ['%$text%']);
    return List.generate(maps.length, (i) {
      return Homiletic.fromJson(maps[i]);
    });
  } catch (error) {
    sendError(error, "getHomileticsByAimText");
    throw Exception("Failed to get homiletics by aim text");
  }
}
