import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:loggy/loggy.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class PastLectureNotes extends StatelessWidget {
  const PastLectureNotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LectureNote>>(
      future: getLectureNotes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");

        List<LectureNote> notes = snapshot.data ?? [];

        return snapshot.hasData && notes.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 20, bottom: 10),
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Past Notes"),
                              // TextButton(
                              //     onPressed: () {}, child: const Text("See all"))
                            ])),
                    ...notes.map((note) {
                      return SizedBox(
                          key: Key("${note.id}"),
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 5),
                              child: GestureDetector(
                                  onTapUp: (_) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NotesEditor(note: note)));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 0,
                                          bottom: 8,
                                          right: 25),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: Colors.orange[400],
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[400]!,
                                                blurRadius: 10,
                                                offset: const Offset(0, 3))
                                          ]),
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      height: 75,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Container(
                                                height: 50,
                                                width: 50,
                                                margin: const EdgeInsets.only(
                                                    right: 10, left: 10),
                                                decoration: BoxDecoration(
                                                    color: Color(
                                                        StringToHex.toColor(note
                                                            .passage
                                                            .padLeft(3)
                                                            .toLowerCase()
                                                            .replaceAll(
                                                                RegExp(
                                                                    r'[^\w\s]+'),
                                                                '')
                                                            .substring(0, 3))),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    border: Border.all(
                                                        color: Colors.white)),
                                                child: Center(
                                                  child: Text(
                                                    note.passage
                                                        .replaceAll(
                                                            RegExp(r'\s'), '')
                                                        .padRight(3)
                                                        .substring(0, 3),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22),
                                                  ),
                                                )),
                                            Text(note.passage,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17)),
                                          ]),
                                          //Times are wildly wrong

                                          Text(timeago.format(
                                              note.time ?? DateTime.now(),
                                              locale: 'en_short')),
                                        ],
                                      )))));
                    })
                  ],
                ))
            : const SizedBox.shrink();
      },
    );
  }
}
