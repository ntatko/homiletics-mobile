import 'package:flutter/material.dart';
import 'package:homiletics/components/feedback_form.dart';
// import 'package:url_launcher/url_launcher.dart';

class HelpMenu extends StatelessWidget {
  final VoidCallback? onOpenSettings;

  const HelpMenu({Key? key, this.onOpenSettings}) : super(key: key);

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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0))),
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: FeedbackForm(),
                          );
                        });
                  },
                  child: const Text("Request Help / Leave Feedback?")),
              if (onOpenSettings != null)
                TextButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('Settings'),
                ),
            ],
          ),
        ]));
  }
}
