import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';

class ApplicationQuestionsCard extends StatelessWidget {
  List<Application> applications;
  final Homiletic homiletic;
  void Function() addApplication;
  Future<void> Function() removeApplication;

  ApplicationQuestionsCard(
      {Key? key,
      required this.applications,
      required this.homiletic,
      required this.addApplication,
      required this.removeApplication})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.grey[200],
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              const Text("Application Questions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ...applications.map((application) {
                // int index = _applications.indexOf(application);
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(8),
                    child: TextField(
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller:
                            TextEditingController(text: application.text),
                        decoration: const InputDecoration(
                          hintText: 'How can I...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) {
                          addApplication();
                          // setState(() {
                          //   _applications
                          //       .add(Application.blank(_thisHomiletic.id));
                          // });
                        },
                        onChanged: (value) async {
                          await application.updateText(value);
                          await homiletic.update();
                        }));
              }),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Wrap(
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
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(Icons.remove)),
                                Text('Remove')
                              ],
                            ),
                            onPressed: applications.isNotEmpty
                                ? () async {
                                    try {
                                      removeApplication();
                                      // await applications[
                                      //         applications.length - 1]
                                      //     .delete();
                                      // setState(() {
                                      //   _applications.removeLast();
                                      // });
                                    } catch (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: const Text(
                                            "Removing that Application didn't work"),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                      sendError(error, "Remove application");
                                    }
                                  }
                                : null),
                        ElevatedButton(
                            onPressed: () {
                              addApplication();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 0, right: 10),
                                    child: Icon(Icons.add)),
                                SizedBox(
                                    width: 90,
                                    child: Text(
                                      'Application',
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ))
                              ],
                            )),
                      ])),
            ])));
  }
}
