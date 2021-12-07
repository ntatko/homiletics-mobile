import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/passage.dart';
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
  int _tab = 0;

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
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: () async {
                LectureNote removed =
                    await _thisNote?.delete() ?? LectureNote();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Deleted Lecture Note'),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () async {
                        await removed.update();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NotesEditor(note: removed)));
                      }),
                ));
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (r) => false);
              },
            ),
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
                  labelText: 'Genesis 1:1-15',
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
                          return VerseContainer(
                              passage: _thisNote?.passage ?? '');
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
