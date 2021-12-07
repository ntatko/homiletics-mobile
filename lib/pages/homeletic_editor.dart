import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/passage.dart';
import 'package:homiletics/common/rounded_button.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:reorderables/reorderables.dart';

class HomileticEditor extends StatefulWidget {
  const HomileticEditor({Key? key, this.homiletic}) : super(key: key);

  final Homiletic? homiletic;

  @override
  State<HomileticEditor> createState() => _HomileticState();
}

class _HomileticState extends State<HomileticEditor> {
  Homiletic? _thisHomiletic;
  List<ContentSummary> _summaries = [];
  List<Division> _divisions = [];
  List<Application> _applications = [];
  List<Passage> _passages = [];

  @override
  void initState() {
    super.initState();
    prepTheTable();
  }

  prepTheTable() async {
    if (widget.homiletic != null) {
      List<ContentSummary> summaries =
          await getSummariesByHomileticId(widget.homiletic?.id);
      List<Division> divisions =
          await getDivisionsByHomileticId(widget.homiletic?.id);
      List<Application> applications =
          await getApplicationsByHomileticId(widget.homiletic?.id);
      setState(() {
        _summaries = summaries;
        _divisions = divisions;
        _applications = applications;
        _thisHomiletic = widget.homiletic;
      });
    } else {
      setState(() {
        _thisHomiletic = Homiletic();
        _thisHomiletic?.passage = '';
      });
      await _thisHomiletic?.update();
      setState(() {
        _summaries.add(ContentSummary.blank(_thisHomiletic?.id ?? -1));
        for (var element in _summaries) {
          element.update();
        }
        _divisions.add(Division.blank(_thisHomiletic?.id ?? -1));
        for (var element in _divisions) {
          element.update();
        }
        _applications.add(Application.blank(_thisHomiletic?.id ?? -1));
        for (var element in _applications) {
          element.update();
        }
      });
    }
  }

  fetchPassages(String reference) async {
    List<Passage> passage = await fetchPassage(reference);
    _passages = passage;
  }

