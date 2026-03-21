import 'package:flutter/foundation.dart';
import 'package:homiletics/storage/application_storage.dart';

class Application {
  String text;
  int homileticsId;
  String? uuid;
  int? id;
  Future<void> _pendingWrite = Future<void>.value();

  Application({this.text = '', required this.homileticsId, this.id, this.uuid});

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
        homileticsId: json['homiletic_id'],
        text: json['text'] ?? '',
        id: json['id'],
        uuid: json['uuid']?.toString());
  }

  Map<String, dynamic> toJson() =>
      {"text": text, "homiletic_id": homileticsId, "id": id, "uuid": uuid};

  factory Application.blank(int homileticsId) {
    return Application(homileticsId: homileticsId);
  }

  Future<void> update() async {
    if (kIsWeb) return;
    _pendingWrite = _pendingWrite.catchError((_) {}).then((_) async {
      if (id == null) {
        id = await insertApplication(this);
      } else {
        await updateApplication(this);
      }
    });
    await _pendingWrite;
  }

  Future<void> updateText(String updatedText) async {
    text = updatedText;
    await update();
  }

  Future<void> delete() async {
    deleteApplication(this);
  }
}
