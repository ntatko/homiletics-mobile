import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/storage/application_storage.dart';

class Application with SerializedSave {
  String text;
  int homileticsId;
  int? id;

  /// Passage from the linked homiletic (UI only; set by [getAllApplicationsWithPassages]).
  String? homileticPassage;

  Application({this.text = '', required this.homileticsId, this.id});

  factory Application.fromJson(Map<String, dynamic> json) {
    final Application application = Application(
        homileticsId: json['homiletic_id'] as int? ?? -1,
        text: json['text'] as String? ?? '',
        id: json['id'] as int?);
    application.rememberSaved(application._contentJson());
    return application;
  }

  Map<String, dynamic> toJson() =>
      {"text": text, "homiletic_id": homileticsId, "id": id};

  Map<String, dynamic> _contentJson() => toJson()..remove('id');

  factory Application.blank(int homileticsId) {
    return Application(homileticsId: homileticsId);
  }

  /// Saves this [Application]. Concurrent calls run one after another, and
  /// calls after [delete] do nothing.
  Future<void> update() {
    return serializeSave(() async {
      if (kIsWeb) return;
      final Map<String, dynamic> state = _contentJson();
      if (id == null) {
        id = await insertApplication(this);
      } else if (!matchesSaved(state)) {
        await updateApplication(this);
      }
      rememberSaved(state);
    });
  }

  Future<void> updateText(String updatedText) async {
    text = updatedText;
    await update();
  }

  /// Deletes this [Application] from the database. Waits for any save in
  /// flight first, and makes later saves no-ops.
  Future<void> delete() {
    markDeleted();
    return serialize(() async {
      if (id == null) return;
      try {
        await deleteApplication(this);
      } catch (_) {
        unmarkDeleted();
        rethrow;
      }
    });
  }
}
