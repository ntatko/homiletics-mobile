import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/pages/application_page.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:loggy/loggy.dart';

class ApplicationList extends StatelessWidget {
  const ApplicationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        child: Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.green[900]
                : Colors.green[100],
            child: FutureBuilder<List<Application>>(
              future: getAllApplications(),
              builder: (context, snapshot) {
                if (snapshot.hasError) logError("${snapshot.error}");

                List<Application> filteredDataList = snapshot.data
                        ?.where((application) => application.text != '')
                        .toList()
                        .reversed
                        .toList() ??
                    [];

                return Container(
                  height:
                      snapshot.hasData && filteredDataList.isNotEmpty ? 240 : 0,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 10),
                  child: snapshot.hasData
                      ? Column(children: [
                          HomeHeader(
                              title: "Application Questions",
                              onExpand: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ApplicationPage(
                                            applications: filteredDataList)));
                              }),
                          Expanded(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filteredDataList.length,
                                  itemBuilder: (context, index) {
                                    Application? application =
                                        filteredDataList[index];
                                    return ApplicationListItem(
                                      application: application,
                                    );
                                  }))
                        ])
                      : const SizedBox.shrink(),
                );
              },
            )));
  }
}
