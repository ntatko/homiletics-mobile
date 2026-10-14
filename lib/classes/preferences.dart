import 'package:hive/hive.dart';
import 'package:homiletics/classes/translation.dart';

class Preferences {
  Preferences();

  static const String _boxKey = 'user';
  static const String _preferredVersionKey = 'preferredVersion';
  static const String _hasSeenTranscriptionPromptKey =
      'hasSeenTranscriptionPrompt';
  static const String _hasSeenFormattingPromptKey = 'hasSeenFormattingPrompt';

  static Future<void> init() async {
    await Hive.openBox(_boxKey);
  }

  static String get preferredVersion =>
      Hive.box(_boxKey).get(_preferredVersionKey) ?? Translation.web.code;

  static Translation get translation {
    return Translation.all.firstWhere(
        (translation) => translation.code == preferredVersion,
        orElse: () => Translation.web);
  }

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
}
