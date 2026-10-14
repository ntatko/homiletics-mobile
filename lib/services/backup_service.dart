import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Whole-library backups: one .zip the user keeps wherever they like
/// (Google Drive, Files, AirDrop, email…). Nothing is uploaded by the app.
///
/// Format (see [kBackupFormatVersion]):
///
///   manifest.json   {"format": "homiletics-backup", "v": 1, "app_version",
///                    "created", "counts": {...}}
///   data.json       {"homiletics": [...], "lecture_notes": [...],
///                    "word_studies": [...]}
///   recordings/…    lecture audio, stored uncompressed (optional)
///
/// Records are written from the model classes' JSON (minus database ids),
/// not as a copy of the SQLite file, so a backup still restores after the
/// schema changes. Restoring only ever adds: a record that already exists
/// identically is skipped, and nothing is deleted or overwritten.
class BackupService {
  BackupService._();

  static const String formatName = 'homiletics-backup';
  static const String _manifestName = 'manifest.json';
  static const String _dataName = 'data.json';
  static const String _recordingsDir = 'recordings';

  /// Where lecture recordings live (and are restored to). Overridable for
  /// tests; defaults to the app documents directory, as in [LectureNote].
  static Future<String> Function() recordingsDirectory =
      () async => (await getApplicationDocumentsDirectory()).path;

  /// Total size of the recordings a backup would include, in bytes.
  static Future<int> recordingsSize() async {
    int total = 0;
    for (final File file in await _recordingFiles(await getLectureNotes())) {
      try {
        total += await file.length();
      } catch (_) {}
    }
    return total;
  }

  /// Writes a backup of everything into [directory] (the temporary
  /// directory by default) and returns the file. The archive is built on a
  /// background isolate so large recordings don't freeze the screen.
  static Future<File> create({
    required bool includeRecordings,
    required String appVersion,
    Directory? directory,
    DateTime? now,
  }) async {
    final DateTime created = now ?? DateTime.now();
    final List<LectureNote> notes = await getLectureNotes();
    final Map<String, dynamic> data = {
      'homiletics': [
        for (final Homiletic h in await getAllHomiletics())
          await _homileticJson(h),
      ],
      'lecture_notes': [for (final LectureNote n in notes) _lectureJson(n)],
      'word_studies': [
        for (final WordStudy w in await getAllWordStudies()) _wordStudyJson(w),
      ],
    };

    // Recording entries are only listed for files that are really there.
    final Map<String, String> recordings = {};
    if (includeRecordings) {
      for (final File file in await _recordingFiles(notes)) {
        recordings['$_recordingsDir/${p.basename(file.path)}'] = file.path;
      }
    }
    for (final Map<String, dynamic> note
        in (data['lecture_notes'] as List).cast<Map<String, dynamic>>()) {
      final String? name = note.remove('recording_path') as String?;
      final String entry = '$_recordingsDir/$name';
      note['recording'] = recordings.containsKey(entry) ? entry : null;
    }

    final Map<String, dynamic> manifest = {
      'format': formatName,
      'v': kBackupFormatVersion,
      'app_version': appVersion,
      'created': created.toUtc().toIso8601String(),
      'counts': {
        'homiletics': (data['homiletics'] as List).length,
        'lecture_notes': notes.length,
        'word_studies': (data['word_studies'] as List).length,
        'recordings': recordings.length,
      },
    };

    final Directory dir = directory ?? await getTemporaryDirectory();
    final String path = p.join(dir.path, backupFileName(created));
    final String manifestJson = jsonEncode(manifest);
    final String dataJson = jsonEncode(data);
    await Isolate.run(() async {
      final ZipFileEncoder zip = ZipFileEncoder()..create(path);
      zip.addArchiveFile(ArchiveFile.string(_manifestName, manifestJson));
      zip.addArchiveFile(ArchiveFile.string(_dataName, dataJson));
      final List<InputFileStream> streams = [];
      for (final MapEntry<String, String> r in recordings.entries) {
        // Audio is already compressed; storing it keeps memory flat.
        final InputFileStream stream = InputFileStream(r.value);
        streams.add(stream);
        zip.addArchiveFile(ArchiveFile.stream(r.key, stream)
          ..compression = CompressionType.none);
      }
      await zip.close();
      for (final InputFileStream stream in streams) {
        await stream.close();
      }
    });
    return File(path);
  }

  /// "Homiletics backup 2026-10-14.zip"
  static String backupFileName(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'Homiletics backup ${date.year}-${two(date.month)}-${two(date.day)}.zip';
  }

