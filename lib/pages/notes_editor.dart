import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/components/recording_section.dart';
import 'package:homiletics/pages/home.dart';
import 'package:split_view/split_view.dart';

class NotesEditor extends StatefulWidget {
  const NotesEditor({Key? key, this.note}) : super(key: key);

  final LectureNote? note;

  @override
  State<NotesEditor> createState() => _NotesState();
}

class _NotesState extends State<NotesEditor> {
  late LectureNote _thisNote;
  late QuillController _noteController;
  final TextEditingController _passageController = TextEditingController();
  String _translationVersion = 'web';
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
      _passageController.text = _thisNote.passage;
    });
    await _thisNote.update();
  }

  @override
  void dispose() {
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    _passageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> splitChildren = [
      Column(children: [
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
      ]),
      VerseContainer(
          key: _verseContainerKey,
          passage: _thisNote.passage,
          translation: Preferences.translation)
    ];

    return Scaffold(
        appBar: AppBar(
          title: TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: _passageController,
            decoration: const InputDecoration(
                hintText: 'Passage', suffixIcon: Icon(Icons.edit)),
            onChanged: (String value) async {
              _thisNote.passage = value;
              if (_thisNote.id != -1) await _thisNote.update();
            },
            onEditingComplete: () => setState(() {}),
            onSubmitted: (_) => setState(() {}),
          ),
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
                    case 3:
                      showDialog(
                          context: context,
                          builder: ((context) => PreferencesModal(
                                onTranslationChanged: () {
                                  // Reload the verse container when translation changes
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _verseContainerKey.currentState
                                        ?.reloadPassage();
                                  });
                                },
                              )));
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
                      const PopupMenuItem(
                        value: 3,
                        child: ListTile(
                          title: Text('Preferences'),
                          leading: Icon(Icons.settings),
                        ),
                      ),
                    ]),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          // Use screen size to determine orientation, not available space
          // This prevents keyboard opening from triggering layout changes
          final screenSize = MediaQuery.sizeOf(context);
          final isLandscape = screenSize.width > screenSize.height;

          return SafeArea(
            bottom: false,
            child: SplitView(
                indicator: SplitIndicator(
                    viewMode: isLandscape
                        ? SplitViewMode.Horizontal
                        : SplitViewMode.Vertical),
                viewMode: isLandscape
                    ? SplitViewMode.Horizontal
                    : SplitViewMode.Vertical,
                children: isLandscape
                    ? splitChildren.reversed.toList()
                    : splitChildren),
          );
        }));
  }
}
