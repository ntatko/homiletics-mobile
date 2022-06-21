import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/homiletic_list_item.dart';
import 'package:matomo/matomo.dart';

class LessonPage extends TraceableStatelessWidget {
  final List<Homiletic> homiletics;

  const LessonPage({Key? key, required this.homiletics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Previous Homiletics")),
      body: ListView.builder(
          itemBuilder: ((context, index) {
            Homiletic homiletic = homiletics[index];
            return HomileticListItem(homiletic: homiletic);
          }),
          itemCount: homiletics.length),
    );
  }
}
