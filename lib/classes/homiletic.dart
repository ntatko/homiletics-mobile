import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
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

  Homiletic(
      {this.passage = '',
      this.subjectSentence = '',
      this.aim = '',
      this.id = -1,
      this.updatedAt});

  factory Homiletic.fromJson(Map<String, dynamic> json) {
    return Homiletic(
        passage: json['passage'],
        subjectSentence: json['subject_sentence'],
        aim: json['aim'],
        id: json['id'],
        updatedAt: DateTime(json['updated_at']));
  }

  Map<String, dynamic> toJson() => {
        "passage": passage,
        "subject_sentence": subjectSentence,
        "aim": aim,
        "id": id
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
}
