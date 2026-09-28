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

  /// The transcribed text of the recording, if any.
  String? transcript;

  /// [transcript] cleaned up into readable paragraphs by the on-device
  /// language model. The raw [transcript] is kept alongside it since a small
  /// model can occasionally drop or garble a sentence.
  String? formattedTranscript;

  LectureNote(
      {this.id = -1,
      this.note = '',
      this.passage = '',
      this.time,
      this.recordingPath,
      this.transcript,
      this.formattedTranscript});

  /// Creates a new [LectureNote] from a JSON map.
  factory LectureNote.fromJson(Map<String, dynamic> json) {
    return LectureNote(
        id: json['id'],
        note: json['note'],
        passage: json['passage'],
        time: DateTime.parse(json['time']),
        recordingPath: json['recording_path'],
        transcript: json['transcript'],
        formattedTranscript: json['formatted_transcript']);
  }

  /// Returns a map representation of the lecture note.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "passage": passage,
      "note": note,
      "time": time?.toIso8601String() ?? '',
      "recording_path": recordingPath,
      "transcript": transcript,
      "formatted_transcript": formattedTranscript
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

  /// Updates the transcript in the database with the parameter of this function.
  Future<void> updateTranscript(String? updateTranscript) async {
    if (updateTranscript != null && updateTranscript != '') {
      transcript = updateTranscript;
    }
    await update();
  }

  /// Updates the formatted transcript in the database with the parameter of
  /// this function.
  Future<void> updateFormattedTranscript(String? updateFormatted) async {
    if (updateFormatted != null && updateFormatted != '') {
      formattedTranscript = updateFormatted;
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
