import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';

class FcfCard extends StatelessWidget {
  final Homiletic homiletic;

  const FcfCard({Key? key, required this.homiletic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: const Color.fromARGB(255, 196, 255, 241),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("FCF",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("FCF"),
                            content: const Text(
                                "The FCF (Fallen Condition Focus) is the part of humanity that is the most illustrated or referenced in the passage. It is the condition that the audience is in, the reason that the audience needs to be saved."),
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
                      controller: TextEditingController(text: homiletic.fcf),
                      decoration: const InputDecoration(
                        hintText: 'Fallen/Frail/Feeble/Fickle',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String ss) async {
                        await homiletic.updateFcf(ss);
                      })),
            ])));
  }
}
