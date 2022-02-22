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
  LectureNote? _thisNote;

  @override
  void initState() {
    super.initState();
    prepTheTable();
  }

  prepTheTable() async {
    if (widget.note != null) {
      setState(() {
        _thisNote = widget.note;
      });
    } else {
      setState(() {
        _thisNote = LectureNote();
        _thisNote?.update();
      });
    }
    await _thisNote?.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                              "Deleting these lecture notes cannot be undone. Are you sure you wish to proceed?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await _thisNote?.delete();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Home()),
                                      (r) => false);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text("Notes Deleted"),
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
                },
                icon: const Icon(Icons.delete)),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (r) => false);
              },
            ),
          ],
        ),
        body: Center(
            child: ListView(padding: const EdgeInsets.all(15), children: [
          const Text("Passage",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Container(
              margin: const EdgeInsets.all(8),
              child: TextField(
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                controller: TextEditingController(text: _thisNote?.passage),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) async {
                  _thisNote?.passage = value;
                  if (_thisNote?.id != -1) await _thisNote?.update();
                },
              )),
          SizedBox(
              width: 150,
              child: RoundedButton(
                  onClick: () {
                    showModalBottomSheet(
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
                                        _thisNote?.passage ?? '',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: const Icon(Icons.close))
                                    ])),
                            Expanded(
                                flex: 1,
                                child: VerseContainer(
                                    passage: _thisNote?.passage ?? ''))
                          ]);
                        });
                  },
                  child: Center(
                      child: Row(children: const [
                    Icon(Icons.search),
                    Text("Show passage")
                  ])))),
          const Divider(),
          Container(
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              child: const Text("Notes",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: TextEditingController(text: _thisNote?.note),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 30,
            minLines: 20,
            onChanged: (String value) async {
              _thisNote?.note = value;
              if (_thisNote?.id != -1) await _thisNote?.update();
            },
          )
        ])));
  }
}
