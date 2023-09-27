import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';

class StartActivity extends StatefulWidget {
  const StartActivity({Key? key}) : super(key: key);

  @override
  State<StartActivity> createState() => _StartActivityState();
}

class _StartActivityState extends State<StartActivity> {
  String _lectureNoteTitle = "";
  String _homileticTitle = "";

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
        child: Card(
            color: Colors.blueGrey[100],
            child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: const Text(
                          "Start with your own passage",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: const Text(
                          "",
                          style: TextStyle(fontSize: 13),
                        )),
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                            // onPressed: () async {
                            //   Homiletic homiletic = Homiletic();
                            //   await homiletic.update();
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(builder: (context) => HomileticEditor(homiletic: homiletic)),
                            //   );
                            // },
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: Padding(
                                          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                                            const Text("Start a new Homiletic",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            const Text("Enter a Bible passage reference to start a new homiletic."),
                                            const SizedBox(height: 10),
                                            TextField(
                                                onChanged: (value) => setState(() {
                                                      _homileticTitle = value;
                                                    }),
                                                decoration: const InputDecoration(
                                                    labelText: "Passage Reference", border: OutlineInputBorder())),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                                child: const Text("Start"),
                                                onPressed: () async {
                                                  Homiletic homiletic = Homiletic(passage: _homileticTitle);
                                                  await homiletic.update();
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => HomileticEditor(homiletic: homiletic)));
                                                })
                                          ]),
                                        ),
                                      ));
                            },
                            child: const Text(
                              "New Homiletics",
                              textAlign: TextAlign.center,
                            )),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: Padding(
                                          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                                            const Text("Start a new lecture note",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            const Text("Enter a Bible passage reference to start a new lecture note."),
                                            const SizedBox(height: 10),
                                            TextField(
                                                onChanged: (value) => setState(() {
                                                      _lectureNoteTitle = value;
                                                    }),
                                                decoration: const InputDecoration(
                                                    labelText: "Passage Reference", border: OutlineInputBorder())),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                                child: const Text("Start"),
                                                onPressed: () async {
                                                  LectureNote note = LectureNote(passage: _lectureNoteTitle);
                                                  await note.update();
                                                  Navigator.push(context,
                                                      MaterialPageRoute(builder: (context) => NotesEditor(note: note)));
                                                })
                                          ]),
                                        ),
                                      ));
                            },
                            child: const Text(
                              "New Lecture Notes",
                              textAlign: TextAlign.center,
                            ))
                      ],
                    )
                  ],
                ))));
  }
}
