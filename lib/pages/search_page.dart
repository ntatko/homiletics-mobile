import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show Document;
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:loggy/loggy.dart';

/// Every kind of search result, one titled section per kind. Sections with
/// no matches don't show.
class SearchResults extends StatelessWidget {
  final String searchString;

  const SearchResults({Key? key, required this.searchString}) : super(key: key);

  /// Lecture notes are stored as Quill Delta JSON (older ones as plain
  /// text); show the text, not the JSON.
  static String _notePreview(String note) {
    try {
      return Document.fromJson(jsonDecode(note) as List).toPlainText().trim();
    } catch (_) {
      return note;
    }
  }

  static Future<Widget> _homileticById(int id) async =>
      HomileticEditor(homiletic: await getHomileticById(id));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchSection<ContentSummary>(
          title: "Content Summaries",
          searchString: searchString,
          search: getSummaryByText,
          label: (summary) => summary.summary,
          open: (summary) => _homileticById(summary.homileticId),
        ),
        SearchSection<Division>(
          title: "Divisions",
          searchString: searchString,
          search: getDivisionByText,
          label: (division) => division.title,
          open: (division) => _homileticById(division.homileticId),
        ),
        SearchSection<Application>(
          title: "Applications",
          searchString: searchString,
          search: getApplicationsByText,
          label: (application) => application.text,
          open: (application) => _homileticById(application.homileticsId),
        ),
        SearchSection<Homiletic>(
          title: "Aims",
          searchString: searchString,
          search: getHomileticsByAimText,
          label: (homiletic) => homiletic.aim,
          open: (homiletic) async => HomileticEditor(homiletic: homiletic),
        ),
        SearchSection<Homiletic>(
          title: "Summary Sentences",
          searchString: searchString,
          search: getHomileticsBySummarySentenceText,
          label: (homiletic) => homiletic.subjectSentence,
          open: (homiletic) async => HomileticEditor(homiletic: homiletic),
        ),
        SearchSection<Homiletic>(
          title: "Homiletics Passages",
          searchString: searchString,
          search: getHomileticsByPassageText,
          label: (homiletic) => homiletic.passage,
          open: (homiletic) async => HomileticEditor(homiletic: homiletic),
        ),
        SearchSection<LectureNote>(
          title: "Lecture Notes",
          searchString: searchString,
          search: getLectureNotesByText,
          label: (note) =>
              note.passage.isNotEmpty ? note.passage : _notePreview(note.note),
          open: (note) async => NotesEditor(note: note),
        ),
        SearchSection<WordStudy>(
          title: "Word Studies",
          searchString: searchString,
          search: getWordStudiesByText,
          label: (study) => study.word.isNotEmpty ? study.word : study.passage,
          open: (study) async => WordStudyEditor(study: study),
        ),
      ],
    );
  }
}

/// One titled list of search matches of type [T]. Tapping a match opens the
/// page [open] builds for it.
class SearchSection<T> extends StatefulWidget {
  final String title;
  final String searchString;
  final Future<List<T>> Function(String query) search;
  final String Function(T item) label;

  /// Builds the page to open for a match. May look things up (e.g. the
  /// homiletic a division belongs to), and so may fail.
  final Future<Widget> Function(T item) open;

  const SearchSection({
    Key? key,
    required this.title,
    required this.searchString,
    required this.search,
    required this.label,
    required this.open,
  }) : super(key: key);

  @override
  State<SearchSection<T>> createState() => _SearchSectionState<T>();
}

class _SearchSectionState<T> extends State<SearchSection<T>> {
  Future<List<T>>? _results;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  @override
  void didUpdateWidget(covariant SearchSection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchString != widget.searchString) _runSearch();
  }

  void _runSearch() {
    _results =
        widget.searchString.isEmpty ? null : widget.search(widget.searchString);
  }

  Future<void> _open(T item) async {
    if (_opening) return;
    _opening = true;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final Widget page = await widget.open(item);
      if (!mounted) return;
      navigator.push(MaterialPageRoute(builder: (context) => page));
    } catch (error) {
      logError('Opening search result failed: $error');
      messenger.showSnackBar(const SnackBar(
        content: Text("Couldn't open that result. It may have been deleted."),
      ));
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_results == null) return const SizedBox.shrink();

    return FutureBuilder<List<T>>(
        future: _results,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logError('${widget.title} search failed: ${snapshot.error}');
            return const SizedBox.shrink();
          }
          final List<T> matches = snapshot.data ?? const [];
          if (matches.isEmpty) return const SizedBox.shrink();
          return Column(children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            ...matches.map((item) {
              return ListTile(
                onTap: () => _open(item),
                title: Text(widget.label(item)),
              );
            }),
          ]);
        });
  }
}
