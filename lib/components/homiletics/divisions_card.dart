import 'package:flutter/material.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/components/homiletics/row_controllers.dart';

class DivisionsCard extends StatefulWidget {
  final List<Division> divisions;
  final Homiletic homiletic;
  final VoidCallback addDivision;
  final Future<void> Function(Division division) removeDivision;

  const DivisionsCard(
      {Key? key,
      required this.divisions,
      required this.homiletic,
      required this.addDivision,
      required this.removeDivision})
      : super(key: key);

  @override
  State<DivisionsCard> createState() => _DivisionsCardState();
}

class _DivisionsCardState extends State<DivisionsCard> {
  /// Per row: [verses, title].
  final RowControllers<Division> _controllers =
      RowControllers<Division>((division) => [
            TextEditingController(text: division.passage),
            TextEditingController(text: division.title),
          ]);
  final RowRemover _remover = RowRemover();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _add() {
    _controllers.focusNextNewRow();
    widget.addDivision();
  }

  Future<void> _remove(Division division) {
    final controllers = _controllers.of(division);
    return _remover.remove(
      context,
      hasText: controllers.any((c) => c.text.trim().isNotEmpty),
      rowName: 'division',
      remove: () => widget.removeDivision(division),
      failureMessage: "Removing that Division didn't work",
      errorIdentifier: "Remove Divisions",
    );
  }

  @override
  Widget build(BuildContext context) {
    _controllers.retainOnly(widget.divisions);
    return Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.green[100]
            : Colors.blueGrey[900],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Divisions",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Divisions"),
                              content: const Text(
                                  "Divisions are groupings of verses that are related. There should be at least two and no more than four."),
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
              ...widget.divisions.map((division) {
                final controllers = _controllers.of(division);
                return Container(
                    key: ObjectKey(division),
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 75,
                            child: TextField(
                                autofocus:
                                    _controllers.shouldAutofocus(division),
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: controllers[0],
                                decoration: const InputDecoration(
                                  labelText: 'Verses',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (String value) async {
                                  await division.updatePassage(value);
                                  await widget.homiletic.update();
                                })),
                        Expanded(
                            child: TextField(
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: controllers[1],
                                onSubmitted: (_) => _add(),
                                decoration: const InputDecoration(
                                  labelText: 'Division Sentence',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 4,
                                minLines: 1,
                                onChanged: (String value) async {
                                  await division.updateText(value);
                                  await widget.homiletic.update();
                                })),
                        IconButton(
                          tooltip: 'Remove division',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _remove(division),
                        ),
                      ],
                    ));
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                          Text('(${widget.divisions.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
