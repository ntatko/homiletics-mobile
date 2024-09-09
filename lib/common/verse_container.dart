import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homiletics/classes/passage.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/report_error.dart';

// ignore: must_be_immutable
class VerseContainer extends StatefulWidget {
  String passage;
  Translation? translation;

  VerseContainer({Key? key, required this.passage, this.translation})
      : super(key: key);

  @override
  VerseContainerState createState() => VerseContainerState();
}

class VerseContainerState extends State<VerseContainer> {
  @override
  void didUpdateWidget(covariant VerseContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PassageResponse>(
        future: fetchPassage(widget.passage, Preferences.translation),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            sendError("${snapshot.error}", 'PassageContainer');
            return const Center(child: Text("An error occurred"));
          }

          return snapshot.hasData
              ? Scrollbar(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SelectableText.rich(TextSpan(children: [
                            TextSpan(
                                text: "${snapshot.data!.reference}\n\n",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black)),
                            TextSpan(
                                text:
                                    "${snapshot.data!.verses[0].chapter.toString()}: ",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            ...snapshot.data!.verses.fold(
                                [],
                                (List t, Passage passage) => [
                                      ...t,
                                      if (snapshot.data!.verses
                                                  .indexOf(passage) >=
                                              1 &&
                                          snapshot
                                                  .data!
                                                  .verses[snapshot.data!.verses
                                                          .indexOf(passage) -
                                                      1]
                                                  .chapter !=
                                              passage.chapter)
                                        TextSpan(
                                            text:
                                                "${passage.chapter.toString()}: ",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      TextSpan(
                                        text: "${passage.verse.toString()} ",
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12),
                                      ),
                                      TextSpan(
                                          recognizer:
                                              DoubleTapGestureRecognizer()
                                                ..onDoubleTap = () {
                                                  Clipboard.setData(
                                                          ClipboardData(
                                                              text: passage.text
                                                                  .replaceAll(
                                                                      '\n',
                                                                      '')))
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: const Text(
                                                          "Verse copied to clipboard"),
                                                      action: SnackBarAction(
                                                        onPressed: () {},
                                                        label: "Ok",
                                                      ),
                                                    ));
                                                  });
                                                },
                                          text:
                                              "${passage.text.replaceAll('\n', '')}\n\n",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                          )),
                                    ]).toList(),
                            TextSpan(
                                text: "(${Preferences.translation.name})\n",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                            TextSpan(
                                text: Preferences.translation == Translation.esv
                                    ? """
Scripture quotations are from the ESV® Bible (The Holy Bible, English Standard Version®), copyright © 2001 by Crossway, a publishing ministry of Good News Publishers. Used by permission. All rights reserved. The ESV text may not be quoted in any publication made available to the public by a Creative Commons license. The ESV may not be translated into any other language.
Users may not copy or download more than 500 verses of the ESV Bible or more than one half of any book of the ESV Bible.\n\n"""
                                    : "\n",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ])))))
              : const Center(child: CircularProgressIndicator());
        });
  }
}
