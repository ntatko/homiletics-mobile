import 'package:flutter/material.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';

class ContentSummariesCard extends StatefulWidget {
  final List<ContentSummary> contentSummaries;
  final Homiletic homiletic;
  final void Function() addContentSummary;
  final void Function() removeContentSummary;

  const ContentSummariesCard({
    Key? key,
    required this.contentSummaries,
    required this.homiletic,
    required this.addContentSummary,
    required this.removeContentSummary,
  }) : super(key: key);

  @override
  ContentSummariesCardState createState() => ContentSummariesCardState();
}

class ContentSummariesCardState extends State<ContentSummariesCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: MediaQuery.of(context).platformBrightness == Brightness.light
          ? Colors.blue[100]
          : Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Content Summaries",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Content Summaries"),
                            content: const Text(
                                "A content summary is a summary of a section of the bible. It doesn't need to be a sentence, it can also be more than one sentence. It should be a summary, in your own words, of the content of the passage.\nYou should have at least 10, but more than 20 content summaries. Generally, depending on the length of the passage, you will divide your passage into chunks of an approximate size to hit the 10-20 mark. So, if you passage is 30 verses, I'd try for 3 verses per content summary on average."),
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
            ...widget.contentSummaries.map((element) {
              return Container(
                margin: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 90,
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: TextField(
                        autofocus: true,
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
                          await widget.homiletic.update();
                        },
                      ),
                    ),
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
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                      setState(() {
                        widget.addContentSummary();
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 20),
                        const SizedBox(width: 4),
                        Text('(${widget.contentSummaries.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