  /// Reads and checks a backup file without changing anything. Throws a
  /// [BackupException] if it isn't a backup this version can restore.
  static Future<BackupContents> read(String path) async {
    final ({String manifest, String data})? json = await Isolate.run(() {
      final InputFileStream input = InputFileStream(path);
      try {
        final Archive archive = ZipDecoder().decodeStream(input);
        final ArchiveFile? manifest = archive.findFile(_manifestName);
        final ArchiveFile? data = archive.findFile(_dataName);
        if (manifest == null || data == null) return null;
        return (
          manifest: utf8.decode(manifest.readBytes()!),
          data: utf8.decode(data.readBytes()!),
        );
      } finally {
        input.closeSync();
      }
    }).catchError((Object _) =>
        throw const BackupException(BackupProblem.notABackup));
    if (json == null) throw const BackupException(BackupProblem.notABackup);

    final Map<String, dynamic> manifest;
    final Map<String, dynamic> data;
    try {
      manifest = jsonDecode(json.manifest) as Map<String, dynamic>;
      if (manifest['format'] != formatName) {
        throw const BackupException(BackupProblem.notABackup);
      }
      final Object? version = manifest['v'];
      if (version is! int || version < 1) {
        throw const BackupException(BackupProblem.damaged);
      }
      if (version > kBackupFormatVersion) {
        throw const BackupException(BackupProblem.newerVersion);
      }
      data = jsonDecode(json.data) as Map<String, dynamic>;
      return BackupContents._(
        path: path,
        created: DateTime.tryParse(manifest['created'] as String? ?? ''),
        homiletics: _list(data['homiletics']),
        lectureNotes: _list(data['lecture_notes']),
        wordStudies: _list(data['word_studies']),
      );
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(BackupProblem.damaged);
    }
  }

  static List<Map<String, dynamic>> _list(Object? value) =>
      (value as List? ?? const []).cast<Map<String, dynamic>>();

  /// Adds everything in [backup] that isn't already in the library.
  static Future<RestoreResult> restore(BackupContents backup) async {
    final Set<String> existingHomiletics = {
      for (final Homiletic h in await getAllHomiletics())
        _fingerprint(await _homileticJson(h)),
    };
    final Set<String> existingNotes = {
      for (final LectureNote n in await getLectureNotes())
        _fingerprint(_lectureJson(n)),
    };
    final Set<String> existingWordStudies = {
      for (final WordStudy w in await getAllWordStudies())
        _fingerprint(_wordStudyJson(w)),
    };

    int added = 0, skipped = 0;

    for (final Map<String, dynamic> h in backup.homiletics) {
      if (!existingHomiletics.add(_fingerprint(h))) {
        skipped++;
        continue;
      }
      await _insertHomiletic(h);
      added++;
    }

    final Database lectures = await AppStorage.database('lectures');
    for (final Map<String, dynamic> n in backup.lectureNotes) {
      if (!existingNotes.add(_fingerprint(n))) {
        skipped++;
        continue;
      }
      final String? recording = await _restoreRecording(
          backup.path, n['recording'] as String?);
      await lectures.insert('lectures', {
        'note': _string(n['note']),
        'passage': _string(n['passage']),
        'time': _string(n['time']),
        'recording_path': recording,
        'transcript': n['transcript'] as String?,
        'formatted_transcript': n['formatted_transcript'] as String?,
      });
      added++;
    }

    final Database wordStudies = await AppStorage.database('word_studies');
    for (final Map<String, dynamic> w in backup.wordStudies) {
      if (!existingWordStudies.add(_fingerprint(w))) {
        skipped++;
        continue;
      }
      await wordStudies.insert('word_studies', {
        for (final String key in _wordStudyFields) key: _string(w[key]),
      });
      added++;
    }

    return RestoreResult(added: added, skipped: skipped);
  }

  /// Inserts a homiletic and its children with their original timestamp,
  /// in one transaction when all tables share a database.
  static Future<void> _insertHomiletic(Map<String, dynamic> h) async {
    Future<void> write(DatabaseExecutor homiletics,
        DatabaseExecutor Function(String table) child) async {
      final int id = await homiletics.insert('homiletics', {
        for (final String key in _homileticFields) key: _string(h[key]),
      });
      for (final Map<String, dynamic> s in _list(h['content_summaries'])) {
        await child('content_summaries').insert('content_summaries', {
          'summary': _string(s['summary']),
          'passage': _string(s['passage']),
          'homiletic_id': id,
        });
      }
      for (final Map<String, dynamic> d in _list(h['divisions'])) {
        await child('divisions').insert('divisions', {
          'title': _string(d['title']),
          'passage': _string(d['passage']),
          'homiletic_id': id,
        });
      }
      for (final Map<String, dynamic> a in _list(h['applications'])) {
        await child('applications').insert('applications', {
          'text': _string(a['text']),
          'homiletic_id': id,
        });
      }
    }

    final AppStorage storage = await AppStorage.instance;
    if (storage.isUnified) {
      final Database db = await storage.databaseFor('homiletics');
      await db.transaction((txn) => write(txn, (_) => txn));
    } else {
      final Map<String, Database> dbs = {
        for (final String table in const [
          'content_summaries',
          'divisions',
          'applications'
        ])
          table: await storage.databaseFor(table),
      };
      await write(await storage.databaseFor('homiletics'), (t) => dbs[t]!);
    }
  }

