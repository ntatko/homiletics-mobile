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

  /// Creates a new [Division] from a JSON map.
  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(json['homiletic_id'],
        title: json['title'], passage: json['passage'], id: json['id']);
  }

  /// Creates a blank [Division] with the given [homileticId].
  factory Division.blank(int homileticId) {
    return Division(homileticId);
  }

  /// Updates the division in the database with whatever is in this object.
  Future<void> update() async {
    if (!kIsWeb) {
      if (id == null) {
        id = await insertDivision(this);
      } else {
        await updateDivision(this);
      }
    }
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
