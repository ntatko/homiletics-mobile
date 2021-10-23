import 'package:homiletics/storage/content_summary_storage.dart';

class ContentSummary {
  String summary;
  String passage;
  int? id;
  int homileticId;

  ContentSummary(
      {this.summary = '',
      this.passage = '',
      this.id,
      required this.homileticId});

  Map<String, dynamic> toJson() => {
        "summary": summary,
        "passage": passage,
        "homiletic_id": homileticId,
        "id": id
      };

  factory ContentSummary.fromJson(Map<String, dynamic> json) {
    return ContentSummary(
        summary: json['summary'],
        passage: json['passage'],
        homileticId: json['homiletic_id'],
        id: json['id']);
  }

  Future<void> update() async {
    if (id == null) {
      id = await insertSummary(this);
    } else {
      await updateSummary(this);
    }
  }

  Future<void> updatePassage(String text) async {
    passage = text;
    await update();
  }

  Future<void> updateText(String text) async {
    summary = text;
    await update();
  }

  factory ContentSummary.blank(int homileticId) {
    return ContentSummary(homileticId: homileticId);
  }
}
