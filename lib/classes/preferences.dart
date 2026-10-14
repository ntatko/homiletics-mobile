import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/translation.dart';

class Preferences {
  Preferences();

  static const String _boxKey = 'user';
  static const String _preferredVersionKey = 'preferredVersion';
  static const String _hasSeenTranscriptionPromptKey =
      'hasSeenTranscriptionPrompt';
  static const String _hasSeenFormattingPromptKey = 'hasSeenFormattingPrompt';
  static const String _appLanguageKey = 'appLanguage';
  static const String _hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const String _removedRecordingsKey = 'removedRecordings';
  static const String _autoRemoveRecordingsKey = 'autoRemoveRecordings';
  static const String _recordingRemovalAgeDaysKey = 'recordingRemovalAgeDays';
  static const String _lastRecordingCleanupKey = 'lastRecordingCleanup';
  static const String _lastBackupAtKey = 'lastBackupAt';
  static const String _lastUpdateCheckKey = 'lastUpdateCheck';
  static const String _skippedUpdateVersionKey = 'skippedUpdateVersion';

  /// The interface language the user picked, or null to follow the phone.
  /// MaterialApp listens to this so a change applies immediately.
  static final ValueNotifier<Language?> appLanguageNotifier =
      ValueNotifier<Language?>(null);

  static Future<void> init() async {
    await Hive.openBox(_boxKey);
    appLanguageNotifier.value =
        Language.fromCode(Hive.box(_boxKey).get(_appLanguageKey) as String?);
  }

  /// The user's chosen interface language, or null to follow the phone.
  static Language? get appLanguage => appLanguageNotifier.value;

  static set appLanguage(Language? language) {
    Hive.box(_boxKey).put(_appLanguageKey, language?.code);
    appLanguageNotifier.value = language;
  }

  /// The language the interface is actually shown in.
  static Language get effectiveLanguage =>
      appLanguage ??
      Language.match(WidgetsBinding.instance.platformDispatcher.locale);

  /// The code of the Bible translation in use (see [translation]).
  static String get preferredVersion => translation.code;

  /// The translation the user chose, or — if they never chose one (or the
  /// stored code no longer exists) — the default for the app language.
  static Translation get translation => Translation.resolve(
      Hive.box(_boxKey).get(_preferredVersionKey) as String?,
      effectiveLanguage);

  static set preferredVersion(String version) =>
      Hive.box(_boxKey).put(_preferredVersionKey, version);

  static bool get hasSeenTranscriptionPrompt =>
      Hive.box(_boxKey).get(_hasSeenTranscriptionPromptKey) ?? false;

  static set hasSeenTranscriptionPrompt(bool seen) =>
      Hive.box(_boxKey).put(_hasSeenTranscriptionPromptKey, seen);

  static bool get hasSeenFormattingPrompt =>
      Hive.box(_boxKey).get(_hasSeenFormattingPromptKey) ?? false;

  static set hasSeenFormattingPrompt(bool seen) =>
      Hive.box(_boxKey).put(_hasSeenFormattingPromptKey, seen);

  /// Whether the first-run guide ("How homiletics works") has been shown
  /// or skipped, so Home doesn't open it again.
  static bool get hasSeenOnboarding =>
      Hive.box(_boxKey).get(_hasSeenOnboardingKey) ?? false;

  static set hasSeenOnboarding(bool seen) =>
      Hive.box(_boxKey).put(_hasSeenOnboardingKey, seen);

  /// When "Free up space" removed lecture note [noteId]'s recording, or null
  /// if it didn't. The note keeps its notes and transcripts; this only lets
  /// the editor say where the audio went.
  static DateTime? recordingRemovedAt(int noteId) {
    // Read while building the editor; never throw from there.
    if (!Hive.isBoxOpen(_boxKey)) return null;
    final Object? removed = Hive.box(_boxKey).get(_removedRecordingsKey);
    if (removed is! Map) return null;
    return DateTime.tryParse(removed['$noteId'] as String? ?? '');
  }

  static Future<void> markRecordingRemoved(int noteId, DateTime at) {
    final Object? stored = Hive.box(_boxKey).get(_removedRecordingsKey);
    return Hive.box(_boxKey).put(_removedRecordingsKey, {
      if (stored is Map) ...stored,
      '$noteId': at.toIso8601String(),
    });
  }

  /// Forgets the removal once the note has a recording again.
  static Future<void> clearRecordingRemoved(int noteId) async {
    final Object? stored = Hive.box(_boxKey).get(_removedRecordingsKey);
    if (stored is! Map || !stored.containsKey('$noteId')) return;
    await Hive.box(_boxKey).put(_removedRecordingsKey,
        Map<dynamic, dynamic>.of(stored)..remove('$noteId'));
  }

  /// Whether old recordings are removed on launch (at most once a day).
  static bool get autoRemoveRecordings =>
      Hive.box(_boxKey).get(_autoRemoveRecordingsKey) ?? false;

  static set autoRemoveRecordings(bool enabled) =>
      Hive.box(_boxKey).put(_autoRemoveRecordingsKey, enabled);

  /// The age picked under "Remove recordings older than", in days.
  static int get recordingRemovalAgeDays =>
      Hive.box(_boxKey).get(_recordingRemovalAgeDaysKey) ?? 91;

  static set recordingRemovalAgeDays(int days) =>
      Hive.box(_boxKey).put(_recordingRemovalAgeDaysKey, days);

  /// When the automatic removal last ran.
  static DateTime? get lastRecordingCleanup => DateTime.tryParse(
      Hive.box(_boxKey).get(_lastRecordingCleanupKey) as String? ?? '');

  static set lastRecordingCleanup(DateTime? at) =>
      Hive.box(_boxKey).put(_lastRecordingCleanupKey, at?.toIso8601String());

  /// When the user last made a backup (Settings → Backup & restore), or
  /// null if never.
  static DateTime? get lastBackupAt =>
      DateTime.tryParse(Hive.box(_boxKey).get(_lastBackupAtKey) as String? ?? '');

  static set lastBackupAt(DateTime? time) =>
      Hive.box(_boxKey).put(_lastBackupAtKey, time?.toIso8601String());

  /// When the Windows update check last reached GitHub (see UpdateService).
  static DateTime? get lastUpdateCheck {
    final Object? ms = Hive.box(_boxKey).get(_lastUpdateCheckKey);
    return ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static set lastUpdateCheck(DateTime? time) =>
      Hive.box(_boxKey).put(_lastUpdateCheckKey, time?.millisecondsSinceEpoch);

  /// A version the user chose to skip, so the launch check doesn't offer
  /// it again ("3.1.0").
  static String? get skippedUpdateVersion =>
      Hive.box(_boxKey).get(_skippedUpdateVersionKey) as String?;

  static set skippedUpdateVersion(String? version) =>
      Hive.box(_boxKey).put(_skippedUpdateVersionKey, version);
}
