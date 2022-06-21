import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

class Homiletic {
  String passage;
  List<ContentSummary>? summaries;
  List<Division>? divisions;
  String subjectSentence;
  String aim;
  List<Application>? applications;
  int id;
  DateTime? updatedAt;

  Homiletic({this.passage = '', this.subjectSentence = '', this.aim = '', this.id = -1, this.updatedAt});

  factory Homiletic.fromJson(Map<String, dynamic> json) {
    return Homiletic(
        passage: json['passage'].toString(),
        subjectSentence: json['subject_sentence'].toString(),
        aim: json['aim'].toString(),
        id: int.parse(json['id'].toString()),
        updatedAt: DateTime.parse(json['updated_at']));
  }

  Map<String, dynamic> toJson() => {
        "passage": passage,
        "subject_sentence": subjectSentence,
        "aim": aim,
        "id": id,
        "updated_at": updatedAt?.toIso8601String() ?? ''
      };

  Future<void> update() async {
    if (id == -1) {
      id = await insertHomiletic(this);
    } else {
      await updateHomiletic(this);
    }
  }

  Future<void> updatePassage(String text) async {
    passage = text;
    await update();
  }

  Future<void> updateAim(String text) async {
    aim = text;
    await update();
  }

  Future<void> updateSubjectSentence(String text) async {
    subjectSentence = text;
    await update();
  }

  Future<Map<String, dynamic>> delete() async {
    List<ContentSummary> summaries = await deleteSummaryByHomileticId(id);
    List<Application> applications = await deleteApplicationByHomileticId(id);
    List<Division> divisions = await deleteDivisionByHomileticId(id);
    await deleteHomiletic(this);
    return {"summaries": summaries, "applications": applications, "divisions": divisions, "homiletic": this};
  }
}
