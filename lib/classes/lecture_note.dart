import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/serialized_save.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LectureNote with SerializedSave {
  /// The id of the lecture note. -1 means it has never been saved.
  int id;

  /// The note of the lecture note.
  String note;

  /// The passage of the lecture note.
  String passage;

  /// The time the lecture note was updated.
  DateTime? time;

  /// The file name (not a full path) of the lecture recording, inside the
  /// app documents directory. Use [recordingFilePath] to get the full path;
  /// the documents directory can move between app updates on iOS, so a
  /// stored absolute path would go stale.
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
    final LectureNote lectureNote = LectureNote(
        id: json['id'] as int? ?? -1,
        note: json['note'] as String? ?? '',
        passage: json['passage'] as String? ?? '',
        time: DateTime.tryParse(json['time'] as String? ?? ''),
        recordingPath: _normalizeRecordingPath(json['recording_path'] as String?),
        transcript: json['transcript'] as String?,
        formattedTranscript: json['formatted_transcript'] as String?);
    // Remember the raw stored value so an old absolute path gets rewritten as
    // a file name on the next save.
    lectureNote.rememberSaved(lectureNote._contentJson()
      ..['recording_path'] = json['recording_path'] as String?);
    return lectureNote;
  }

  /// Older versions stored an absolute path; keep only the file name.
  static String? _normalizeRecordingPath(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    return stored.contains('/') ? p.basename(stored) : stored;
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

  /// The fields a save would actually change (no id or timestamp).
  Map<String, dynamic> _contentJson() => toJson()
    ..remove('id')
    ..remove('time');

  /// Full path to the recording file, or null if there is no recording.
  Future<String?> recordingFilePath() async {
    final String? fileName = recordingPath;
    if (fileName == null || fileName.isEmpty) return null;
    return '${(await getApplicationDocumentsDirectory()).path}/$fileName';
  }

  /// Updates the note in the database with whatever is in this object.
  /// Concurrent calls run one after another, calls that change nothing skip
  /// the write (so [time] isn't bumped), and calls after [delete] do nothing.
  Future<void> update() {
    return serializeSave(() async {
      if (kIsWeb) return;
      final Map<String, dynamic> state = _contentJson();
      if (id == -1) {
        id = await insertLectureNote(this);
      } else if (!matchesSaved(state)) {
        await updateLectureNote(this);
      }
      rememberSaved(state);
    });
  }

  /// Updates the note in the database with the parameters of this function.
  /// A null parameter leaves that field unchanged; '' clears it.
  Future<void> updateNote(String? updateNote, String? updatePassage) async {
    if (updateNote != null) {
      note = updateNote;
    }
    if (updatePassage != null) {
      passage = updatePassage;
    }
    await update();
  }

  /// Points this note at a new recording, given its file name inside the app
  /// documents directory (a full path is accepted and reduced to its file
  /// name). If this is a different recording, the previous file is deleted
  /// from disk and the transcripts are cleared, since they belonged to it.
  Future<void> updateRecordingPath(String fileName) async {
    if (isDeleted) return;
    final String newName = p.basename(fileName);
    if (newName == recordingPath) {
      await update();
      return;
    }
    final String? oldFilePath = await recordingFilePath();

    recordingPath = newName;
    transcript = null;
    formattedTranscript = null;
    await update();

    // Only drop the old file once the note no longer points at it.
    if (oldFilePath != null) {
      await _deleteFile(oldFilePath);
    }
  }

  /// Updates the transcript in the database with the parameter of this
  /// function. Null leaves it unchanged; '' clears it.
  Future<void> updateTranscript(String? text) async {
    if (text != null) {
      transcript = text;
    }
    await update();
  }

  /// Updates the formatted transcript in the database with the parameter of
  /// this function. Null leaves it unchanged; '' clears it.
  Future<void> updateFormattedTranscript(String? text) async {
    if (text != null) {
      formattedTranscript = text;
    }
    await update();
  }

  /// Deletes the note in the database, along with its recording file. Waits
  /// for any save in flight first, and makes later saves no-ops so the note
  /// can't be re-inserted. [id] is left as-is.
  Future<LectureNote> delete() async {
    markDeleted();
    await serialize(() async {
      if (id != -1) {
        try {
          await deleteLectureNote(this);
        } catch (_) {
          unmarkDeleted();
          rethrow;
        }
      }
      final String? filePath = await recordingFilePath();
      if (filePath != null) {
        await _deleteFile(filePath);
      }
    });
    return this;
  }

  /// Deletes [path] if it exists; a missing or undeletable file is ignored.
  static Future<void> _deleteFile(String path) async {
    try {
      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Leaving a stray file behind is harmless.
    }
  }
}
