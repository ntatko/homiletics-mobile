import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/storage/application_storage.dart';

class ApplicationPage extends StatelessWidget {
  final List<Application> applications;

  const ApplicationPage({Key? key, required this.applications})
      : super(key: key);

  static const double _maxWidth = 720;

  /// Same filtering and order as the home screen's [ApplicationList].
  static Future<List<Application>> _load() async =>
      (await getAllApplicationsWithPassages())
          .where((application) => application.text != '')
          .toList()
          .reversed
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeLivingItOut),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: StudyDataBuilder<List<Application>>(
            load: _load,
            initialData: applications,
            builder: (context, snapshot) {
              final List<Application> current = snapshot.data ?? applications;
              return current.isEmpty
                  ? StudyListEmpty(context.l10n.studiesNoApplications)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: current.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return ApplicationListItem(
                          application: current[index],
                          displayStyle: ApplicationQuestionDisplay.list,
                        );
                      },
                    );
            },
          ),
        ),
      ),
    );
  }
}
