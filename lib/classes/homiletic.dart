import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

/// The bread and butter of the app. The [Homiletic] is a collection of [Division]s, [ContentSummary]s, and [Application]s.
class Homiletic {
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

  /// The id of the homiletic.
  int id;

  /// The time that the homiletic was last updated.
  DateTime? updatedAt;

  Homiletic(
      {this.passage = '',
      this.subjectSentence = '',
      this.aim = '',
      this.id = -1,
      this.updatedAt});

  /// Creates a new [Homiletic] from a JSON map.
  factory Homiletic.fromJson(Map<String, dynamic> json) {
    return Homiletic(
        passage: json['passage'].toString(),
        subjectSentence: json['subject_sentence'].toString(),
        aim: json['aim'].toString(),
        id: int.parse(json['id'].toString()),
        updatedAt: DateTime.parse(json['updated_at']));
  }

  /// Returns a map representation of the homiletic.
  Map<String, dynamic> toJson() => {
        "passage": passage,
        "subject_sentence": subjectSentence,
        "aim": aim,
        "id": id,
        "updated_at": updatedAt?.toIso8601String() ?? ''
      };

  /// Updates the homiletic in the database with whatever is in this object.
  Future<void> update() async {
    if (!kIsWeb) {
      if (id == -1) {
        id = await insertHomiletic(this);
      } else {
        await updateHomiletic(this);
      }
    }
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

  /// Deletes the homiletic from the database, as well as its associated
  /// [ContentSummary]s, [Application]s, and [Division]s.
  Future<Map<String, dynamic>> delete() async {
    List<ContentSummary> summaries = await deleteSummaryByHomileticId(id);
    List<Application> applications = await deleteApplicationByHomileticId(id);
    List<Division> divisions = await deleteDivisionByHomileticId(id);
    await deleteHomiletic(this);
    return {
      "summaries": summaries,
      "applications": applications,
      "divisions": divisions,
      "homiletic": this
    };
  }
}
