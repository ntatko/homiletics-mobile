import 'package:hive/hive.dart';
import 'package:homiletics/classes/translation.dart';

class Preferences {
  Preferences();

  static const String _boxKey = 'user';
  static const String _preferredVersionKey = 'preferredVersion';
  static const String _preferredLanguageKey = 'preferredLanguage';

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

  static String get preferredLanguage =>
      Hive.box(_boxKey).get(_preferredLanguageKey) ?? 'en';

  static set preferredVersion(String version) =>
      Hive.box(_boxKey).put(_preferredVersionKey, version);

  static set preferredLanguage(String language) =>
      Hive.box(_boxKey).put(_preferredLanguageKey, language);
}
