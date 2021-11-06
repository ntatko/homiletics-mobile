class PassageSchedule {
  DateTime rollout;
  String reference;

  PassageSchedule({required this.rollout, required this.reference});

  factory PassageSchedule.fromJson(Map<String, dynamic> json) {
    return PassageSchedule(
        rollout: DateTime.parse(json['rollout']), reference: json['reference']);
  }

  Map<String, dynamic> toJson() {
    return {'rollout': rollout.toString(), 'reference': reference};
  }
}
