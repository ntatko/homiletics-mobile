/// This is the response from the API, which determines the current lesson passage reference.
class PassageSchedule {
  /// The reference to the current lesson passage.
  final String passage;

  /// The date the passage expires.
  final DateTime rollout;

  /// The lesson number the passage is for.
  final String lesson;

  /// a link to the study for the passage.
  final String study;

  const PassageSchedule({
    required this.passage,
    required this.rollout,
    required this.lesson,
    required this.study,
  });

  /// Creates a new [PassageSchedule] from a JSON map.

  /// Creates a new [PassageSchedule] from a JSON map.
  factory PassageSchedule.fromJson(Map<String, dynamic> json) {
    return PassageSchedule(
      passage: json['passage'],
      rollout: DateTime.parse(json['rollout']),
      lesson: json['lesson'],
      study: json['study'],
    );
  }

  /// Returns a map representation of the passage schedule.
  Map<String, dynamic> toJson() {
    return {
      'passage': passage,
      'rollout': rollout.toString(),
      'lesson': lesson,
      'study': study,
    };
  }
}
