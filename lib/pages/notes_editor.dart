import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/pages/home.dart';
import 'package:matomo/matomo.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NotesEditor extends TraceableStatefulWidget {
  const NotesEditor({Key? key, this.note}) : super(key: key);

  final LectureNote? note;

  @override
  State<NotesEditor> createState() => _NotesState();
}

class _NotesState extends State<NotesEditor> {
  late LectureNote _thisNote;
  bool _isTrayOpen = false;
  String _translationVersion = 'web';
  final PanelController _controller = PanelController();

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
        appBar: AppBar(
          title: const Text('Homiletics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()), (r) => false);
            },
          ),
          actions: [
            PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      Navigator.pushAndRemoveUntil(
                          context, MaterialPageRoute(builder: (context) => const Home()), (r) => false);
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
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _thisNote.delete();
                                      Navigator.pushAndRemoveUntil(
                                          context, MaterialPageRoute(builder: (context) => const Home()), (r) => false);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: const Text("Lecture Note Deleted"),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                    } catch (error) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: const Text("Something went wrong. Try again soon."),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                      sendError(error, "notes deletion");
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
                      const PopupMenuItem(child: ListTile(leading: Icon(Icons.save), title: Text("Save")), value: 0),
                      const PopupMenuItem(
                          child: ListTile(
                            title: Text('Delete'),
                            leading: Icon(Icons.delete),
                          ),
                          value: 1),
                    ]),
          ],
        ),
        body: SlidingUpPanel(
            controller: _controller,
            minHeight: 75,
            // panelSnapping: false,
            backdropEnabled: true,
            parallaxEnabled: false,
            isDraggable: true,
            borderRadius: BorderRadius.circular(15),
            onPanelClosed: () {
              setState(() {
                _isTrayOpen = false;
              });
            },
            onPanelSlide: (height) {
              if (height > 0 && !_isTrayOpen) {
                setState(() {
                  _isTrayOpen = true;
                });
              }
            },
            onPanelOpened: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                _isTrayOpen = true;
              });
            },
            collapsed: Column(children: [
              Container(
                  padding: const EdgeInsets.only(top: 7),
                  child: Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(300)),
                    ),
                  )),
              SizedBox(
                  height: 60,
                  child: Row(children: [
                    Container(
                        width: MediaQuery.of(context).size.width - 100,
                        margin: const EdgeInsets.all(8),
                        child: TextField(
                          keyboardType: TextInputType.text,
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
                    SizedBox(
                      width: 75,
                      child: DropdownButton(
                        items: [
                          ...bibleTranslations
                              .map((e) => DropdownMenuItem(
                                    child: Text(
                                      e.short,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: e.code,
                                  ))
                              .toList()
                        ],
                        onChanged: (version) {
                          setState(() {
                            _translationVersion = version.toString();
                          });
                        },
                        value: _translationVersion,
                      ),
                    )
                  ])),
            ]),
            panel: Column(children: [
              Container(
                  padding: const EdgeInsets.only(top: 7, bottom: 12),
                  child: Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(300)),
                    ),
                  )),
              VerseContainer(passage: _thisNote.passage, controller: _controller, version: _translationVersion)
            ]),
            body: Center(
                child: ListView(padding: const EdgeInsets.all(15), children: [
              Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  child: const Text("Notes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              TextField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: TextEditingController(text: _thisNote.note),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 6,
                onChanged: (String value) async {
                  _thisNote.note = value;
                  if (_thisNote.id != -1) await _thisNote.update();
                },
              ),
              const HelpMenu()
            ]))));
  }
}
