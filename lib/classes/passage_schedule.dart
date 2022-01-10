class PassageSchedule {
  String reference;
  DateTime expires;

  PassageSchedule({required this.reference, required this.expires});

  factory PassageSchedule.fromJson(Map<String, dynamic> json) {
    return PassageSchedule(
        reference: json['reference'], expires: DateTime.parse(json['expires']));
  }

  Map<String, dynamic> toJson() {
    return {'reference': reference, 'expires': expires.toString()};
  }
}
