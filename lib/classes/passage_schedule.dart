import 'package:homiletics/classes/language.dart';

/// One week of the suggested-passages feed (data/suggested-passages.json).
class PassageSchedule {
  /// The English passage reference. Always used for Bible Gateway lookups
  /// and for matching saved studies; show [displayPassage] instead.
  final String passage;

  /// When this week's lesson starts.
  final DateTime rollout;

  /// The English lesson title, e.g. "BSF Romans #4".
  final String lesson;

  /// The study's web address; also identifies the study.
  final String study;

  /// Translated lesson titles, by [Language.code].
  final Map<String, String> lessonI18n;

  /// Translated passage for display, by [Language.code].
  final Map<String, String> passageI18n;

  /// The study's display name, by [Language.code] (including "en").
  final Map<String, String> studyNames;

  const PassageSchedule({
    required this.passage,
    required this.rollout,
    required this.lesson,
    required this.study,
    this.lessonI18n = const {},
    this.passageI18n = const {},
    this.studyNames = const {},
  });

  /// [studies] is the feed's top-level "studies" map (study url → names).
  factory PassageSchedule.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic>? studies}) {
    return PassageSchedule(
      passage: json['passage'] as String,
      rollout: DateTime.parse(json['rollout'] as String),
      lesson: json['lesson'] as String? ?? '',
      study: json['study'] as String? ?? '',
      lessonI18n: _stringMap(json['lesson_i18n']),
      passageI18n: _stringMap(json['passage_i18n']),
      studyNames: _stringMap(studies?[json['study']]),
    );
  }

  static Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final MapEntry entry in value.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: entry.value as String,
    };
  }

  /// The value for [language] in [values]: its exact code (e.g.
  /// "zh_Hant"), then its bare language ("zh"), else null.
  static String? _pick(Map<String, String> values, Language language) {
    final String? exact = values[language.code];
    if (exact != null && exact.trim().isNotEmpty) return exact;
    final String? bare = values[language.locale.languageCode];
    if (bare != null && bare.trim().isNotEmpty) return bare;
    return null;
  }

  String displayPassage(Language language) =>
      _pick(passageI18n, language) ?? passage;

  String displayLesson(Language language) =>
      _pick(lessonI18n, language) ?? lesson;

  /// The study's name in [language], falling back to English, or null if
  /// the feed has no names for it.
  String? studyName(Language language) =>
      _pick(studyNames, language) ?? studyNames['en'];

  /// Returns a map representation of the passage schedule.
  Map<String, dynamic> toJson() {
    return {
      'passage': passage,
      'rollout': rollout.toString(),
      'lesson': lesson,
      'study': study,
      if (lessonI18n.isNotEmpty) 'lesson_i18n': lessonI18n,
      if (passageI18n.isNotEmpty) 'passage_i18n': passageI18n,
    };
  }
}
