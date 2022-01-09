import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/rounded_button.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';

class StartActivity extends StatelessWidget {
  const StartActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  "Start with your own passage",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoundedButton(
                    onClick: () async {
                      Homiletic homiletic = Homiletic();
                      await homiletic.update();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)),
                      );
                    },
                    child: const Text("New Homiletics")),
                RoundedButton(
                    onClick: () async {
                      LectureNote note = LectureNote();
                      await note.update();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotesEditor(note: note)));
                    },
                    child: const Text("New Lecture Notes"))
              ],
            )
          ],
        ));
  }
}
