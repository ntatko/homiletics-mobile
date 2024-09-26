// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';

class DivisionsCard extends StatelessWidget {
  List<Division> divisions;
  final Homiletic homiletic;
  void Function() addDivision;
  Future<void> Function() removeDivision;

  DivisionsCard(
      {Key? key,
      required this.divisions,
      required this.homiletic,
      required this.addDivision,
      required this.removeDivision})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.green[100]
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Divisions",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Divisions"),
                              content: const Text(
                                  "Divisions are groupings of verses that are related. There should be at least two and no more than four."),
                              actions: [
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              ...divisions.map((division) {
                return Container(
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                  await divisions[divisions.indexOf(division)]
                                      .updatePassage(value);
                                  await homiletic.update();
                                })),
                        Expanded(
                            child: TextField(
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller:
                                    TextEditingController(text: division.title),
                                onSubmitted: (_) {
                                  addDivision();
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Division Sentence',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 4,
                                minLines: 1,
                                onChanged: (String value) async {
                                  await division.updateText(value);
                                  await homiletic.update();
                                }))
                      ],
                    ));
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                      ),
                      onPressed: divisions.isNotEmpty
                          ? () async {
                              try {
                                await removeDivision();
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
                                sendError(error, "Remove Divisions");
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
                        addDivision();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 4),
                          Text('(${divisions.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