  List<Widget> buildContentDivisionsList() {
    return _divisions
        .map((e) => Container(
              key: Key("${e.order}"),
              child: Row(
                children: [
                  Text("${_divisions.indexOf(e) + 1}"),
                  TextField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: TextEditingController(text: e.title),
                    decoration: const InputDecoration(
                      labelText: 'Division Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) async {
                      await e.updateText(value);
                    },
                  )
                ],
              ),
            ))
        .toList();
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
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (r) => false);
              },
            ),
          ],
        ),
        body: Center(
            child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text("Passage",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.all(8),
                child: TextField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller:
                      TextEditingController(text: _thisHomiletic?.passage),
                  decoration: const InputDecoration(
                    labelText: 'Genesis 1:1-15',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) async {
                    await _thisHomiletic?.updatePassage(value);
                  },
                )),
            SizedBox(
                width: 150,
                child: RoundedButton(
                    onClick: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return VerseContainer(
                                passage: _thisHomiletic?.passage ?? '');
                          });
                    },
                    child: Center(
                        child: Row(children: const [
                      Icon(Icons.search),
                      Text("Show passage")
                    ])))),
            // const Divider(),
            // const Text("Content List",
            //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // SizedBox(
            //     width: MediaQuery.of(context).size.width,
            //     height: 40 *
            //         (_summaries.length.toDouble() +
            //             _divisions.length.toDouble()),
            //     child: ReorderableColumn(
            //         children: () {
            //           List<Widget> contentSumWidgets =
            //               _summaries.map((summary) {
            //             return SizedBox(
            //                 key: Key("${summary.id}"),
            //                 height: 40,
            //                 width: MediaQuery.of(context).size.width,
            //                 child: Row(
            //                   children: [
            //                     SizedBox(
            //                         child: Text(
            //                             "${_summaries.indexOf(summary) + 1}:")),
            //                     SizedBox(
            //                         width: 75,
            //                         child: TextField(
            //                             keyboardType: TextInputType.number,
            //                             textCapitalization:
            //                                 TextCapitalization.sentences,
            //                             controller: TextEditingController(
            //                                 text: summary.passage),
            //                             decoration: const InputDecoration(
            //                               labelText: 'Verses',
            //                               border: OutlineInputBorder(),
            //                             ),
            //                             onChanged: (String value) {
            //                               summary.updatePassage(value);
            //                             })),
            //                     Container(
            //                         padding: const EdgeInsets.only(left: 5),
            //                         width: 250,
            //                         child: TextField(
            //                             keyboardType: TextInputType.text,
            //                             textCapitalization:
            //                                 TextCapitalization.sentences,
            //                             controller: TextEditingController(
            //                                 text: summary.summary),
            //                             decoration: const InputDecoration(
            //                               labelText: 'Summary',
            //                               border: OutlineInputBorder(),
            //                             ),
            //                             onChanged: (String value) async {
            //                               await summary.updateText(value);
            //                             }))
            //                   ],
            //                 ));
            //           }).toList();

            //           return contentSumWidgets;
            //         }(),
            //         onReorder: (_, __) {})),
            // // Container(child: Column(
            // //     // onReorder: (int oldIndex, int newIndex) {},
            // //     children: [])), //buildContentDivisionsList())),
            // Container(
            //     child: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     RoundedButton(
            //         child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             children: const [
            //               Icon(Icons.add),
            //               Text("Add Division")
            //             ]),
            //         onClick: () {
            //           setState(() {
            //             _divisions
            //                 .add(Division.blank(_thisHomiletic?.id ?? -1));
            //           });
            //         }),
            //     RoundedButton(
            //         child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             children: const [Icon(Icons.add), Text("Add Summary")]),
            //         onClick: () {
            //           setState(() {
            //             _summaries.add(
            //                 ContentSummary.blank(_thisHomiletic?.id ?? -1));
            //           });
            //         })
            //   ],
            // )),
            const Text("Content Summaries",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._summaries.map((element) {
              int index = _summaries.indexOf(element);
              return Dismissible(
                  key: Key(index.toString()),
                  onDismissed: (_) {
                    _summaries = _summaries..removeAt(index);
                    element.delete();
                  },
                  child: Container(
                      margin: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${index + 1}:",
                            style: const TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                              width: 75,
                              child: TextField(
                                  keyboardType: TextInputType.number,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: TextEditingController(
                                      text: element.passage),
                                  decoration: const InputDecoration(
                                    labelText: 'Verses',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String value) {
                                    element.updatePassage(value);
                                  })),
                          SizedBox(
                              width: 250,
                              child: TextField(
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: TextEditingController(
                                      text: element.summary),
                                  decoration: const InputDecoration(
                                    labelText: 'Summary',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String value) async {
                                    await element.updateText(value);
                                  }))
                        ],
                      )));
            }).toList(),
            RoundedButton(
                onClick: () {
                  setState(() {
                    _summaries
                        .add(ContentSummary.blank(_thisHomiletic?.id ?? -1));
                  });
                },
                child: Row(
                  children: const [
                    Icon(Icons.add),
                    Text('Add Content Summary')
                  ],
                )),
            const Divider(),
            const Text("Divisions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._divisions.map((division) {
              int index = _divisions.indexOf(division);
              return Dismissible(
                  key: Key(division.toString()),
                  onDismissed: (_) {
                    division.delete();
                    _thisHomiletic?.update();
                    setState(() {
                      _divisions = _divisions..remove(division);
                    });
                  },
                  child: Container(
                      margin: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${index + 1}:",
                            style: const TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                              width: 75,
                              child: TextField(
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: TextEditingController(
                                      text: division.passage),
                                  decoration: const InputDecoration(
                                    labelText: 'Verses',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String value) async {
                                    await _divisions[index]
                                        .updatePassage(value);
                                  })),
                          SizedBox(
                              width: 250,
                              child: TextField(
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: TextEditingController(
                                      text: division.title),
                                  decoration: const InputDecoration(
                                    labelText: 'Division Title',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String value) async {
                                    await division.updateText(value);
                                  }))
                        ],
                      )));
            }),
            RoundedButton(
                onClick: () {
                  setState(() {
                    _divisions.add(Division.blank(_thisHomiletic?.id ?? -1));
                  });
                },
                child: Row(
                  children: const [Icon(Icons.add), Text('Add Division')],
                )),
            const Divider(),
            const Text("Summary Sentence",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.all(8),
                child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: TextEditingController(
                        text: _thisHomiletic?.subjectSentence ?? ''),
                    decoration: const InputDecoration(
                      labelText: '10 words or fewer, please XD',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String ss) async {
                      await _thisHomiletic?.updateSubjectSentence(ss);
                    })),
            const Divider(),
            const Text("Aim",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.all(8),
                child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller:
                        TextEditingController(text: _thisHomiletic?.aim ?? ''),
                    decoration: const InputDecoration(
                      labelText: 'Cause the audience to learn that...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String ss) async {
                      await _thisHomiletic?.updateAim(ss);
                    })),
            const Divider(),
            const Text("Application Questions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._applications.map((application) {
              // int index = _applications.indexOf(application);
              return Dismissible(
                  key: Key(application.toString()),
                  onDismissed: (_) {
                    application.delete();
                    setState(() {
                      _applications = _applications..remove(application);
                    });
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.all(8),
                      child: TextField(
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller:
                              TextEditingController(text: application.text),
                          decoration: const InputDecoration(
                            labelText: 'How can I...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) async {
                            await application.updateText(value);
                          })));
            }),
            RoundedButton(
                onClick: () {
                  setState(() {
                    _applications
                        .add(Application.blank(_thisHomiletic?.id ?? -1));
                  });
                },
                child: Row(
                  children: const [Icon(Icons.add), Text('Add Application')],
                )),
          ],
        )));
  }
}
