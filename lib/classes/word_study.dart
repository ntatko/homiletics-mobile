import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/storage/word_study_storage.dart';

class WordStudy with SerializedSave {
  /// The id of the word study. -1 means it has never been saved.
  int id;

  /// The passage the word study is for.
  String passage;

  /// The specific word or short phrase being studied.
  String word;

  /// What the word means, in plain terms.
  String definition;

  /// Where else the word or concept appears in Scripture.
  String otherUsage;

  /// What the author intended the word to mean in this passage.
  String contextualMeaning;

  /// Insight from the original language, commentary, or outside study.
  String deeperMeaning;

  /// How this truth should shape the reader's life.
  String application;

  /// The time the word study was last updated.
  DateTime? updatedAt;

  WordStudy(
      {this.id = -1,
      this.passage = '',
      this.word = '',
      this.definition = '',
      this.otherUsage = '',
      this.contextualMeaning = '',
      this.deeperMeaning = '',
      this.application = '',
      this.updatedAt});

  /// Creates a new [WordStudy] from a JSON map.
  factory WordStudy.fromJson(Map<String, dynamic> json) {
    final WordStudy study = WordStudy(
        id: json['id'] as int? ?? -1,
        passage: json['passage'] as String? ?? '',
        word: json['word'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        otherUsage: json['other_usage'] as String? ?? '',
        contextualMeaning: json['contextual_meaning'] as String? ?? '',
        deeperMeaning: json['deeper_meaning'] as String? ?? '',
        application: json['application'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''));
    study.rememberSaved(study._contentJson());
    return study;
  }

  /// Returns a map representation of the word study.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "passage": passage,
      "word": word,
      "definition": definition,
      "other_usage": otherUsage,
      "contextual_meaning": contextualMeaning,
      "deeper_meaning": deeperMeaning,
      "application": application,
      "updated_at": updatedAt?.toIso8601String() ?? ''
    };
  }

  /// The fields a save would actually change (no id or timestamp).
  Map<String, dynamic> _contentJson() => toJson()
    ..remove('id')
    ..remove('updated_at');

  /// Updates the word study in the database with whatever is in this object.
  /// Concurrent calls run one after another, calls that change nothing skip
  /// the write (so [updatedAt] isn't bumped), and calls after [delete] do
  /// nothing.
  Future<void> update() {
    return serializeSave(() async {
      if (kIsWeb) return;
      final Map<String, dynamic> state = _contentJson();
      if (id == -1) {
        id = await insertWordStudy(this);
      } else if (!matchesSaved(state)) {
        await updateWordStudy(this);
      }
      rememberSaved(state);
    });
  }

  /// Updates the passage in the database with the parameter of this function.
  Future<void> updatePassage(String updatePassage) async {
    passage = updatePassage;
    await update();
  }

  /// Updates the word in the database with the parameter of this function.
  Future<void> updateWord(String updateWord) async {
    word = updateWord;
    await update();
  }

  /// Updates the definition in the database with the parameter of this function.
  Future<void> updateDefinition(String updateDefinition) async {
    definition = updateDefinition;
    await update();
  }

  /// Updates the other usage in the database with the parameter of this function.
  Future<void> updateOtherUsage(String updateOtherUsage) async {
    otherUsage = updateOtherUsage;
    await update();
  }

  /// Updates the contextual meaning in the database with the parameter of this function.
  Future<void> updateContextualMeaning(String updateContextualMeaning) async {
    contextualMeaning = updateContextualMeaning;
    await update();
  }

  /// Updates the deeper meaning in the database with the parameter of this function.
  Future<void> updateDeeperMeaning(String updateDeeperMeaning) async {
    deeperMeaning = updateDeeperMeaning;
    await update();
  }

  /// Updates the application in the database with the parameter of this function.
  Future<void> updateApplication(String updateApplication) async {
    application = updateApplication;
    await update();
  }

  /// Deletes the word study in the database. Waits for any save in flight
  /// first, and makes later saves no-ops so the study can't be re-inserted.
  /// [id] is left as-is.
  Future<WordStudy> delete() async {
    markDeleted();
    await serialize(() async {
      if (id == -1) return;
      try {
        await deleteWordStudy(this);
      } catch (_) {
        unmarkDeleted();
        rethrow;
      }
    });
    return this;
  }
}
