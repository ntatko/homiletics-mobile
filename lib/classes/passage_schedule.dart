/// This is the response from the API, which determines the current lesson passage reference.
class PassageSchedule {
  /// The reference to the current lesson passage.
  String reference;

  /// The date the passage expires.
  DateTime expires;

  PassageSchedule({required this.reference, required this.expires});

  /// Creates a new [PassageSchedule] from a JSON map.
  factory PassageSchedule.fromJson(Map<String, dynamic> json) {
    return PassageSchedule(
        reference: json['reference'], expires: DateTime.parse(json['expires']));
  }

  /// Returns a map representation of the passage schedule.
  Map<String, dynamic> toJson() {
    return {'reference': reference, 'expires': expires.toString()};
  }
}
