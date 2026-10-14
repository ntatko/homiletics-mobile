import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/common/relative_time.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:homiletics/theme/home_widgets.dart';

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
    final AppLocalizations l = context.l10n;
    final String time =
        relativeTime(context, study.updatedAt ?? DateTime.now());
    final String subtitle = hasWord && study.passage.isNotEmpty
        ? l.studiesWordStudySubtitleWithPassage(study.passage, time)
        : l.studiesWordStudySubtitle(time);
    return StudyListRow(
      key: Key("${study.id}"),
      leading: const StudyKindTile(StudyKind.wordStudy),
      title: hasWord
          ? study.word
          : (study.passage.isNotEmpty
              ? study.passage
              : l.studiesWordStudyUntitled),
      subtitle: subtitle,
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
