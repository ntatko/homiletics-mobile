import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/homiletic_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:loggy/loggy.dart';

/// Every saved homiletic, newest first (the "Homiletics" tab of
/// [LessonPage]).
class PastLessons extends StatelessWidget {
  /// Shown until the list's own (refreshable) query comes back.
  final List<Homiletic>? initialData;

  const PastLessons({Key? key, this.initialData}) : super(key: key);

  static Future<List<Homiletic>> _load() async =>
      (await getAllHomiletics()).reversed.toList();

  @override
  Widget build(BuildContext context) {
    return StudyDataBuilder<List<Homiletic>>(
        load: _load,
        initialData: initialData,
        builder: (context, snapshot) {
          if (snapshot.hasError) logError('${snapshot.error}');
          if (!snapshot.hasData) return const StudyListLoading();
          return DisplayLessons(snapshot.data!);
        });
  }
}

class DisplayLessons extends StatelessWidget {
  final List<Homiletic> homiletics;

  const DisplayLessons(this.homiletics, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (homiletics.isEmpty) {
      return StudyListEmpty(context.l10n.studiesNoHomiletics);
    }
    return ListView.builder(
      padding: studyListPadding,
      itemCount: homiletics.length,
      itemBuilder: (context, index) => HomileticListItem(
        key: ValueKey(homiletics[index].id),
        homiletic: homiletics[index],
        divider: index < homiletics.length - 1,
      ),
    );
  }
}

/// Padding of the full study lists.
const EdgeInsets studyListPadding = EdgeInsets.fromLTRB(16, 8, 16, 32);

/// Spinner shown while a study list loads.
class StudyListLoading extends StatelessWidget {
  const StudyListLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Muted message for a study list with nothing in it.
class StudyListEmpty extends StatelessWidget {
  final String message;

  const StudyListEmpty(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: AppColors.of(context).muted)),
      ),
    );
  }
}
