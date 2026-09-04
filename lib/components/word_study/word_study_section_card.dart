import 'package:flutter/material.dart';

class WordStudySectionCard extends StatelessWidget {
  final String title;
  final String helpText;
  final String hint;
  final TextEditingController controller;
  final Future<void> Function(String) onChanged;
  final Color lightColor;
  final int minLines;
  final List<Widget>? actions;
  final FocusNode? focusNode;

  const WordStudySectionCard({
    Key? key,
    required this.title,
    required this.helpText,
    required this.hint,
    required this.controller,
    required this.onChanged,
    required this.lightColor,
    this.minLines = 3,
    this.actions,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: MediaQuery.of(context).platformBrightness == Brightness.light
            ? lightColor
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(title),
                            content: Text(helpText),
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
              if (actions != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                  child: Wrap(spacing: 8, runSpacing: 8, children: actions!),
                ),
              Container(
                  margin: const EdgeInsets.all(8),
                  child: TextField(
                      focusNode: focusNode,
                      maxLines: null,
                      minLines: minLines,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (String value) async {
                        await onChanged(value);
                      })),
            ])));
  }
}
