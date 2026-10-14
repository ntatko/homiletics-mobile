import 'package:flutter/material.dart';
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

// ignore: must_be_immutable
class ContentSearches extends StatelessWidget {
  String searchString;
  ContentSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<ContentSummary>>(
        future: getSummaryByText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Content Summaries",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((summary) {
                return ListTile(
                  onTap: () async {
                    Homiletic homiletic =
                        await getHomileticById(summary.homileticId);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)));
                  },
                  title: Text(summary.summary),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class DivisionSearches extends StatelessWidget {
  String searchString;
  DivisionSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Division>>(
        future: getDivisionByText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Divisions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((division) {
                return ListTile(
                  onTap: () async {
                    Homiletic homiletic =
                        await getHomileticById(division.homileticId);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)));
                  },
                  title: Text(division.title),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class ApplicationSearches extends StatelessWidget {
  String searchString;
  ApplicationSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<Application>>(
        future: getApplicationsByText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Applications",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((application) {
                return ListTile(
                  onTap: () async {
                    Homiletic homiletic =
                        await getHomileticById(application.homileticsId);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)));
                  },
                  title: Text(application.text),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class AimSearches extends StatelessWidget {
  String searchString;
  AimSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<Homiletic>>(
        future: getHomileticsByAimText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Aims",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((homiletic) {
                return ListTile(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)));
                  },
                  title: Text(homiletic.aim),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class SummarySentenceSearches extends StatelessWidget {
  String searchString;
  SummarySentenceSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<Homiletic>>(
        future: getHomileticsBySummarySentenceText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Summary Sentences",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((homiletic) {
                return ListTile(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)));
                  },
                  title: Text(homiletic.subjectSentence),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class PassageSearches extends StatelessWidget {
  String searchString;
  PassageSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<Homiletic>>(
        future: getHomileticsByPassageText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Homiletics Passages",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((homiletic) {
                return ListTile(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomileticEditor(homiletic: homiletic)));
                  },
                  title: Text(homiletic.passage),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class LectureNoteSearches extends StatelessWidget {
  String searchString;
  LectureNoteSearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<LectureNote>>(
        future: getLectureNotesByText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Lecture Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((note) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotesEditor(note: note)));
                  },
                  title:
                      Text(note.passage.isNotEmpty ? note.passage : note.note),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

// ignore: must_be_immutable
class WordStudySearches extends StatelessWidget {
  String searchString;
  WordStudySearches({Key? key, this.searchString = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchString.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<WordStudy>>(
        future: getWordStudiesByText(searchString),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(children: [
              const Text(
                "Word Studies",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ...snapshot.data!.map((study) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WordStudyEditor(study: study)));
                  },
                  title: Text(
                      study.word.isNotEmpty ? study.word : study.passage),
                );
              }).toList(),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
