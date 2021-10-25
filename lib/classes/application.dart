import 'package:homiletics/storage/application_storage.dart';

class Application {
  String text;
  int homileticsId;
  int? id;

  Application({this.text = '', required this.homileticsId, this.id});

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
        homileticsId: json['homiletic_id'], text: json['text'], id: json['id']);
  }

  Map<String, dynamic> toJson() =>
      {"text": text, "homiletic_id": homileticsId, "id": id};

  factory Application.blank(int homileticsId) {
    return Application(homileticsId: homileticsId);
  }

  Future<void> update() async {
    if (id == null) {
      id = await insertApplication(this);
    } else {
      await updateApplication(this);
    }
  }

  Future<void> updateText(String updatedText) async {
    text = updatedText;
    await update();
  }

  Future<void> delete() async {
    deleteApplication(this);
  }
}
