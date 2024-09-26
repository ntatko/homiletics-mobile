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
  String _passageReference = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey[900]
            : Colors.blueGrey[100],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Start with your own passage",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() {
                  _passageReference = value;
                }),
                decoration: InputDecoration(
                  labelText: "Enter Bible passage reference",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Increased border radius for a rounder look
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: _passageReference.isNotEmpty
                        ? () async {
                            Homiletic homiletic =
                                Homiletic(passage: _passageReference);
                            await homiletic.update();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomileticEditor(homiletic: homiletic)),
                            );
                          }
                        : null,
                    child: const Text(
                      "Homiletics",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _passageReference.isNotEmpty
                        ? () async {
                            LectureNote note =
                                LectureNote(passage: _passageReference);
                            await note.update();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotesEditor(note: note)),
                            );
                          }
                        : null,
                    child: const Text(
                      "Lecture Notes",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
