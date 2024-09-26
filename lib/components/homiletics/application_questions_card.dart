// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';

class ApplicationQuestionsCard extends StatelessWidget {
  List<Application> applications;
  final Homiletic homiletic;
  void Function() addApplication;
  Future<void> Function() removeApplication;

  ApplicationQuestionsCard(
      {Key? key,
      required this.applications,
      required this.homiletic,
      required this.addApplication,
      required this.removeApplication})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.grey[200]
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Application Questions",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Application Questions"),
                                  content: const Text(
                                    "These are questions that help the audience apply what they've just heard to their own lives. They should be specific, personal, open-ended, and thought-provoking.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ]),
              ),
              ...applications.map((application) {
                // int index = _applications.indexOf(application);
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(8),
                    child: TextField(
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller:
                            TextEditingController(text: application.text),
                        decoration: const InputDecoration(
                          hintText: 'How can I...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) {
                          addApplication();
                          // setState(() {
                          //   _applications
                          //       .add(Application.blank(_thisHomiletic.id));
                          // });
                        },
                        onChanged: (value) async {
                          await application.updateText(value);
                          await homiletic.update();
                        }));
              }).toList(),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                      ),
                      onPressed: applications.isNotEmpty
                          ? () async {
                              try {
                                removeApplication();
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
                                sendError(error, "Remove application");
                              }
                            }
                          : null,
                      child: const Icon(Icons.delete),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () {
                        addApplication();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 4),
                          Text('(${applications.length})'),
                        ],
                      ),
                    ),
                  ])),
            ])));
  }
}
