import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:loggy/loggy.dart';

class ApplicationList extends StatelessWidget {
  const ApplicationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Application>>(
      future: getAllApplications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) logError("${snapshot.error}");

        List<Application> filteredDataList = snapshot.data
                ?.where((application) => application.text != '')
                .toList() ??
            [];

        return AnimatedContainer(
          height: snapshot.hasData && filteredDataList.isNotEmpty ? 240 : 0,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 20),
          duration: const Duration(milliseconds: 400),
          child: snapshot.hasData
              ? Column(children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    child: Row(
                      children: const [Text("Application Questions")],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredDataList.length,
                          itemBuilder: (context, index) {
                            Application? application = filteredDataList[index];
                            return Container(
                                width: 160,
                                height: 180,
                                margin: const EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 20),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey[400]!,
                                          blurRadius: 10,
                                          offset: const Offset(0, 3))
                                    ],
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  application.text,
                                  maxLines: 6,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ));
                          }))
                ])
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
