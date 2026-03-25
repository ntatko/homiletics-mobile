import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';

class ApplicationPage extends StatelessWidget {
  final List<Application> applications;

  const ApplicationPage({Key? key, required this.applications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Questions'),
      ),
      body: applications.isEmpty
          ? Center(
              child: Text(
                'No application questions yet.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: applications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return ApplicationListItem(
                  application: applications[index],
                  displayStyle: ApplicationQuestionDisplay.list,
                );
              },
            ),
    );
  }
}
