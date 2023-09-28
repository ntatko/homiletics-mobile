import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:loggy/loggy.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomileticsList extends StatelessWidget {
  const HomileticsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Past Homiletics"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()), (r) => false);
                },
              ),
            ),
            body: FutureBuilder<List<Homiletic>>(
              future: getAllHomiletics(),
              builder: (context, snapshot) {
                if (snapshot.hasError) logError('${snapshot.error}');

                return snapshot.hasData ? DisplayLessons(snapshot.data!) : const Center(child: Text('Loading...'));
              },
            )));
  }
}

class DisplayLessons extends StatelessWidget {
  final List<Homiletic> homiletics;

  const DisplayLessons(this.homiletics, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return homiletics.isNotEmpty
        ? ListView.builder(
            itemCount: homiletics.length,
            itemBuilder: (context, index) {
              Homiletic homiletic = homiletics[index];
              return SizedBox(
                  key: Key("${homiletic.id}"),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: GestureDetector(
                          onTapUp: (_) {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => HomileticEditor(homiletic: homiletic)));
                          },
                          child: Container(
                              padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8, right: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey[400]!, blurRadius: 10, offset: const Offset(0, 3))
                                  ]),
                              width: MediaQuery.of(context).size.width - 20,
                              height: 75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    Container(
                                        height: 50,
                                        width: 50,
                                        margin: const EdgeInsets.only(right: 10, left: 10),
                                        decoration: BoxDecoration(
                                            color: Color(StringToHex.toColor(homiletic.passage
                                                .padLeft(3)
                                                .toLowerCase()
                                                .replaceAll(RegExp(r'[^\w\s]+'), '')
                                                .substring(0, 3))),
                                            borderRadius: BorderRadius.circular(25),
                                            border: Border.all(color: Colors.white)),
                                        child: Center(
                                          child: Text(
                                            homiletic.passage.replaceAll(RegExp(r'\s'), '').padRight(3).substring(0, 3),
                                            style: const TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                          ),
                                        )),
                                    Text(homiletic.passage,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                  ]),
                                  //Times are wildly wrong

                                  Text(timeago.format(homiletic.updatedAt ?? DateTime.now(), locale: 'en_short'))
                                ],
                              )))));
            })
        : const Center(child: SizedBox(height: 300, child: Text('No Lessons yet!')));
  }
}
