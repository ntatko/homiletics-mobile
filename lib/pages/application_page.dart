import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/common/application_list_item.dart';
import 'package:matomo/matomo.dart';

class ApplicationPage extends TraceableStatelessWidget {
  final List<Application> applications;

  const ApplicationPage({required this.applications});

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
