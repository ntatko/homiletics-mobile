import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/storage/application_storage.dart';

class ApplicationPage extends StatelessWidget {
  final List<Application> applications;

  const ApplicationPage({Key? key, required this.applications})
      : super(key: key);

  /// Same filtering and order as the home screen's [ApplicationList].
  static Future<List<Application>> _load() async =>
      (await getAllApplicationsWithPassages())
          .where((application) => application.text != '')
          .toList()
          .reversed
          .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Questions'),
      ),
      body: StudyDataBuilder<List<Application>>(
        load: _load,
        initialData: applications,
        builder: (context, snapshot) {
          final List<Application> current = snapshot.data ?? applications;
          return current.isEmpty
              ? Center(
                  child: Text(
                    'No application questions yet.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
    );
  }
}
