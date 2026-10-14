import 'dart:io';

import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/services/whisper_model_service.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The ages offered under "Remove recordings older than".
enum RecordingAge {
  oneMonth(30),
  threeMonths(91),
  sixMonths(182),
  oneYear(365);

  const RecordingAge(this.days);

  final int days;

  /// The age for a stored [days] value; three months if it isn't one.
  static RecordingAge fromDays(int days) => RecordingAge.values
      .firstWhere((age) => age.days == days, orElse: () => threeMonths);
}

/// A lecture note's recording that's on disk.
class StoredRecording {
  final LectureNote note;
  final String path;
  final int bytes;

  /// When it was recorded (from its file name), else when it was last written.
  final DateTime recordedAt;

  const StoredRecording({
    required this.note,
    required this.path,
    required this.bytes,
    required this.recordedAt,
  });

  bool get isTranscribed => (note.transcript ?? '').trim().isNotEmpty;
}

/// The recordings on disk, plus recording files no note points at.
class RecordingUsage {
  final List<StoredRecording> recordings;

  /// Recording files that no note references (left by a crash, or by an
  /// older version). Only files untouched for a day count, so a recording
  /// that's being saved right now is never one.
  final List<File> orphans;
  final int orphanBytes;

  const RecordingUsage({
    required this.recordings,
    this.orphans = const [],
    this.orphanBytes = 0,
  });

  int get recordingBytes =>
      recordings.fold(0, (int sum, StoredRecording r) => sum + r.bytes);

  int get totalBytes => recordingBytes + orphanBytes;

  /// Recordings made before [age] ago, oldest first.
  List<StoredRecording> olderThan(RecordingAge age, DateTime now) {
    final DateTime cutoff = now.subtract(Duration(days: age.days));
    return recordings.where((r) => r.recordedAt.isBefore(cutoff)).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }
}

/// What a removal freed.
class RecordingRemoval {
  final int removed;
  final int bytes;
  final int failed;

  const RecordingRemoval(
      {required this.removed, required this.bytes, this.failed = 0});
}

/// Finds and removes lecture recordings to free up space. Only the audio is
/// deleted: notes, transcripts, formatted transcripts and time marks stay.
class RecordingStorageService {
  RecordingStorageService._();

  /// Recordings are saved as "lecture_<note id>_<milliseconds>.m4a" (".wav"
  /// on Windows) in the documents directory.
  static final RegExp _recordingFileName =
      RegExp(r'^lecture_(\d+)_(\d+)\.(m4a|wav)$');

  /// Lecture notes open in an editor. Their recordings are left alone: the
  /// editor's copy of the note would save the old file name back.
  static final Set<int> openNoteIds = {};

  /// How old an unreferenced recording file must be before it's an orphan.
  static const Duration _orphanGrace = Duration(days: 1);

