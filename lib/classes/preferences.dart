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
