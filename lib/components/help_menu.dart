import 'package:flutter/material.dart';
import 'package:homiletics/components/feedback_form.dart';
// import 'package:url_launcher/url_launcher.dart';

class HelpMenu extends StatelessWidget {
  const HelpMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Column(children: [
          Center(
              child: Text("Copyright (C) ${DateTime.now().year} 13one.org",
                  style: const TextStyle(color: Colors.grey))),
          const Center(
              child: Text("All rights reserved",
                  style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return const Padding(
                        child: FeedbackForm(),
                        padding: EdgeInsets.all(12),
                      );
                    });
              },
              child: const Text("Request Help / Leave Feedback?"))
        ]));
  }
}
