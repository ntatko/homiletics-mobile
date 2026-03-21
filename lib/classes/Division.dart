// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:homiletics/storage/division_storage.dart';

class Division {
  /// The title of the division.
  String title;

  /// The passage reference (just text, no rules) of the division.
  String passage;

  /// The homiletic id of the division.
  int homileticId;

  /// Stable id for operational sync (cross-device).
  String? uuid;

  /// The id of the division.
  int? id;
  Future<void> _pendingWrite = Future<void>.value();

  Division(this.homileticId,
      {this.title = '', this.passage = '', this.id, this.uuid});

  /// Creates a [Map] representation of the division.
  Map<String, dynamic> toJson() => {
        "title": title,
        "passage": passage,
        "homiletic_id": homileticId,
        "id": id,
        "uuid": uuid,
      };

  /// Creates a new [Division] from a JSON map.
  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(json['homiletic_id'],
        title: json['title'] ?? '',
        passage: json['passage'] ?? '',
        id: json['id'],
        uuid: json['uuid']?.toString());
  }

  /// Creates a blank [Division] with the given [homileticId].
  factory Division.blank(int homileticId) {
    return Division(homileticId);
  }

  /// Updates the division in the database with whatever is in this object.
  Future<void> update() async {
    if (kIsWeb) return;
    _pendingWrite = _pendingWrite.catchError((_) {}).then((_) async {
      if (id == null) {
        id = await insertDivision(this);
      } else {
        await updateDivision(this);
      }
    });
    await _pendingWrite;
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

  /// Deletes the [Division] from the database.
  Future<void> delete() async {
    await deleteDivision(this);
  }
}
