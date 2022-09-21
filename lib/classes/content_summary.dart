import 'package:flutter/foundation.dart';
import 'package:homiletics/storage/content_summary_storage.dart';

class ContentSummary {
  /// The body of the content summary.
  String summary;

  /// The passage reference of the content summary.
  String passage;

  /// The id of the content summary.
  int? id;

  /// The id of the Homiletic with which this [ContentSummary] associates to.
  int homileticId;

  ContentSummary(
      {this.summary = '',
      this.passage = '',
      this.id,
      required this.homileticId});

  /// Convert this [ContentSummary] to a [Map].
  Map<String, dynamic> toJson() => {
        "summary": summary,
        "passage": passage,
        "homiletic_id": homileticId,
        "id": id
      };

  /// Create a new [ContentSummary] from a [Map].
  factory ContentSummary.fromJson(Map<String, dynamic> json) {
    return ContentSummary(
        summary: json['summary'],
        passage: json['passage'],
        homileticId: json['homiletic_id'],
        id: json['id']);
  }

  /// Update the database with the contents of this [ContentSummary].
  Future<void> update() async {
    if (!kIsWeb) {
      if (id == null) {
        id = await insertSummary(this);
      } else {
        await updateSummary(this);
      }
    }
  }

  /// Update the [passage] of this [ContentSummary].
  Future<void> updatePassage(String text) async {
    passage = text;
    await update();
  }

  /// Update the [summary] of this [ContentSummary].
  Future<void> updateText(String text) async {
    summary = text;
    await update();
  }

  /// Create a blank [ContentSummary] with the given [homileticId].
  factory ContentSummary.blank(int homileticId) {
    return ContentSummary(homileticId: homileticId);
  }

  /// Delete this [ContentSummary] from the database.
  Future<void> delete() async {
    await deleteSummary(this);
  }
}
