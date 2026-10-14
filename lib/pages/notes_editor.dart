import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/editor/passage_split_scaffold.dart';
import 'package:homiletics/components/recording_section.dart';

class NotesEditor extends StatefulWidget {
  const NotesEditor({Key? key, this.note}) : super(key: key);

  final LectureNote? note;

  @override
  State<NotesEditor> createState() => _NotesState();
}

class _NotesState extends State<NotesEditor> {
  static const Duration _saveDelay = Duration(milliseconds: 500);

  late final LectureNote _thisNote;
  late final QuillController _noteController;

  /// The Delta JSON last copied into [_thisNote.note], so selection-only
  /// changes (which also notify the controller) don't trigger saves.
  late String _lastNoteJson;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _thisNote = widget.note ?? LectureNote();
    _noteController = _buildNoteController(_thisNote.note);
    _lastNoteJson = _currentNoteJson();
    // Only a brand-new note needs saving up front; re-saving an existing one
    // would bump its time just for being opened.
    if (_thisNote.id == -1) _thisNote.update();
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

  String _currentNoteJson() =>
      jsonEncode(_noteController.document.toDelta().toJson());

  void _onNoteChanged() {
    final String json = _currentNoteJson();
    if (json == _lastNoteJson) return;
    _lastNoteJson = json;
    _thisNote.note = json;
    _scheduleSave();
  }

  void _onPassageChanged(String value) {
    _thisNote.passage = value;
    _scheduleSave();
  }

  /// Debounces saves while the user types; [_flushSave] writes immediately.
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, _flushSave);
  }

  Future<void> _flushSave() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    // update() runs saves in order, so this can't race the initial insert.
    await _thisNote.update();
  }

  @override
  void dispose() {
    final bool hadPendingSave = _saveTimer?.isActive ?? false;
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    if (hadPendingSave) {
      _flushSave().whenComplete(notifyStudyDataChanged);
    } else {
      _saveTimer?.cancel();
      notifyStudyDataChanged();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PassageSplitScaffold(
      initialPassage: _thisNote.passage,
      passageHint: 'Passage',
      onPassageChanged: _onPassageChanged,
      itemName: "Lecture Note",
      deletedMessage: "Lecture Note Deleted",
      deleteErrorIdentifier: "notes deletion",
      onDelete: _thisNote.delete,
      child: Column(children: [
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
    );
  }
}
