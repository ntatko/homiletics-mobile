import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';

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
      });
      await _thisHomiletic?.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Homiletics'),
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
            const Divider(),
            const Text("Content Summaries",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._summaries.map((element) {
              int index = _summaries.indexOf(element);
              return Container(
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
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: element.passage),
                              decoration: const InputDecoration(
                                labelText: 'Verses',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) async {
                                await element.updatePassage(value);
                              })),
                      SizedBox(
                          width: 250,
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: element.summary),
                              decoration: const InputDecoration(
                                labelText: 'Summary',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) async {
                                await element.updateText(value);
                              }))
                    ],
                  ));
            }).toList(),
            TextButton(
                onPressed: () {
                  setState(() {
                    _summaries
                        .add(ContentSummary.blank(_thisHomiletic?.id ?? -1));
                  });
                },
                child: const Text("Add Content Summary")),
            const Divider(),
            const Text("Divisions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._divisions.map((division) {
              int index = _divisions.indexOf(division);
              return Container(
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
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: division.passage),
                              decoration: const InputDecoration(
                                labelText: 'Verse Range',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) async {
                                await _divisions[index].updatePassage(value);
                              })),
                      SizedBox(
                          width: 250,
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: division.title),
                              decoration: const InputDecoration(
                                labelText: 'Division Title',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) async {
                                await division.updateText(value);
                              }))
                    ],
                  ));
            }),
            TextButton(
                onPressed: () {
                  setState(() {
                    _divisions.add(Division.blank(_thisHomiletic?.id ?? -1));
                  });
                },
                child: const Text("Add Division")),
            const Divider(),
            const Text("Summary Sentence",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.all(8),
                child: TextField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: TextEditingController(
                        text: _thisHomiletic?.subjectSentence ?? ''),
                    decoration: const InputDecoration(
                      labelText: '10 words or less, please XD',
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
            const Text("Aplication Questions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._applications.map((application) {
              // int index = _applications.indexOf(application);
              return Container(
                  margin: const EdgeInsets.all(8),
                  child: TextField(
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: TextEditingController(text: application.text),
                      decoration: const InputDecoration(
                        labelText: 'How can I...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) async {
                        await application.updateText(value);
                      }));
            }),
            TextButton(
                onPressed: () {
                  setState(() {
                    _applications
                        .add(Application.blank(_thisHomiletic?.id ?? -1));
                  });
                },
                child: const Text("Add Content Summary")),
          ],
        )));
  }
}
