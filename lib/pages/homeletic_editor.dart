import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:matomo/matomo.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:homiletics/storage/pdf_generation.dart';

class HomileticEditor extends TraceableStatefulWidget {
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
  bool _isTrayOpen = false;
  String _translationVersion = 'web';
  final PanelController _controller = PanelController();

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
        appBar: AppBar(
          title: const Text('Homiletics'),
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
                                    primary: Colors.red,
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
                    ]),
          ],
        ),
        body: SlidingUpPanel(
            controller: _controller,
            backdropTapClosesPanel: true,
            minHeight: 75,
            // panelSnapping: false,
            backdropEnabled: true,
            parallaxEnabled: false,
            isDraggable: true,
            borderRadius: BorderRadius.circular(15),
            onPanelClosed: () {
              setState(() {
                _isTrayOpen = false;
              });
            },
            onPanelSlide: (height) {
              if (height > 0 && !_isTrayOpen) {
                setState(() {
                  _isTrayOpen = true;
                });
              }
            },
            onPanelOpened: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                _isTrayOpen = true;
              });
            },
            collapsed: Column(children: [
              Container(
                  padding: const EdgeInsets.only(top: 7),
                  child: Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(300)),
                    ),
                  )),
              SizedBox(
                  height: 60,
                  child: Row(children: [
                    Container(
                        width: MediaQuery.of(context).size.width - 100,
                        margin: const EdgeInsets.all(8),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller: TextEditingController(
                              text: _thisHomiletic.passage),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (String value) async {
                            await _thisHomiletic.updatePassage(value);
                          },
                        )),
                    SizedBox(
                      width: 75,
                      child: DropdownButton(
                        items: [
                          ...bibleTranslations
                              .map((e) => DropdownMenuItem(
                                    child: Text(
                                      e.short,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: e.code,
                                  ))
                              .toList()
                        ],
                        onChanged: (version) {
                          setState(() {
                            _translationVersion = version.toString();
                          });
                        },
                        value: _translationVersion,
                      ),
                    )
                  ])),
            ]),
            panel: Column(children: [
              GestureDetector(
                  onTap: () {
                    _controller.close();
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 7, bottom: 12),
                      child: Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(300)),
                        ),
                      ))),
              VerseContainer(
                  passage: _thisHomiletic.passage,
                  controller: _controller,
                  version: _translationVersion)
            ]),
            body: SafeArea(
                child: Center(
                    child: ListView(
              padding: const EdgeInsets.all(5),
              children: [
                Card(
                    color: Colors.blue[100],
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Text("Content Summaries",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          ..._summaries.map((element) {
                            int index = _summaries.indexOf(element);
                            return Container(
                                margin: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${index + 1}.",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Container(
                                        width: 90,
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: TextField(
                                            autofocus: true,
                                            keyboardType: TextInputType.text,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: TextEditingController(
                                                text: element.passage),
                                            decoration: const InputDecoration(
                                              labelText: 'Verses',
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (String value) async {
                                              await element
                                                  .updatePassage(value);
                                              await _thisHomiletic.update();
                                            })),
                                    Expanded(
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
                                            onSubmitted: (_) {
                                              setState(() {
                                                _summaries.add(
                                                    ContentSummary.blank(
                                                        _thisHomiletic.id));
                                              });
                                            },
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
                              ElevatedButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: const [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Icon(Icons.remove)),
                                      Text('Remove')
                                    ],
                                  ),
                                  onPressed: _summaries.isNotEmpty
                                      ? () async {
                                          try {
                                            await _summaries[
                                                    _summaries.length - 1]
                                                .delete();
                                            setState(() {
                                              _summaries.removeLast();
                                            });
                                          } catch (error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: const Text(
                                                  "Removing that Content Summary didn't work"),
                                              action: SnackBarAction(
                                                onPressed: () {},
                                                label: "Ok",
                                              ),
                                            ));
                                            sendError(error,
                                                "Content Summary removal");
                                          }
                                        }
                                      : null),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _summaries.add(ContentSummary.blank(
                                          _thisHomiletic.id));
                                    });
                                  },
                                  child: SizedBox(
                                      child: Row(
                                    children: const [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 0, right: 10),
                                          child: Icon(Icons.add)),
                                      Text('Content')
                                    ],
                                  ))),
                            ],
                          ),
                        ]))),
                const SizedBox(height: 20),
                Card(
                    color: Colors.green[100],
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Text("Divisions",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          ..._divisions.map((division) {
                            int index = _divisions.indexOf(division);
                            return Container(
                                margin: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${index + 1}:",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(
                                        width: 75,
                                        child: TextField(
                                            autofocus: true,
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
                                              await _thisHomiletic.update();
                                            })),
                                    Expanded(
                                        child: TextField(
                                            keyboardType: TextInputType.text,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: TextEditingController(
                                                text: division.title),
                                            onSubmitted: (_) {
                                              setState(() {
                                                _divisions.add(Division.blank(
                                                    _thisHomiletic.id));
                                              });
                                            },
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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Icon(Icons.remove)),
                                        Text('Remove')
                                      ],
                                    ),
                                    onPressed: _divisions.isNotEmpty
                                        ? () async {
                                            try {
                                              await _divisions[
                                                      _divisions.length - 1]
                                                  .delete();
                                              setState(() {
                                                _divisions.removeLast();
                                              });
                                            } catch (error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: const Text(
                                                    "Removing that Division didn't work"),
                                                action: SnackBarAction(
                                                  onPressed: () {},
                                                  label: "Ok",
                                                ),
                                              ));
                                              sendError(
                                                  error, "Remove Divisions");
                                            }
                                          }
                                        : null),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _divisions.add(
                                            Division.blank(_thisHomiletic.id));
                                      });
                                    },
                                    child: Row(
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 0, right: 10),
                                            child: Icon(Icons.add)),
                                        Text('Division')
                                      ],
                                    )),
                              ]),
                        ]))),
                const SizedBox(height: 20),
                Card(
                    color: Colors.yellow[100],
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Text("Summary Sentence",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Container(
                              margin: const EdgeInsets.all(8),
                              child: TextField(
                                  maxLines: null,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: TextEditingController(
                                      text: _thisHomiletic.subjectSentence),
                                  decoration: const InputDecoration(
                                    hintText: 'Summarize: 10 words or fewer',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String ss) async {
                                    await _thisHomiletic
                                        .updateSubjectSentence(ss);
                                  })),
                        ]))),
                const SizedBox(height: 20),
                Card(
                    color: Colors.red[100],
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Text("Aim",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Container(
                              margin: const EdgeInsets.all(8),
                              child: TextField(
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: TextEditingController(
                                      text: _thisHomiletic.aim),
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Cause the audience to learn that...',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String aim) async {
                                    await _thisHomiletic.updateAim(aim);
                                  })),
                        ]))),
                const SizedBox(height: 20),
                Card(
                    color: Colors.grey[200],
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Text("Application Questions",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          ..._applications.map((application) {
                            // int index = _applications.indexOf(application);
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.all(8),
                                child: TextField(
                                    autofocus: true,
                                    maxLines: null,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: TextEditingController(
                                        text: application.text),
                                    decoration: const InputDecoration(
                                      hintText: 'How can I...',
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (_) {
                                      setState(() {
                                        _applications.add(Application.blank(
                                            _thisHomiletic.id));
                                      });
                                    },
                                    onChanged: (value) async {
                                      await application.updateText(value);
                                      await _thisHomiletic.update();
                                    }));
                          }),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: const [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Icon(Icons.remove)),
                                            Text('Remove')
                                          ],
                                        ),
                                        onPressed: _applications.isNotEmpty
                                            ? () async {
                                                try {
                                                  await _applications[
                                                          _applications.length -
                                                              1]
                                                      .delete();
                                                  setState(() {
                                                    _applications.removeLast();
                                                  });
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: const Text(
                                                        "Removing that Application didn't work"),
                                                    action: SnackBarAction(
                                                      onPressed: () {},
                                                      label: "Ok",
                                                    ),
                                                  ));
                                                  sendError(error,
                                                      "Remove applicatoin");
                                                }
                                              }
                                            : null),
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _applications.add(Application.blank(
                                                _thisHomiletic.id));
                                          });
                                        },
                                        child: Row(
                                          children: const [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: 0, right: 10),
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
                        ]))),
                const HelpMenu(),
                SizedBox(
                  height: 150 + MediaQuery.of(context).viewInsets.bottom,
                )
              ],
            )))));
  }
}
