import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homiletics/common/rounded_button.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
        Container(
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
        Container(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Expanded(
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
            ))),
        Container(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Expanded(
                child: TextField(
              maxLines: 6,
              onChanged: (value) => setState(() {
                _content = value;
              }),
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
            ))),
        Container(
          padding: const EdgeInsets.only(bottom: 15, top: 12),
          child: RoundedButton(
            child: const Text("Submit"),
            onClick: () async {
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
                  content:
                      const Text("Feedback submission failed, try again soon."),
                  action: SnackBarAction(
                    onPressed: () {},
                    label: "Ok",
                  ),
                ));
              }
            },
          ),
        )
      ],
    );
  }
}

Future<void> submitFeedback(String name, String email, String feedback) async {
  await http.post(
    Uri.parse('https://homiletics.cloud.zipidy.org/items/feedback'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'name': name, 'email': email, 'feedback': feedback}),
  );
}
