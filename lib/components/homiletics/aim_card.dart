import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';

class AimCard extends StatelessWidget {
  final Homiletic homiletic;

  const AimCard({Key? key, required this.homiletic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.red[100],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              const Text("Aim",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
