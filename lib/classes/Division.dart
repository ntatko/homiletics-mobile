// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/storage/division_storage.dart';

class Division with SerializedSave {
  /// The title of the division.
  String title;

  /// The passage reference (just text, no rules) of the division.
  String passage;

  /// The homiletic id of the division.
  int homileticId;

  /// The id of the division.
  int? id;

  Division(this.homileticId, {this.title = '', this.passage = '', this.id});

  /// Creates a [Map] representation of the division.
  Map<String, dynamic> toJson() => {
        "title": title,
        "passage": passage,
        "homiletic_id": homileticId,
        "id": id
      };

  Map<String, dynamic> _contentJson() => toJson()..remove('id');

  /// Creates a new [Division] from a JSON map.
  factory Division.fromJson(Map<String, dynamic> json) {
    final Division division = Division(json['homiletic_id'] as int? ?? -1,
        title: json['title'] as String? ?? '',
        passage: json['passage'] as String? ?? '',
        id: json['id'] as int?);
    division.rememberSaved(division._contentJson());
    return division;
  }

  /// Creates a blank [Division] with the given [homileticId].
  factory Division.blank(int homileticId) {
    return Division(homileticId);
  }

  /// Updates the division in the database with whatever is in this object.
  /// Concurrent calls run one after another, and calls after [delete] do
  /// nothing.
  Future<void> update() {
    return serializeSave(() async {
      if (kIsWeb) return;
      final Map<String, dynamic> state = _contentJson();
      if (id == null) {
        id = await insertDivision(this);
      } else if (!matchesSaved(state)) {
        await updateDivision(this);
      }
      rememberSaved(state);
    });
  }

  /// Updates the [passage] of the division.
  Future<void> updatePassage(String text) async {
    passage = text;
    await update();
  }

  /// Updates the [title] of the division.
  Future<void> updateText(String text) async {
    title = text;
    await update();
  }

  /// Deletes the [Division] from the database. Waits for any save in flight
  /// first, and makes later saves no-ops.
  Future<void> delete() {
    markDeleted();
    return serialize(() async {
      if (id == null) return;
      try {
        await deleteDivision(this);
      } catch (_) {
        unmarkDeleted();
        rethrow;
      }
    });
  }
}
