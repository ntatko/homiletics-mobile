import 'package:flutter/material.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:homiletics/theme/home_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A saved word study in a list: the word (or passage), "Word study ·
/// passage · time". Opens the word-study editor.
class WordStudyListItem extends StatelessWidget {
  final WordStudy study;
  final bool divider;

  const WordStudyListItem({Key? key, required this.study, this.divider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasWord = study.word.isNotEmpty;
    final List<String> parts = [
      'Word study',
      if (hasWord && study.passage.isNotEmpty) study.passage,
      timeago.format(study.updatedAt ?? DateTime.now()),
    ];
    return StudyListRow(
      key: Key("${study.id}"),
      leading: const StudyKindTile(StudyKind.wordStudy),
      title: hasWord
          ? study.word
          : (study.passage.isNotEmpty ? study.passage : 'Word study'),
      subtitle: parts.join(' · '),
      divider: divider,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WordStudyEditor(study: study)));
      },
    );
  }
}
