import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';

class SummarySentenceCard extends StatelessWidget {
  final Homiletic homiletic;

  const SummarySentenceCard({Key? key, required this.homiletic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.yellow[100],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              const Text("Summary Sentence",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
