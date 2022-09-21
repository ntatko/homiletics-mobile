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
        color: Colors.green[100],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              const Text("Divisions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ...divisions.map((division) {
                int index = divisions.indexOf(division);
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
                                  await divisions[index].updatePassage(value);
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
              Wrap(
                  spacing: 20,
                  runSpacing: 0,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Icon(Icons.remove)),
                            Text('Remove')
                          ],
                        ),
                        onPressed: divisions.isNotEmpty
                            ? () async {
                                try {
                                  await removeDivision();
                                  // await _divisions[_divisions.length - 1].delete();
                                  // setState(() {
                                  //   _divisions.removeLast();
                                  // });
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
                            : null),
                    ElevatedButton(
                        onPressed: () {
                          addDivision();
                          // setState(() {
                          //   _divisions.add(Division.blank(_thisHomiletic.id));
                          // });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Padding(
                                padding: EdgeInsets.only(left: 0, right: 10),
                                child: Icon(Icons.add)),
                            Text('Division')
                          ],
                        )),
                  ]),
            ])));
  }
}
