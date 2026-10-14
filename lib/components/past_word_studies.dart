import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/common/word_study_list_item.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:loggy/loggy.dart';

/// Every saved word study, newest first (the "Word studies" tab of
/// [LessonPage]).
class PastWordStudies extends StatelessWidget {
  const PastWordStudies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudyDataBuilder<List<WordStudy>>(
      load: getAllWordStudies,
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");
        if (!snapshot.hasData) return const StudyListLoading();

        final List<WordStudy> studies = snapshot.data!.reversed.toList();
        if (studies.isEmpty) {
          return StudyListEmpty(context.l10n.studiesNoWordStudies);
        }
        return ListView.builder(
          padding: studyListPadding,
          itemCount: studies.length,
          itemBuilder: (context, index) => WordStudyListItem(
            study: studies[index],
            divider: index < studies.length - 1,
          ),
        );
      },
    );
  }
}
