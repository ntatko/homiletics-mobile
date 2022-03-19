import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/rounded_button.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/pages/home.dart';

class NotesEditor extends StatefulWidget {
  const NotesEditor({Key? key, this.note}) : super(key: key);

  final LectureNote? note;

  @override
  State<NotesEditor> createState() => _NotesState();
}

class _NotesState extends State<NotesEditor> {
  late LectureNote _thisNote;

  @override
  void initState() {
    super.initState();
    prepTheTable();
  }

  prepTheTable() async {
    setState(() {
      _thisNote = widget.note ?? LectureNote();
    });
    await _thisNote.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: SizedBox(
            width: 180,
            height: 60,
            child: RoundedButton(
                onClick: () {
                  showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0))),
                      context: context,
                      builder: (context) {
                        return Column(children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 3),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _thisNote.passage,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.close))
                                  ])),
                          Expanded(
                              flex: 1,
                              child: VerseContainer(passage: _thisNote.passage))
                        ]);
                      });
                },
                child: Center(
                    child: Row(children: const [
                  Icon(Icons.search),
                  Text("Show passage")
                ])))),
        appBar: AppBar(
          title: const Text('Homiletics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (r) => false);
            },
          ),
          actions: [
            PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                          (r) => false);
                      return;
                    case 1:
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Are you sure?"),
                              content: const Text(
                                  "Deleting this Lecture Note is permanent and cannot be undone. Are you sure you wish to proceed?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _thisNote.delete();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home()),
                                          (r) => false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            const Text("Lecture Note Deleted"),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                    } catch (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: const Text(
                                            "Something went wrong. Try again soon."),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                    }
                                  },
                                  child: const Text("Delete"),
                                  style: TextButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                )
                              ],
                            );
                          });
                      return;
                    // case 2:
                    //   try {
                    //     await createHomileticsPdf(_thisHomiletic!, _summaries,
                    //         _divisions, _applications);
                    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //       content: const Text(
                    //           "PDF created successfully. Look in your files app to find it."),
                    //       action: SnackBarAction(
                    //         onPressed: () {},
                    //         label: "Ok",
                    //       ),
                    //     ));
                    //   } catch (error) {
                    //     print("error: ${error.toString()}");
                    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //       content: const Text(
                    //           "Something went wrong creating your PDF. Try again soon."),
                    //       action: SnackBarAction(
                    //         onPressed: () {},
                    //         label: "Ok",
                    //       ),
                    //     ));
                    //   }
                  }
                },
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => [
                      const PopupMenuItem(
                          child: ListTile(
                              leading: Icon(Icons.save), title: Text("Save")),
                          value: 0),
                      const PopupMenuItem(
                          child: ListTile(
                            title: Text('Delete'),
                            leading: Icon(Icons.delete),
                          ),
                          value: 1),
                      // const PopupMenuItem(
                      //     child: ListTile(
                      //         title: Text("Save as PDF"),
                      //         leading: Icon(Icons.download)),
                      //     value: 2)
                    ]),
          ],
        ),
        body: Center(
            child: ListView(padding: const EdgeInsets.all(15), children: [
          const Text("Passage",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Container(
              margin: const EdgeInsets.all(8),
              child: TextField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: TextEditingController(text: _thisNote.passage),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) async {
                  _thisNote.passage = value;
                  if (_thisNote.id != -1) await _thisNote.update();
                },
              )),
          const Divider(),
          Container(
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              child: const Text("Notes",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Expanded(
              child: TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: TextEditingController(text: _thisNote.note),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 30,
            minLines: null,
            onChanged: (String value) async {
              _thisNote.note = value;
              if (_thisNote.id != -1) await _thisNote.update();
            },
          ))
        ])));
  }
}
