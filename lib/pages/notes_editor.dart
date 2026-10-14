import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/recording_section.dart';
import 'package:homiletics/pages/home.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NotesEditor extends StatefulWidget {
  const NotesEditor({Key? key, this.note}) : super(key: key);

  final LectureNote? note;

  @override
  State<NotesEditor> createState() => _NotesState();
}

class _NotesState extends State<NotesEditor> {
  late LectureNote _thisNote;
  late QuillController _noteController;
  bool _isTrayOpen = false;
  String _translationVersion = 'web';
  final PanelController _controller = PanelController();
  final GlobalKey<VerseContainerState> _verseContainerKey =
      GlobalKey<VerseContainerState>();

  @override
  void initState() {
    super.initState();
    prepTheTable();
  }

  /// The note's rich text is stored as Quill Delta JSON in the same `note`
  /// TEXT column older plain-text notes used, so old notes need a fallback:
  /// if it doesn't parse as Delta JSON, treat it as a single plain-text run.
  QuillController _buildNoteController(String note) {
    Document document;
    try {
      document = Document.fromJson(jsonDecode(note) as List);
    } catch (_) {
      document = Document();
      if (note.isNotEmpty) {
        document.insert(0, note);
      }
    }
    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    controller.addListener(_onNoteChanged);
    return controller;
  }

  void _onNoteChanged() {
    final String json = jsonEncode(_noteController.document.toDelta().toJson());
    _thisNote.note = json;
    if (_thisNote.id != -1) _thisNote.update();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if translation preference has changed and reload if needed
    final currentTranslation = Preferences.preferredVersion;
    if (currentTranslation != _translationVersion) {
      setState(() {
        _translationVersion = currentTranslation;
      });
      // Reload the verse container with new translation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verseContainerKey.currentState?.reloadPassage();
      });
    }
  }

  prepTheTable() async {
    setState(() {
      _thisNote = widget.note ?? LectureNote();
      _translationVersion = Preferences.preferredVersion;
      _noteController = _buildNoteController(_thisNote.note);
    });
    await _thisNote.update();
  }

  @override
  void dispose() {
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    super.dispose();
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
                                      if (!mounted) return;
                                      final navigatorContext = context;
                                      Navigator.pushAndRemoveUntil(
                                          navigatorContext,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home()),
                                          (r) => false);
                                      ScaffoldMessenger.of(navigatorContext)
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
                                      sendError(error, "notes deletion");
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text("Delete"),
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
                        value: 0,
                        child: ListTile(
                            leading: Icon(Icons.save), title: Text("Save")),
                      ),
                      const PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          title: Text('Delete'),
                          leading: Icon(Icons.delete),
                        ),
                      ),
                    ]),
          ],
        ),
        body: SlidingUpPanel(
            backdropColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.white
                    : Colors.white,
            controller: _controller,
            minHeight: 75,
            // panelSnapping: false,
            backdropEnabled: true,
            parallaxEnabled: false,
            isDraggable: true,
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.black
                : Colors.white,
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
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(300)),
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
                          controller:
                              TextEditingController(text: _thisNote.passage),
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
                          ...Translation.all
                              .map((e) => DropdownMenuItem(
                                    value: e.code,
                                    child: Text(
                                      e.short,
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(300)),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.only(top: 40),
                  height: MediaQuery.of(context).size.height * 0.56,
                  child: VerseContainer(
                      key: _verseContainerKey,
                      passage: _thisNote.passage,
                      translation: Preferences.translation))
            ]),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RecordingSection(note: _thisNote),
              ),
              QuillSimpleToolbar(
                controller: _noteController,
                config: const QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showSearchButton: false,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: QuillEditor.basic(
                    controller: _noteController,
                    config: const QuillEditorConfig(
                      placeholder: 'Notes',
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
            ])));
  }
}
