import 'package:flutter/material.dart';
import 'package:homiletics/components/feedback_form.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Opens the help / feedback form in a bottom sheet.
Future<void> showFeedbackSheet(BuildContext context) {
  return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: FeedbackForm(),
        );
      });
}

/// Copyright line and the help / feedback link at the foot of a page.
class HelpMenu extends StatelessWidget {
  const HelpMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle footnote =
        AppText.caption.copyWith(color: AppColors.of(context).muted);
    return Container(
        padding: const EdgeInsets.only(top: 28, bottom: 10),
        child: Column(children: [
          Center(
              child: Text("Copyright (C) ${DateTime.now().year} 13one.org",
                  style: footnote)),
          Center(child: Text("All rights reserved", style: footnote)),
          const SizedBox(height: 4),
          TextButton(
              onPressed: () => showFeedbackSheet(context),
              style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text("Request help / leave feedback"))
        ]));
  }
}
