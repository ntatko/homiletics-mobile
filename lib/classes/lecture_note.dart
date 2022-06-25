import 'package:flutter/foundation.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';

class LectureNote {
  int id;
  String note;
  String passage;
  DateTime? time;

  LectureNote({this.id = -1, this.note = '', this.passage = '', this.time});

  factory LectureNote.fromJson(Map<String, dynamic> json) {
    return LectureNote(
        id: json['id'],
        note: json['note'],
        passage: json['passage'],
        time: DateTime.parse(json['time']));
  }

  toJson() {
    return {
      "id": id,
      "passage": passage,
      "note": note,
      "time": time?.toIso8601String() ?? ''
    };
  }

  Future<void> update() async {
    if (!kIsWeb) {
      if (id == -1) {
        id = await insertLectureNote(this);
      } else {
        await updateLectureNote(this);
      }
    }
  }

  Future<void> updateNote(String? updateNote, String? updatePassage) async {
    if (updateNote != null && updateNote != '') {
      note = updateNote;
    }
    if (updatePassage != null && updatePassage != '') {
      passage = updatePassage;
    }
    await update();
  }

  Future<LectureNote> delete() async {
    await deleteLectureNote(this);
    id = -1;
    return this;
  }
}
