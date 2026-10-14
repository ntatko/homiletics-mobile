import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/editor/passage_split_scaffold.dart';
import 'package:homiletics/components/recording_section.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/lecture_widgets.dart';

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

  /// Inserts [mark] (a recording time, "[14:02] ") at the cursor,
  /// replacing any selected text.
  void _insertTimeMark(String mark) {
    final TextSelection selection = _noteController.selection;
    // The document always ends with a newline that can't be typed past.
    final int end = _noteController.document.length - 1;
    final int from = selection.isValid ? selection.start.clamp(0, end) : end;
    final int to = selection.isValid ? selection.end.clamp(from, end) : end;
    _noteController.replaceText(from, to - from, mark,
        TextSelection.collapsed(offset: from + mark.length));
  }

  Widget _toolbarButton(Attribute attribute, Widget icon, String tooltip) {
    // Driven straight from the controller: flutter_quill's
    // QuillToolbarToggleStyleButton childBuilder hook throws a type error
    // at runtime in 11.5.0.
    return ListenableBuilder(
      listenable: _noteController,
      builder: (context, _) {
        final bool isToggled = _noteController
                .getSelectionStyle()
                .attributes[attribute.key]
                ?.value ==
            attribute.value;
        return NotesToolbarButton(
          icon: icon,
          tooltip: tooltip,
          selected: isToggled,
          onPressed: () => _noteController.formatSelection(
              isToggled ? Attribute.clone(attribute, null) : attribute),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final TextStyle noteStyle =
        AppText.body.copyWith(height: 1.55, color: c.ink);
    const HorizontalSpacing noSpacing = HorizontalSpacing(0, 0);

    final Widget toolbar = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toolbarButton(
            Attribute.bold, const Icon(Icons.format_bold_rounded), "Bold"),
        _toolbarButton(Attribute.italic,
            const Icon(Icons.format_italic_rounded), "Italic"),
        _toolbarButton(Attribute.ul,
            const Icon(Icons.format_list_bulleted_rounded), "Bulleted list"),
        _toolbarButton(Attribute.ol,
            const Icon(Icons.format_list_numbered_rounded), "Numbered list"),
      ],
    );

    final Widget editor = QuillEditor.basic(
      controller: _noteController,
      config: QuillEditorConfig(
        placeholder: 'Notes',
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(noteStyle, noSpacing,
              const VerticalSpacing(0, 6), VerticalSpacing.zero, null),
          lists: DefaultListBlockStyle(
              noteStyle,
              noSpacing,
              const VerticalSpacing(0, 6),
              const VerticalSpacing(0, 4),
              null,
              null),
          placeHolder: DefaultTextBlockStyle(noteStyle.copyWith(color: c.muted),
              noSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
        ),
      ),
    );

    return PassageSplitScaffold(
      initialPassage: _thisNote.passage,
      passageHint: 'Passage',
      onPassageChanged: _onPassageChanged,
      itemName: "Lecture Note",
      deletedMessage: "Lecture Note Deleted",
      deleteErrorIdentifier: "notes deletion",
      onDelete: _thisNote.delete,
      headerLabel: 'Lecture · Passage',
      versePanelFirst: false,
      verseWeight: 0.26,
      child: RecordingSection(
        note: _thisNote,
        notesToolbar: toolbar,
        notesEditor: editor,
        onTimeMark: _insertTimeMark,
      ),
    );
  }
}
