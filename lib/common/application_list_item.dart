import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

class ApplicationListItem extends StatelessWidget {
  final Application application;

  const ApplicationListItem({Key? key, required this.application})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapUp: (_) async {
          Homiletic homiletic =
              await getHomileticById(application.homileticsId);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomileticEditor(homiletic: homiletic)));
        },
        child: SizedBox(
            width: 180,
            child: Card(
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.green[300]
                    : Colors.green[800],
                margin: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 20),
                // decoration: BoxDecoration(
                //     color: Colors.green[600],
                //     boxShadow: [
                //       BoxShadow(
                //           color: Colors.grey[400]!,
                //           blurRadius: 10,
                //           offset: const Offset(0, 3))
                //     ],
                //     borderRadius: BorderRadius.circular(12)),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      application.text,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20),
                    )))));
  }
}
