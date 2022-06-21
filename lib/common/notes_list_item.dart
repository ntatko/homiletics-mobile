import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotesListItem extends StatelessWidget {
  final LectureNote note;
  const NotesListItem({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        key: Key("${note.id}"),
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        // height: 80,
        child: GestureDetector(
            onTapUp: (_) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotesEditor(note: note)));
            },
            child: Card(
              surfaceTintColor: Colors.orange,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(StringToHex.toColor(
                          note.passage.padLeft(3).toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '').substring(0, 3))),
                    ),
                    child: Center(
                      child: Text(
                        note.passage.replaceAll(RegExp(r'\s'), '').padRight(3).substring(0, 3),
                        textScaleFactor: 1.0,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(note.passage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        Text(timeago.format(note.time ?? DateTime.now(), locale: 'en_short')),
                      ],
                    ))
              ]),
            )));
  }
}
