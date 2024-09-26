import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';

class AimCard extends StatelessWidget {
  final Homiletic homiletic;

  const AimCard({Key? key, required this.homiletic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.red[100]
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Aim",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Aim"),
                            content: const Text(
                              "The Aim is the key point, the one main takeaway truth you want yourself or an audience to walk away with. It may be derivable from the FCF, and will likely influence the Application Questions.",
                            ),
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
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      controller: TextEditingController(text: homiletic.aim),
                      decoration: const InputDecoration(
                        labelText: 'Cause the audience to learn that...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String aim) async {
                        await homiletic.updateAim(aim);
                      })),
            ])));
  }
}
