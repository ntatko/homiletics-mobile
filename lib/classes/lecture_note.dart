import 'package:flutter/foundation.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';

class LectureNote {
  /// The id of the lecture note.
  int id;

  /// The note of the lecture note.
  String note;

  /// The passage of the lecture note.
  String passage;

  /// The time the lecture note was updated.
  DateTime? time;

  /// The path to the recording of the lecture.
  String? recordingPath;

  LectureNote(
      {this.id = -1,
      this.note = '',
      this.passage = '',
      this.time,
      this.recordingPath});

  /// Creates a new [LectureNote] from a JSON map.
  factory LectureNote.fromJson(Map<String, dynamic> json) {
    return LectureNote(
        id: json['id'],
        note: json['note'],
        passage: json['passage'],
        time: DateTime.parse(json['time']),
        recordingPath: json['recording_path']);
  }

  /// Returns a map representation of the lecture note.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "passage": passage,
      "note": note,
      "time": time?.toIso8601String() ?? '',
      "recording_path": recordingPath
    };
  }

  /// Updates the note in the database with whatever is in this object.
  Future<void> update() async {
    if (!kIsWeb) {
      if (id == -1) {
        id = await insertLectureNote(this);
      } else {
        await updateLectureNote(this);
      }
    }
  }

  /// Updates the note in the database with the parameters of this function.
  Future<void> updateNote(String? updateNote, String? updatePassage) async {
    if (updateNote != null && updateNote != '') {
      note = updateNote;
    }
    if (updatePassage != null && updatePassage != '') {
      passage = updatePassage;
    }
    await update();
  }

  /// Updates the recording path in the database with the parameter of this function.
  Future<void> updateRecordingPath(String? updateRecordingPath) async {
    if (updateRecordingPath != null && updateRecordingPath != '') {
      recordingPath = updateRecordingPath;
    }
    await update();
  }

  /// Deletes the note in the database.
  Future<LectureNote> delete() async {
    await deleteLectureNote(this);
    id = -1;
    return this;
  }
}
