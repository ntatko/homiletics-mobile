import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/homiletics/aim_card.dart';
import 'package:homiletics/components/homiletics/application_questions_card.dart';
import 'package:homiletics/components/homiletics/content_summaries_card.dart';
import 'package:homiletics/components/homiletics/divisions_card.dart';
import 'package:homiletics/components/homiletics/summary_sentence_card.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:split_view/split_view.dart';

class HomileticEditor extends StatefulWidget {
  const HomileticEditor({Key? key, this.homiletic}) : super(key: key);

  final Homiletic? homiletic;

  @override
  State<HomileticEditor> createState() => _HomileticState();
}

class _HomileticState extends State<HomileticEditor> {
  late Homiletic _thisHomiletic;
  List<ContentSummary> _summaries = [];
  List<Division> _divisions = [];
  List<Application> _applications = [];

  @override
  void initState() {
    setState(() {
      _thisHomiletic = widget.homiletic ?? Homiletic();
    });
    super.initState();
    prepTheTable();
  }

  prepTheTable() async {
    await _thisHomiletic.update();
    List<ContentSummary> savedSummaries =
        await getSummariesByHomileticId(_thisHomiletic.id);
    List<Division> savedDivisions =
        await getDivisionsByHomileticId(_thisHomiletic.id);
    List<Application> savedApplications =
        await getApplicationsByHomileticId(_thisHomiletic.id);

    setState(() {
      _summaries = savedSummaries.isNotEmpty
          ? savedSummaries
          : [ContentSummary.blank(_thisHomiletic.id)];
      _divisions = savedDivisions.isNotEmpty
          ? savedDivisions
          : [Division.blank(_thisHomiletic.id)];
      _applications = savedApplications.isNotEmpty
          ? savedApplications
          : [Application.blank(_thisHomiletic.id)];
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> splitChildren = [
      ListView(
        padding: const EdgeInsets.all(5),
        children: [
          ContentSummariesCard(
              contentSummaries: _summaries,
              homiletic: _thisHomiletic,
              addContentSummary: () {
                _summaries.add(ContentSummary.blank(_thisHomiletic.id));
              },
              removeContentSummary: () async {
                await _summaries[_summaries.length - 1].delete();
                setState(() {
                  _summaries.removeLast();
                });
              }),
          const SizedBox(height: 20),
          DivisionsCard(
              divisions: _divisions,
              homiletic: _thisHomiletic,
              addDivision: () {
                setState(() {
                  _divisions.add(Division.blank(_thisHomiletic.id));
                });
              },
              removeDivision: () async {
                await _divisions[_divisions.length - 1].delete();
                setState(() {
                  _divisions.removeLast();
                });
              }),
          const SizedBox(height: 20),
          SummarySentenceCard(homiletic: _thisHomiletic),
          const SizedBox(height: 20),
          AimCard(homiletic: _thisHomiletic),
          const SizedBox(height: 20),
          ApplicationQuestionsCard(
              applications: _applications,
              homiletic: _thisHomiletic,
              addApplication: () {
                setState(() {
                  _applications.add(Application.blank(_thisHomiletic.id));
                });
              },
              removeApplication: () async {
                await _applications[_applications.length - 1].delete();
                setState(() {
                  _applications.removeLast();
                });
              }),
        ],
      ),
      VerseContainer(
          passage: _thisHomiletic.passage, translation: Translation.web)
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: TextEditingController()..text = _thisHomiletic.passage,
            decoration: const InputDecoration(suffixIcon: Icon(Icons.edit)),
            onChanged: (String value) {
              _thisHomiletic.updatePassage(value);
            },
            onEditingComplete: () => setState(() => {}),
            onSubmitted: (_) => setState(() {}),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (kIsWeb) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('You will lose all your work.'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                              (r) => false);
                        },
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (r) => false);
              }
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
                                  "Deleting this Homiletics lesson is permanent and cannot be undone. Are you sure you wish to proceed?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _thisHomiletic.delete();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home()),
                                          (r) => false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            const Text("Homiletics Deleted"),
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
                                      sendError(error, "delete homiletics");
                                    }
                                  },
                                  child: const Text("Delete"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                )
                              ],
                            );
                          });
                      return;
                    case 2:
                      try {
                        await shareHomiletic(_thisHomiletic, _summaries,
                            _divisions, _applications);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("PDF shared successfully."),
                          action: SnackBarAction(
                            onPressed: () {},
                            label: "Ok",
                          ),
                        ));
                      } catch (error) {
                        sendError(error, "Share PDF");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              "Something went wrong sharing your PDF. Try again soon."),
                          action: SnackBarAction(
                            onPressed: () {},
                            label: "Ok",
                          ),
                        ));
                      }
                      return;
                    case 3:
                      try {
                        await printHomiletic(_thisHomiletic, _summaries,
                            _divisions, _applications);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("PDF printed successfully."),
                          action: SnackBarAction(
                            onPressed: () {},
                            label: "Ok",
                          ),
                        ));
                      } catch (error) {
                        sendError(error, "PDF print");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              "Something went wrong creating your PDF. Try again soon."),
                          action: SnackBarAction(
                            onPressed: () {},
                            label: "Ok",
                          ),
                        ));
                      }
                      return;
                    case 4:
                      showDialog(
                          context: context,
                          builder: ((context) => const PreferencesModal()));
                  }
                },
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => [
                      if (!kIsWeb)
                        const PopupMenuItem(
                            child: ListTile(
                                leading: Icon(Icons.save), title: Text("Save")),
                            value: 0),
                      if (!kIsWeb)
                        const PopupMenuItem(
                            child: ListTile(
                              title: Text('Delete'),
                              leading: Icon(Icons.delete),
                            ),
                            value: 1),
                      const PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text(kIsWeb ? 'Save to PDF' : 'Share'),
                        ),
                        value: 2,
                      ),
                      const PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.print),
                          title: Text('Print'),
                        ),
                        value: 3,
                      ),
                      if (!kIsWeb)
                        const PopupMenuItem(
                            child: ListTile(
                              title: Text('Preferences'),
                              leading: Icon(Icons.settings),
                            ),
                            value: 4),
                    ]),
          ],
        ),
        body: OrientationBuilder(
            builder: (context, orientation) => SafeArea(
                  bottom: false,
                  child: SplitView(
                      indicator: SplitIndicator(
                          viewMode: orientation != Orientation.landscape
                              ? SplitViewMode.Vertical
                              : SplitViewMode.Horizontal),
                      viewMode: orientation != Orientation.landscape
                          ? SplitViewMode.Vertical
                          : SplitViewMode.Horizontal,
                      children: orientation != Orientation.landscape
                          ? splitChildren
                          : splitChildren.reversed.toList()),
                )));
  }
}
