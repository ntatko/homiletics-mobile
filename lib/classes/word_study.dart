import 'package:flutter/foundation.dart';
import 'package:homiletics/storage/word_study_storage.dart';

class WordStudy {
  /// The id of the word study.
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
    return WordStudy(
        id: json['id'],
        passage: json['passage'],
        word: json['word'],
        definition: json['definition'],
        otherUsage: json['other_usage'],
        contextualMeaning: json['contextual_meaning'],
        deeperMeaning: json['deeper_meaning'],
        application: json['application'],
        updatedAt: json['updated_at'] != null && json['updated_at'] != ''
            ? DateTime.parse(json['updated_at'])
            : null);
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

  /// Updates the word study in the database with whatever is in this object.
  Future<void> update() async {
    if (!kIsWeb) {
      if (id == -1) {
        id = await insertWordStudy(this);
      } else {
        await updateWordStudy(this);
      }
    }
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

  /// Deletes the word study in the database.
  Future<WordStudy> delete() async {
    await deleteWordStudy(this);
    id = -1;
    return this;
  }
}
