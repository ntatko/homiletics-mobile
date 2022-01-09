class PassageSchedule {
  DateTime rollout;
  String reference;
  DateTime expires;

  PassageSchedule(
      {required this.rollout, required this.reference, required this.expires});

  factory PassageSchedule.fromJson(Map<String, dynamic> json) {
    return PassageSchedule(
        rollout: DateTime.parse(json['rollout']),
        reference: json['reference'],
        expires: DateTime.parse(json['expires']));
  }

  Map<String, dynamic> toJson() {
    return {
      'rollout': rollout.toString(),
      'reference': reference,
      'expires': expires.toString()
    };
  }
}