  /// When a recording called [fileName] was made, if its name says.
  static DateTime? recordedAtFromFileName(String fileName) {
    final RegExpMatch? match = _recordingFileName.firstMatch(fileName);
    if (match == null) return null;
    final int? millis = int.tryParse(match.group(2)!);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Whether [note]'s recording was removed by "Free up space" (rather than
  /// never made).
  static bool wasRemoved(LectureNote note) =>
      note.id != -1 &&
      note.recordingPath == null &&
      Preferences.recordingRemovedAt(note.id) != null;

  /// Every recording on disk. [notes] and [documents] default to the saved
  /// lecture notes and the app documents directory.
  static Future<RecordingUsage> scan({
    List<LectureNote>? notes,
    Directory? documents,
    DateTime? now,
  }) async {
    final List<LectureNote> all = notes ?? await getLectureNotes();
    final Directory dir = documents ?? await getApplicationDocumentsDirectory();
    final DateTime time = now ?? DateTime.now();

    final List<StoredRecording> recordings = [];
    final Set<String> referenced = {};
    for (final LectureNote note in all) {
      final String? fileName = note.recordingPath;
      if (fileName == null) continue;
      referenced.add(fileName);
      final File file = File(p.join(dir.path, fileName));
      try {
        final FileStat stat = await file.stat();
        if (stat.type != FileSystemEntityType.file) continue;
        recordings.add(StoredRecording(
          note: note,
          path: file.path,
          bytes: stat.size,
          recordedAt: recordedAtFromFileName(fileName) ?? stat.modified,
        ));
      } catch (_) {
        // Unreadable: leave it alone.
      }
    }

    final List<File> orphans = [];
    int orphanBytes = 0;
    try {
      await for (final FileSystemEntity entity in dir.list()) {
        if (entity is! File) continue;
        final String name = p.basename(entity.path);
        if (!_recordingFileName.hasMatch(name) || referenced.contains(name)) {
          continue;
        }
        final FileStat stat = await entity.stat();
        if (time.difference(stat.modified) < _orphanGrace) continue;
        orphans.add(entity);
        orphanBytes += stat.size;
      }
    } catch (error) {
      sendError(error, "RecordingStorageService.scan orphans");
    }

    return RecordingUsage(
        recordings: recordings, orphans: orphans, orphanBytes: orphanBytes);
  }

  /// Deletes [recordings]' audio (keeping their notes) and [orphans].
  static Future<RecordingRemoval> remove(
    List<StoredRecording> recordings, {
    List<File> orphans = const [],
    DateTime? now,
  }) async {
    final DateTime time = now ?? DateTime.now();
    int removed = 0;
    int bytes = 0;
    int failed = 0;
    for (final StoredRecording recording in recordings) {
      if (openNoteIds.contains(recording.note.id)) continue;
      try {
        await recording.note.removeRecordingFile();
        await Preferences.markRecordingRemoved(recording.note.id, time);
        removed++;
        bytes += recording.bytes;
      } catch (error) {
        sendError(error, "RecordingStorageService.remove");
        failed++;
      }
    }
    for (final File orphan in orphans) {
      try {
        final int size = await orphan.length();
        await orphan.delete();
        bytes += size;
      } catch (_) {
        // A leftover file only costs space.
      }
    }
    await WhisperModelService.cleanUpConversionFiles();
    return RecordingRemoval(removed: removed, bytes: bytes, failed: failed);
  }

  /// With "Remove automatically" on, removes transcribed recordings older
  /// than the chosen age, at most once a day. Recordings that were never
  /// transcribed are kept: removing them would lose the lecture entirely.
  static Future<RecordingRemoval?> runAutomaticCleanupIfDue(
      {DateTime? now}) async {
    try {
      if (!Preferences.autoRemoveRecordings) return null;
      final DateTime time = now ?? DateTime.now();
      final DateTime? last = Preferences.lastRecordingCleanup;
      if (last != null && time.difference(last) < const Duration(days: 1)) {
        return null;
      }
      Preferences.lastRecordingCleanup = time;
      final RecordingUsage usage = await scan(now: time);
      final RecordingAge age =
          RecordingAge.fromDays(Preferences.recordingRemovalAgeDays);
      return await remove(
        usage.olderThan(age, time).where((r) => r.isTranscribed).toList(),
        orphans: usage.orphans,
        now: time,
      );
    } catch (error) {
      sendError(error, "RecordingStorageService.runAutomaticCleanupIfDue");
      return null;
    }
  }
}

/// "480 MB" or "1.2 GB" for a byte count.
String formatStorageSize(int bytes) {
  const int mib = 1024 * 1024;
  if (bytes >= 1024 * mib) {
    return '${(bytes / (1024 * mib)).toStringAsFixed(1)} GB';
  }
  final double mb = bytes / mib;
  if (mb >= 10) return '${mb.round()} MB';
  return '${mb < 0.1 && bytes > 0 ? '0.1' : mb.toStringAsFixed(1)} MB';
}
