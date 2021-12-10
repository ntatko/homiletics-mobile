import 'package:flutter/material.dart';
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
            const Text("Start a new lesson"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoundedButton(
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomileticEditor()),
                      );
                    },
                    child: const Text("New Homiletics")),
                RoundedButton(
                    onClick: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotesEditor()));
                    },
                    child: const Text("New Lecture Notes"))
              ],
            )
          ],
        ));
  }
}
