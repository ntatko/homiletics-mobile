// ignore_for_file: file_names

import 'package:homiletics/storage/division_storage.dart';

class Division {
  String title;
  String passage;
  int homileticId;
  int order;
  int? id;

  Division(this.homileticId,
      {this.title = '', this.order = 0, this.passage = '', this.id});

  Map<String, dynamic> toJson() => {
        "title": title,
        "passage": passage,
        "homiletic_id": homileticId,
        "order": order,
        "id": id
      };

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(json['homiletic_id'],
        title: json['title'],
        passage: json['passage'],
        id: json['id'],
        order: json['order']);
  }

  factory Division.blank(int homileticId) {
    return Division(homileticId);
  }

  Future<void> update() async {
    if (id == null) {
      id = await insertDivision(this);
    } else {
      await updateDivision(this);
    }
  }

  Future<void> updatePassage(String text) async {
    passage = text;
    await update();
  }

  Future<void> updateText(String text) async {
    title = text;
    await update();
  }

  Future<void> delete() async {
    deleteDivision(this);
  }
}
