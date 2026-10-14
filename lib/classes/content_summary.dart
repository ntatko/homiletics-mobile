import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/storage/content_summary_storage.dart';

class ContentSummary with SerializedSave {
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

  Map<String, dynamic> _contentJson() => toJson()..remove('id');

  /// Create a new [ContentSummary] from a [Map].
  factory ContentSummary.fromJson(Map<String, dynamic> json) {
    final ContentSummary summary = ContentSummary(
        summary: json['summary'] as String? ?? '',
        passage: json['passage'] as String? ?? '',
        homileticId: json['homiletic_id'] as int? ?? -1,
        id: json['id'] as int?);
    summary.rememberSaved(summary._contentJson());
    return summary;
  }

  /// Update the database with the contents of this [ContentSummary].
  /// Concurrent calls run one after another, and calls after [delete] do
  /// nothing.
  Future<void> update() {
    return serializeSave(() async {
      if (kIsWeb) return;
      final Map<String, dynamic> state = _contentJson();
      if (id == null) {
        id = await insertSummary(this);
      } else if (!matchesSaved(state)) {
        await updateSummary(this);
      }
      rememberSaved(state);
    });
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

  /// Delete this [ContentSummary] from the database. Waits for any save in
  /// flight first, and makes later saves no-ops.
  Future<void> delete() {
    markDeleted();
    return serialize(() async {
      if (id == null) return;
      try {
        await deleteSummary(this);
      } catch (_) {
        unmarkDeleted();
        rethrow;
      }
    });
  }
}
