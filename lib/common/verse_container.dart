import 'package:flutter/material.dart';
import 'package:homiletics/classes/passage.dart';
import 'package:loggy/loggy.dart';

class VerseContainer extends StatelessWidget {
  final String passage;

  const VerseContainer({Key? key, required this.passage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FutureBuilder<List<Passage>>(
          future: fetchPassage(passage),
          builder: (context, snapshot) {
            if (snapshot.hasError) logError("${snapshot.error}");

            return snapshot.hasData
                ? ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      Passage? current = snapshot.data?[index];
                      return Container(
                          padding: const EdgeInsets.all(4),
                          color: index % 2 == 1
                              ? Colors.grey[100]
                              : Colors.grey[300],
                          child: Text(
                            "${current?.chapter}:${current?.verse} ${current?.text}"
                                .replaceAll('\n', ''),
                          ));
                    })
                : const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
