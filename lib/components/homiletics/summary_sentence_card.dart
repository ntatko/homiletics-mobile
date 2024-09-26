import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';

class SummarySentenceCard extends StatelessWidget {
  final Homiletic homiletic;

  const SummarySentenceCard({Key? key, required this.homiletic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.yellow[100]
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Summary Sentence",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Summary Sentence"),
                            content: const Text(
                                "The Summary Sentence is a concise, memorable statement that encapsulates the most relevant facts. A good way of thinking of it is the 2am test: if someone were to wake you up at 2am and ask you what the sermon was about, what would you say? You'd say the Summary Sentence.\nIt should be 10 words or fewer. If you're feeling frisky, you can try to make an alliteration."),
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
              Container(
                  margin: const EdgeInsets.all(8),
                  child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: TextEditingController(
                          text: homiletic.subjectSentence),
                      decoration: const InputDecoration(
                        hintText: 'Summarize: 10 words or fewer',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String ss) async {
                        await homiletic.updateSubjectSentence(ss);
                      })),
            ])));
  }
}