  /// Copies a recording out of the backup into the recordings directory,
  /// under a new name if one by that name is already there. Returns the
  /// file name to store, or null if the backup has no such recording.
  static Future<String?> _restoreRecording(
      String backupPath, String? entry) async {
    if (entry == null || entry.isEmpty) return null;
    final String dir = await recordingsDirectory();
    final String original = p.basename(entry);
    String name = original;
    for (int i = 1; File(p.join(dir, name)).existsSync(); i++) {
      name = '${p.basenameWithoutExtension(original)}-restored-$i'
          '${p.extension(original)}';
    }
    final String target = p.join(dir, name);
    final bool copied = await Isolate.run(() async {
      final InputFileStream input = InputFileStream(backupPath);
      try {
        final ArchiveFile? file =
            ZipDecoder().decodeStream(input).findFile(entry);
        if (file == null) return false;
        final OutputFileStream output = OutputFileStream(target);
        file.writeContent(output);
        await output.close();
        return true;
      } finally {
        input.closeSync();
      }
    });
    return copied ? name : null;
  }

  static const List<String> _homileticFields = [
    'passage',
    'subject_sentence',
    'aim',
    'fcf',
    'updated_at',
  ];

  static const List<String> _wordStudyFields = [
    'passage',
    'word',
    'definition',
    'other_usage',
    'contextual_meaning',
    'deeper_meaning',
    'application',
    'updated_at',
  ];

  static String _string(Object? value) => value as String? ?? '';

  static Future<Map<String, dynamic>> _homileticJson(Homiletic h) async {
    final Map<String, dynamic> json = h.toJson();
    return {
      for (final String key in _homileticFields) key: json[key] ?? '',
      'content_summaries': [
        for (final ContentSummary s in await getSummariesByHomileticId(h.id))
          {'passage': s.passage, 'summary': s.summary},
      ],
      'divisions': [
        for (final Division d in await getDivisionsByHomileticId(h.id))
          {'passage': d.passage, 'title': d.title},
      ],
      'applications': [
        for (final Application a in await getApplicationsByHomileticId(h.id))
          {'text': a.text},
      ],
    };
  }

  static Map<String, dynamic> _lectureJson(LectureNote n) {
    final Map<String, dynamic> json = n.toJson()..remove('id');
    return json;
  }

  static Map<String, dynamic> _wordStudyJson(WordStudy w) {
    final Map<String, dynamic> json = w.toJson();
    return {for (final String key in _wordStudyFields) key: json[key] ?? ''};
  }

  /// What makes two records "the same" for restore: every field the user
  /// wrote plus its timestamp. Recording file names differ between devices
  /// (and a backup may leave the audio out), so they don't count.
  static String _fingerprint(Map<String, dynamic> record) {
    final Map<String, dynamic> copy = Map.of(record)
      ..remove('recording')
      ..remove('recording_path');
    for (final String key in const ['transcript', 'formatted_transcript']) {
      if (copy.containsKey(key)) copy[key] = copy[key] ?? '';
    }
    final List<String> keys = copy.keys.toList()..sort();
    return jsonEncode([for (final String key in keys) [key, copy[key]]]);
  }

  static Future<List<File>> _recordingFiles(List<LectureNote> notes) async {
    final String dir = await recordingsDirectory();
    final List<File> files = [];
    for (final LectureNote note in notes) {
      final String? name = note.recordingPath;
      if (name == null || name.isEmpty) continue;
      final File file = File(p.join(dir, name));
      if (file.existsSync()) files.add(file);
    }
    return files;
  }
}

/// The newest backup format this app writes and can restore.
const int kBackupFormatVersion = 1;

/// A checked backup, ready to preview and restore.
class BackupContents {
  final String path;
  final DateTime? created;
  final List<Map<String, dynamic>> homiletics;
  final List<Map<String, dynamic>> lectureNotes;
  final List<Map<String, dynamic>> wordStudies;

  const BackupContents._({
    required this.path,
    required this.created,
    required this.homiletics,
    required this.lectureNotes,
    required this.wordStudies,
  });

  int get recordingCount =>
      lectureNotes.where((n) => n['recording'] != null).length;
}

class RestoreResult {
  final int added;
  final int skipped;

  const RestoreResult({required this.added, required this.skipped});
}

enum BackupProblem { notABackup, damaged, newerVersion }

class BackupException implements Exception {
  final BackupProblem problem;

  const BackupException(this.problem);

  @override
  String toString() => 'BackupException($problem)';
}
