import 'package:flutter/material.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/components/search_bar.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchString = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
        SearchBar(
            enabled: true,
            autofocus: true,
            icon: const Icon(Icons.chevron_left),
            onIconPressed: () => Navigator.pop(context),
            onChanged: (String s) => setState(() {
                  _searchString = s;
                })),
        Expanded(
            child: _searchString.isEmpty
                ? const Center(child: Text("Search to find results"))
                : ListView(
                    children: [
                      ContentSearches(searchString: _searchString),
                      DivisionSearches(searchString: _searchString),
                      ApplicationSearches(searchString: _searchString),
                      AimSearches(searchString: _searchString),
                      SummarySentenceSearches(searchString: _searchString),
                      PassageSearches(searchString: _searchString),
                    ],
                  ))
      ]),
    ));
  }
}

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
