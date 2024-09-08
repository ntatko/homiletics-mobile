import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:http/http.dart' as http;

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String _name = '';
  String _email = '';
  String _content = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Leave Some Feedback',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close))
              ],
            ),
            const Divider(),
            SizedBox(
              height: 300,
              child: ListView(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _name = value;
                        }),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _email = value;
                        }),
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _content = value;
                        }),
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Feedback',
                          border: OutlineInputBorder(),
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 12),
              child: ElevatedButton(
                child: const Text("Submit"),
                onPressed: () async {
                  try {
                    await submitFeedback(_name, _email, _content);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Successfully submitted feedback"),
                      action: SnackBarAction(
                        onPressed: () {},
                        label: "Ok",
                      ),
                    ));
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(
                          "Feedback submission failed, try again soon."),
                      action: SnackBarAction(
                        onPressed: () {},
                        label: "Ok",
                      ),
                    ));
                    sendError(error, "Feedback Submission");
                  }
                },
              ),
            )
          ],
        ));
  }
}

Future<void> submitFeedback(String name, String email, String feedback) async {
  await http.post(
    Uri.parse(
        'https://homiletics-directus.cloud.plodamouse.com/items/homiletics_feedback'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'name': name, 'email': email, 'feedback': feedback}),
  );
}
