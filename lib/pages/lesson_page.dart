import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/homiletic_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

class LessonPage extends StatelessWidget {
  /// Shown until the page's own (refreshable) query comes back.
  final List<Homiletic> homiletics;

  const LessonPage({Key? key, required this.homiletics}) : super(key: key);

  static Future<List<Homiletic>> _load() async =>
      (await getAllHomiletics()).reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Previous Homiletics")),
      body: StudyDataBuilder<List<Homiletic>>(
          load: _load,
          initialData: homiletics,
          builder: (context, snapshot) {
            final List<Homiletic> current = snapshot.data ?? homiletics;
            return ListView.builder(
                itemBuilder: ((context, index) {
                  Homiletic homiletic = current[index];
                  return HomileticListItem(homiletic: homiletic);
                }),
                itemCount: current.length);
          }),
    );
  }
}
