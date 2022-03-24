import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homiletics/classes/passage.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:loggy/loggy.dart';

// ignore: must_be_immutable
class VerseContainer extends StatelessWidget {
  String passage;
  bool show;
  String version;

  VerseContainer(
      {Key? key, required this.passage, this.show = true, this.version = 'web'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.only(left: 6, right: 6),
      // height: MediaQuery.of(context).size.height * .7,
      child: show
          ? FutureBuilder<List<Passage>>(
              future: fetchPassage(
                  passage,
                  bibleTranslations.firstWhere(
                      (translation) => version == translation.code)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Failed to load passage"),
                    action: SnackBarAction(label: "Ok", onPressed: () {}),
                  ));
                  logError("${snapshot.error}");
                  return const SizedBox.expand();
                }

                return snapshot.hasData
                    ? Scrollbar(
                        child: SingleChildScrollView(
                            child: SelectableText.rich(TextSpan(children: [
                        TextSpan(
                            text: "${snapshot.data![0].chapter.toString()}: ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        ...snapshot.data!.fold(
                            [],
                            (List t, Passage passage) => [
                                  ...t,
                                  if (snapshot.data!.indexOf(passage) >= 1 &&
                                      snapshot
                                              .data![snapshot.data!
                                                      .indexOf(passage) -
                                                  1]
                                              .chapter !=
                                          passage.chapter)
                                    TextSpan(
                                        text: passage.chapter.toString(),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  TextSpan(
                                    text: "${passage.verse.toString()} ",
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 12),
                                  ),
                                  TextSpan(
                                      recognizer: DoubleTapGestureRecognizer()
                                        ..onDoubleTap = () {
                                          Clipboard.setData(ClipboardData(
                                                  text: passage.text
                                                      .replaceAll('\n', '')))
                                              .then((_) {
                                            ScaffoldMessenger.of(context)
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
                                ]).toList()
                      ]))))
                    : const Center(child: CircularProgressIndicator());
              })
          : const SizedBox.shrink(),
    ));
  }
}
