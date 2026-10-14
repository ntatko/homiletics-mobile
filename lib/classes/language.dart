import 'package:flutter/widgets.dart';

/// An app (interface) language. Bible translations are chosen separately;
/// see [Translation.languageCode] for how they're grouped and defaulted.
class Language {
  /// The language's own name for itself, shown in the picker.
  final String name;

  /// The locale Flutter's localizations are generated for.
  final Locale locale;

  const Language({required this.name, required this.locale});

  /// A stable string for storing the choice (e.g. "en", "zh_Hans").
  String get code => locale.scriptCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.scriptCode}';

  static const Language english =
      Language(name: 'English', locale: Locale('en'));
  static const Language spanish =
      Language(name: 'Español', locale: Locale('es'));
  static const Language chineseSimplified = Language(
      name: '简体中文',
      locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
  static const Language chineseTraditional = Language(
      name: '繁體中文',
      locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
  static const Language french =
      Language(name: 'Français', locale: Locale('fr'));
  static const Language portuguese =
      Language(name: 'Português', locale: Locale('pt'));
  static const Language swahili =
      Language(name: 'Kiswahili', locale: Locale('sw'));

  /// Every language the interface is translated into, in picker order.
  static const List<Language> all = [
    english,
    spanish,
    chineseSimplified,
    chineseTraditional,
    french,
    portuguese,
    swahili,
  ];

  static Language? fromCode(String? code) {
    if (code == null) return null;
    for (final Language language in all) {
      if (language.code == code) return language;
    }
    return null;
  }

  /// The supported language that best matches [locale] (e.g. the phone's),
  /// falling back to English. Chinese without a script picks Traditional
  /// for Taiwan / Hong Kong / Macau and Simplified otherwise.
  static Language match(Locale locale) {
    if (locale.languageCode == 'zh') {
      final String? script = locale.scriptCode;
      final bool traditional = script == 'Hant' ||
          (script == null &&
              const {'TW', 'HK', 'MO'}.contains(locale.countryCode));
      return traditional ? chineseTraditional : chineseSimplified;
    }
    for (final Language language in all) {
      if (language.locale.languageCode == locale.languageCode) return language;
    }
    return english;
  }
}
