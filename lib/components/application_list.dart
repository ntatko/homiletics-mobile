import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/pages/application_page.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:loggy/loggy.dart';

class ApplicationList extends StatelessWidget {
  const ApplicationList({Key? key}) : super(key: key);

  /// Vertical space for the horizontal carousel only (cards fill this; no [Expanded] gap).
  static const double _carouselStripHeight = 124;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        child: Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.green[900]
                : Colors.green[100],
            child: FutureBuilder<List<Application>>(
              future: getAllApplicationsWithPassages(),
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

                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeHeader(
                        title: "Application Questions",
                        onExpand: () {
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
                      SizedBox(
                        height: _carouselStripHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: filteredDataList.length,
                          itemBuilder: (context, index) {
                            return ApplicationListItem(
                              application: filteredDataList[index],
                              carouselStripHeight: _carouselStripHeight,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            )));
  }
}
