import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/pages/application_page.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:loggy/loggy.dart';

/// Home's "Living it out" section: the latest application questions in one
/// card. "See all" opens [ApplicationPage] when there are more.
class ApplicationList extends StatelessWidget {
  /// How many questions Home shows.
  static const int count = 3;

  /// Around the section when it shows (it collapses entirely when empty).
  final EdgeInsetsGeometry padding;

  const ApplicationList({Key? key, this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudyDataBuilder<List<Application>>(
      load: getAllApplicationsWithPassages,
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");

        List<Application> filteredDataList = snapshot.data
                ?.where((application) => application.text != '')
                .toList()
                .reversed
                .toList() ??
            [];

        if (!snapshot.hasData || filteredDataList.isEmpty) {
          return const SizedBox.shrink();
        }

        final List<Application> shown = filteredDataList.take(count).toList();
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                "Living it out",
                actionLabel: "See all",
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationPage(
                        applications: filteredDataList,
                      ),
                    ),
                  );
                },
              ),
              AppCard(
                radius: 16,
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < shown.length; i++)
                      ApplicationListItem(
                        application: shown[i],
                        divider: i < shown.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
