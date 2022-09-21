class Language {
  /// The name of the language in the native language.
  final String name;

  /// The ISO 639-3 code for the language.
  final String code;

  const Language({required this.name, required this.code});

  /// The English language.
  static const Language english = Language(name: 'English', code: 'eng');

  /// Returns a list of all languages available in the app.
  static List<Language> get all => [
        english,
      ];
}
