import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';

class ApplicationPage extends StatelessWidget {
  final List<Application> applications;

  const ApplicationPage({Key? key, required this.applications}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Questions"),
      ),
      body: Column(children: [
        Expanded(
            child: OrientationBuilder(
          builder: ((context, orientation) => GridView.count(
                primary: false,
                crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                children: applications
                    .map((e) => ApplicationListItem(
                          application: e,
                        ))
                    .toList(),
              )),
        ))
      ]),
    );
  }
}
