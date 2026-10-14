import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';

class ApplicationQuestionsCard extends StatefulWidget {
  final List<Application> applications;
  final Homiletic homiletic;
  final VoidCallback addApplication;
  final Future<void> Function(Application application) removeApplication;

  const ApplicationQuestionsCard(
      {Key? key,
      required this.applications,
      required this.homiletic,
      required this.addApplication,
      required this.removeApplication})
      : super(key: key);

  @override
  State<ApplicationQuestionsCard> createState() =>
      _ApplicationQuestionsCardState();
}

class _ApplicationQuestionsCardState extends State<ApplicationQuestionsCard> {
  final RowControllers<Application> _controllers = RowControllers<Application>(
      (application) => [TextEditingController(text: application.text)]);
  final RowRemover _remover = RowRemover();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _add() {
    _controllers.focusNextNewRow();
    widget.addApplication();
  }

  Future<void> _remove(Application application) {
    return _remover.remove(
      context,
      hasText: _controllers.of(application)[0].text.trim().isNotEmpty,
      rowName: 'application question',
      remove: () => widget.removeApplication(application),
      failureMessage: "Removing that Application didn't work",
      errorIdentifier: "Remove application",
    );
  }

  @override
  Widget build(BuildContext context) {
    _controllers.retainOnly(widget.applications);
    return Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[200]
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Application Questions",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Application Questions"),
                                  content: const Text(
                                    "These are questions that help the audience apply what they've just heard to their own lives. They should be specific, personal, open-ended, and thought-provoking.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ]),
              ),
              ...widget.applications.map((application) {
                return Container(
                    key: ObjectKey(application),
                    margin: const EdgeInsets.all(8),
                    child: Row(children: [
                      Expanded(
                          child: TextField(
                              autofocus:
                                  _controllers.shouldAutofocus(application),
                              maxLines: null,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              controller: _controllers.of(application)[0],
                              decoration: const InputDecoration(
                                hintText: 'How can I...',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _add(),
                              onChanged: (value) async {
                                await application.updateText(value);
                                await widget.homiletic.update();
                              })),
                      IconButton(
                        tooltip: 'Remove application question',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(application),
                      ),
                    ]));
              }),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: _add,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 4),
                          Text('(${widget.applications.length})'),
                        ],
                      ),
                    ),
                  ])),
            ])));
  }
}
