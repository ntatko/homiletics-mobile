import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/rounded_button.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
// import 'package:homiletics/storage/pdf_generation.dart';

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

  List<Widget> buildContentDivisionsList() {
    return _divisions
        .map(
          (e) => Row(
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
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: SizedBox(
            height: 80,
            child: RoundedButton(
              child: Center(
                  child: Row(children: const [
                Icon(Icons.search),
                SizedBox(
                    width: 100,
                    child: Text(
                      "Show passage",
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ))
              ])),
              onClick: () {
                if (_thisHomiletic.passage == '') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Please enter a passage"),
                    action: SnackBarAction(
                      onPressed: () {},
                      label: "Ok",
                    ),
                  ));
                } else {
                  showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0))),
                      context: context,
                      builder: (context) {
                        return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 3),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _thisHomiletic.passage,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: const Icon(Icons.close))
                                      ])),
                              Expanded(
                                  flex: 1,
                                  child: VerseContainer(
                                      passage: _thisHomiletic.passage))
                            ]);
                      });
                }
              },
            )),
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
                                  "Deleting this Homiletics lessson is permanent and cannot be undone. Are you sure you wish to proceed?"),
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
                                    }
                                  },
                                  child: const Text("Delete"),
                                  style: TextButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                )
                              ],
                            );
                          });
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
                          child: ListTile(
                              leading: Icon(Icons.save), title: Text("Save")),
                          value: 0),
                      const PopupMenuItem(
                          child: ListTile(
                            title: Text('Delete'),
                            leading: Icon(Icons.delete),
                          ),
                          value: 1),
                      // const PopupMenuItem(
                      //     child: ListTile(
                      //         title: Text("Save as PDF"),
                      //         leading: Icon(Icons.download)),
                      //     value: 2)
                    ]),
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
                      TextEditingController(text: _thisHomiletic.passage),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) async {
                    await _thisHomiletic.updatePassage(value);
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
                        "${index + 1}.",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Container(
                          width: 90,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: element.passage),
                              decoration: const InputDecoration(
                                labelText: 'Verses',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) async {
                                await element.updatePassage(value);
                                await _thisHomiletic.update();
                              })),
                      Expanded(
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: element.summary),
                              decoration: const InputDecoration(
                                labelText: 'Summary',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                              minLines: 1,
                              onChanged: (String value) async {
                                await element.updateText(value);
                                await _thisHomiletic.update();
                              }))
                    ],
                  ));
            }).toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoundedButton(
                    disabled: _summaries.isEmpty,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Icon(Icons.remove)),
                        Text('Remove')
                      ],
                    ),
                    onClick: () async {
                      try {
                        await _summaries[_summaries.length - 1].delete();
                        setState(() {
                          _summaries.removeLast();
                        });
                      } catch (error) {
                        print("Removing that Content Summary didn't work");
                      }
                    }),
                RoundedButton(
                    onClick: () {
                      setState(() {
                        _summaries.add(ContentSummary.blank(_thisHomiletic.id));
                      });
                    },
                    child: SizedBox(
                        width: 300,
                        child: Row(
                          children: const [
                            Padding(
                                padding: EdgeInsets.only(left: 0, right: 10),
                                child: Icon(Icons.add)),
                            Text('Content')
                          ],
                        ))),
              ],
            ),
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
                                labelText: 'Verses',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) async {
                                await _divisions[index].updatePassage(value);
                                await _thisHomiletic.update();
                              })),
                      Expanded(
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                                  TextEditingController(text: division.title),
                              decoration: const InputDecoration(
                                labelText: 'Division Sentence',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                              minLines: 1,
                              onChanged: (String value) async {
                                await division.updateText(value);
                                await _thisHomiletic.update();
                              }))
                    ],
                  ));
            }),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              RoundedButton(
                  disabled: _divisions.isEmpty,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Icon(Icons.remove)),
                      Text('Remove')
                    ],
                  ),
                  onClick: () async {
                    try {
                      await _divisions[_divisions.length - 1].delete();
                      setState(() {
                        _divisions.removeLast();
                      });
                    } catch (error) {
                      print("Removing that Division didn't work");
                    }
                  }),
              RoundedButton(
                  onClick: () {
                    setState(() {
                      _divisions.add(Division.blank(_thisHomiletic.id));
                    });
                  },
                  child: Row(
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(left: 0, right: 10),
                          child: Icon(Icons.add)),
                      Text('Division')
                    ],
                  )),
            ]),
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
                        text: _thisHomiletic.subjectSentence),
                    decoration: const InputDecoration(
                      hintText: 'Summarize: 10 words or fewer',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String ss) async {
                      await _thisHomiletic.updateSubjectSentence(ss);
                    })),
            const Divider(),
            const Text("Aim",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.all(8),
                child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    controller: TextEditingController(text: _thisHomiletic.aim),
                    decoration: const InputDecoration(
                      labelText: 'Cause the audience to learn that...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String aim) async {
                      await _thisHomiletic.updateAim(aim);
                    })),
            const Divider(),
            const Text("Application Questions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ..._applications.map((application) {
              // int index = _applications.indexOf(application);
              return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(8),
                  child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: TextEditingController(text: application.text),
                      decoration: const InputDecoration(
                        hintText: 'How can I...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) async {
                        await application.updateText(value);
                        await _thisHomiletic.update();
                      }));
            }),
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundedButton(
                          disabled: _applications.isEmpty,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Icon(Icons.remove)),
                              Text('Remove')
                            ],
                          ),
                          onClick: () async {
                            try {
                              await _applications[_applications.length - 1]
                                  .delete();
                              setState(() {
                                _applications.removeLast();
                              });
                            } catch (error) {
                              print("Removing that Application didn't work");
                            }
                          }),
                      RoundedButton(
                          onClick: () {
                            setState(() {
                              _applications
                                  .add(Application.blank(_thisHomiletic.id));
                            });
                          },
                          child: Row(
                            children: const [
                              Padding(
                                  padding: EdgeInsets.only(left: 0, right: 10),
                                  child: Icon(Icons.add)),
                              SizedBox(
                                  width: 90,
                                  child: Text(
                                    'Application',
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ))
                            ],
                          )),
                    ])),
            const HelpMenu()
          ],
        )));
  }
}
