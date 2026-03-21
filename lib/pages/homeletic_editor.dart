import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/homiletics/aim_card.dart';
import 'package:homiletics/components/homiletics/application_questions_card.dart';
import 'package:homiletics/components/homiletics/content_summaries_card.dart';
import 'package:homiletics/components/homiletics/divisions_card.dart';
import 'package:homiletics/components/homiletics/fcf_card.dart';
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
  late TextEditingController _fcfController;
  String _translationVersion = 'web';
  final GlobalKey<VerseContainerState> _verseContainerKey =
      GlobalKey<VerseContainerState>();
  int _buildCount = 0;

  void _editorLog(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'homiletics.editor',
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[homiletics.editor] $message${error != null ? ' | $error' : ''}');
  }

  @override
  void initState() {
    super.initState();
    _thisHomiletic = widget.homiletic ?? Homiletic();
    _translationVersion = Preferences.preferredVersion;
    _fcfController = TextEditingController(text: _thisHomiletic.fcf);
    _editorLog(
      'initState: id=${_thisHomiletic.id} uuid=${_thisHomiletic.uuid ?? "(new)"} '
      'passage="${_thisHomiletic.passage}"',
    );
    prepTheTable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if translation preference has changed and reload if needed
    final currentTranslation = Preferences.preferredVersion;
    if (currentTranslation != _translationVersion) {
      _editorLog(
        'didChangeDependencies: translation changed '
        '$_translationVersion -> $currentTranslation',
      );
      setState(() {
        _translationVersion = currentTranslation;
      });
      // Reload the verse container with new translation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verseContainerKey.currentState?.reloadPassage();
      });
    }
  }

  @override
  void dispose() {
    _editorLog('dispose: id=${_thisHomiletic.id} uuid=${_thisHomiletic.uuid}');
    _fcfController.dispose();
    super.dispose();
  }

  prepTheTable() async {
    final startedAt = DateTime.now();
    _editorLog('prepTheTable: start');
    await _thisHomiletic.update();
    _editorLog('prepTheTable: homiletic updated id=${_thisHomiletic.id}');
    List<ContentSummary> savedSummaries =
        await getSummariesByHomileticId(_thisHomiletic.id);
    if (savedSummaries.length > 200) {
      _editorLog(
        'prepTheTable: detected suspicious summary count '
        '${savedSummaries.length}, deduping',
      );
      savedSummaries =
          await dedupeSummariesByHomileticId(_thisHomiletic.id);
      _editorLog(
        'prepTheTable: dedupe complete, summaries=${savedSummaries.length}',
      );
    }
    List<Division> savedDivisions =
        await getDivisionsByHomileticId(_thisHomiletic.id);
    List<Application> savedApplications =
        await getApplicationsByHomileticId(_thisHomiletic.id);
    _editorLog(
      'prepTheTable: loaded summaries=${savedSummaries.length} '
      'divisions=${savedDivisions.length} applications=${savedApplications.length}',
    );

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
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    _editorLog('prepTheTable: setState complete (${elapsedMs}ms)');
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    if (_buildCount <= 5 || _buildCount % 20 == 0) {
      _editorLog(
        'build#$_buildCount: summaries=${_summaries.length} '
        'divisions=${_divisions.length} applications=${_applications.length}',
      );
    }
    List<Widget> splitChildren = [
      ListView(
        padding: const EdgeInsets.all(5),
        children: [
          ContentSummariesCard(
              contentSummaries: _summaries,
              homiletic: _thisHomiletic,
              addContentSummary: () {
                _summaries.add(
                  ContentSummary.blank(_thisHomiletic.id)
                    ..sort = _summaries.length,
                );
              },
              removeContentSummary: () async {
                await _summaries[_summaries.length - 1].delete();
                setState(() {
                  _summaries.removeLast();
                });
                await updateSummarySortOrder(_thisHomiletic.id, _summaries);
              },
              reorderContentSummaries: (reordered) async {
                setState(() {
                  _summaries = reordered;
                });
                await updateSummarySortOrder(_thisHomiletic.id, _summaries);
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
          FcfCard(homiletic: _thisHomiletic),
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
          key: _verseContainerKey,
          passage: _thisHomiletic.passage,
          translation: Preferences.translation)
    ];

    return Scaffold(
        // resizeToAvoidBottomInset: false,
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
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text("Delete"),
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
                  }
                },
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => [
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: 0,
                          child: ListTile(
                              leading: Icon(Icons.save), title: Text("Save")),
                        ),
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            title: Text('Delete'),
                            leading: Icon(Icons.delete),
                          ),
                        ),
                      const PopupMenuItem(
                        value: 2,
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text(kIsWeb ? 'Save to PDF' : 'Share'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 3,
                        child: ListTile(
                          leading: Icon(Icons.print),
                          title: Text('Print'),
                        ),
                      ),
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: 4,
                          child: ListTile(
                            title: Text('Preferences'),
                            leading: Icon(Icons.settings),
                          ),
                        ),
                    ]),
          ],
        ),
        body: SafeArea(
            child: OrientationBuilder(
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
                    ))));
  }
}
