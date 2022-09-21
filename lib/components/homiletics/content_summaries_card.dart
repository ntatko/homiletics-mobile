import 'package:flutter/material.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';

class ContentSummariesCard extends StatefulWidget {
  final List<ContentSummary> contentSummaries;
  final Homiletic homiletic;
  final void Function() addContentSummary;
  final void Function() removeContentSummary;

  const ContentSummariesCard(
      {Key? key,
      required this.contentSummaries,
      required this.homiletic,
      required this.addContentSummary,
      required this.removeContentSummary})
      : super(key: key);

  @override
  _ContentSummariesCardState createState() => _ContentSummariesCardState();
}

class _ContentSummariesCardState extends State<ContentSummariesCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.blue[100],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              const Text("Content Summaries",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ...widget.contentSummaries.map((element) {
                int index = widget.contentSummaries.indexOf(element);
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
                                  await element.updatePassage(value);
                                  await widget.homiletic.update();
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
                                    widget.addContentSummary();
                                  });
                                },
                                maxLines: 4,
                                minLines: 1,
                                onChanged: (String value) async {
                                  await element.updateText(value);
                                  await widget.homiletic.update();
                                }))
                      ],
                    ));
              }).toList(),
              Wrap(
                spacing: 20,
                runSpacing: 0,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Icon(Icons.remove)),
                          Text('Remove')
                        ],
                      ),
                      onPressed: widget.contentSummaries.isNotEmpty
                          ? () async {
                              try {
                                widget.removeContentSummary();
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
                                sendError(error, "Content Summary removal");
                              }
                            }
                          : null),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.addContentSummary();
                          // widget.contentSummaries.add(ContentSummary.blank(
                          //     _thisHomiletic.id));
                        });
                      },
                      child: SizedBox(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.add)),
                          Text('Content')
                        ],
                      ))),
                ],
              ),
            ])));
  }
}
