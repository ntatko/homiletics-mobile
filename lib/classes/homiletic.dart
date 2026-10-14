import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

/// The bread and butter of the app. The [Homiletic] is a collection of [Division]s, [ContentSummary]s, and [Application]s.
class Homiletic with SerializedSave {
  /// The passage referred to by the homiletic.
  String passage;

  /// A list of [ContentSummary]s in the homiletic.
  List<ContentSummary>? summaries;

  /// A list of [Division]s in the homiletic.
  List<Division>? divisions;

  /// The 10-word summary of the homiletic.
  String subjectSentence;

  /// The main truth of the homiletic.
  String aim;

  /// A list of [Application]s in the homiletic.
  List<Application>? applications;

  /// The id of the homiletic. -1 means it has never been saved.
  int id;

  /// The time that the homiletic was last updated.
  DateTime? updatedAt;

  /// The fcf field of the homiletic.
  String fcf;

  Homiletic({
    this.passage = '',
    this.subjectSentence = '',
    this.aim = '',
    this.id = -1,
    this.updatedAt,
    this.fcf = '',
  });

  /// Creates a new [Homiletic] from a JSON map.
  factory Homiletic.fromJson(Map<String, dynamic> json) {
    final Homiletic homiletic = Homiletic(
      passage: json['passage'] as String? ?? '',
      subjectSentence: json['subject_sentence'] as String? ?? '',
      aim: json['aim'] as String? ?? '',
      id: int.tryParse(json['id']?.toString() ?? '') ?? -1,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      fcf: json['fcf'] as String? ?? '',
    );
    homiletic.rememberSaved(homiletic._contentJson());
    return homiletic;
  }

  /// Returns a map representation of the homiletic.
  Map<String, dynamic> toJson() => {
        "passage": passage,
        "subject_sentence": subjectSentence,
        "aim": aim,
        "id": id,
        "updated_at": updatedAt?.toIso8601String() ?? '',
        "fcf": fcf,
      };

  /// The fields a save would actually change (no id or timestamp).
  Map<String, dynamic> _contentJson() => toJson()
    ..remove('id')
    ..remove('updated_at');

  /// Updates the homiletic in the database with whatever is in this object.
  /// Concurrent calls run one after another, calls that change nothing skip
  /// the write (so [updatedAt] isn't bumped), and calls after [delete] do
  /// nothing.
  Future<void> update() {
    return serializeSave(() async {
      if (kIsWeb) return;
      final Map<String, dynamic> state = _contentJson();
      if (id == -1) {
        id = await insertHomiletic(this);
      } else if (!matchesSaved(state)) {
        await updateHomiletic(this);
      }
      rememberSaved(state);
    });
  }

  /// Updates the [passage] of the homiletic.
  Future<void> updatePassage(String text) async {
    passage = text;
    await update();
  }

  /// Updates the [aim] of the homiletic.
  Future<void> updateAim(String text) async {
    aim = text;
    await update();
  }

  /// Updates the [subjectSentence] of the homiletic.
  Future<void> updateSubjectSentence(String text) async {
    subjectSentence = text;
    await update();
  }

  /// Updates the [fcf] of the homiletic.
  Future<void> updateFcf(String text) async {
    fcf = text;
    await update();
  }

  /// Deletes the homiletic from the database, as well as its associated
  /// [ContentSummary]s, [Application]s, and [Division]s, in one transaction.
  /// Waits for any save in flight first, and makes later saves no-ops.
  ///
  /// (While storage is still on the legacy per-table files, the homiletic
  /// row goes first: the worst case is orphaned children rather than a
  /// homiletic that has silently lost its content, and calling this again
  /// retries the child deletes.)
  Future<void> delete() {
    markDeleted();
    return serialize(() async {
      if (id == -1) return;
      try {
        await deleteHomileticWithChildren(id);
      } on HomileticPartiallyDeletedException {
        // The homiletic row is gone; stay deleted.
        rethrow;
      } catch (_) {
        unmarkDeleted();
        rethrow;
      }
    });
  }
}
