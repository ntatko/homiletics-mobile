import 'package:flutter/material.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
// import 'package:homiletics/storage/application_storage.dart';
// import 'package:homiletics/storage/content_summary_storage.dart';
// import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:loggy/loggy.dart';
// import 'package:timeago/timeago.dart' as timeago;
import 'package:string_to_hex/string_to_hex.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  Future<List<Homiletic>> homiletics = getAllHomiletics();

  Future<void> resetData() async {
    setState(() {
      homiletics = getAllHomiletics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Homiletics')),
        // bottomNavigationBar: BottomAppBar(
        //   shape: const CircularNotchedRectangle(),
        //   child: TextButton(
        //     child: const Text("reset the data"),
        //     onPressed: () async {
        //       await resetTable();
        //       await resetApplicationsTable();
        //       await resetDivisionsTable();
        //       await resetSummariesTable();
        //     },
        //   ),
        // ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomileticEditor()),
            );
          },
          label: const Text('New'),
          tooltip: 'New Homiletics',
          icon: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: resetData,
          child: FutureBuilder<List<Homiletic>>(
              future: homiletics,
              builder: (context, snapshot) {
                if (snapshot.hasError) logError('${snapshot.error}');

                return snapshot.hasData
                    ? DisplayLessons(snapshot.data!, () {
                        resetData();
                      })
                    : const Center(child: Text('Loading...'));
              }),
        ));
  }
}

class DisplayLessons extends StatelessWidget {
  final List<Homiletic> homiletics;
  final Function() resetData;

  const DisplayLessons(this.homiletics, this.resetData, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return homiletics.isNotEmpty
        ? ListView.builder(
            itemCount: homiletics.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final homiletic = homiletics[index];

              return Dismissible(
                  key: Key("${homiletic.id}"),
                  onDismissed: (direction) async {
                    Map<String, dynamic> restores = await homiletic.delete();
                    await resetData();

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(children: [
                      Text('"${homiletic.passage}" deleted'),
                      TextButton(
                          onPressed: () async {
                            Homiletic hom = restores['homiletic'];
                            hom.id = -1;
                            await hom.update();
                            for (ContentSummary i in restores['summaries']) {
                              i.homileticId = hom.id;
                              i.id = -1;
                              await i.update();
                            }
                            for (Division i in restores['divisions']) {
                              i.homileticId = hom.id;
                              i.id = -1;
                              await i.update();
                            }
                            for (Application i in restores['applications']) {
                              i.homileticsId = hom.id;
                              i.id = -1;
                              await i.update();
                            }
                            await resetData();
                          },
                          child: const Text("Undo"))
                    ])));
                  },
                  child: Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: GestureDetector(
                          onTapUp: (_) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomileticEditor(homiletic: homiletic)));
                          },
                          child: Container(
                              padding: const EdgeInsets.only(
                                  top: 8, left: 8, bottom: 8, right: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[400]!,
                                        blurRadius: 10,
                                        offset: const Offset(0, 3))
                                  ]),
                              width: MediaQuery.of(context).size.width - 20,
                              height: 75,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    Container(
                                        height: 50,
                                        width: 50,
                                        margin: const EdgeInsets.only(
                                            right: 10, left: 10),
                                        decoration: BoxDecoration(
                                            color: Color(StringToHex.toColor(
                                                homiletic.passage
                                                    .padLeft(3)
                                                    .toLowerCase()
                                                    .replaceAll(
                                                        RegExp(r'[^\w\s]+'), '')
                                                    .substring(0, 3))),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                                color: Colors.white)),
                                        child: Center(
                                          child: Text(
                                            homiletic.passage
                                                .padRight(3)
                                                .substring(0, 3),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                        )),
                                    Text(homiletic.passage,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                                  ]),
                                  // Times are wildly wrong

                                  // Text(timeago.format(
                                  //     homiletic.updatedAt ?? DateTime.now(),
                                  //     locale: 'en_short'))
                                ],
                              )))));
            })
        : Center(
            child: SizedBox(
                height: 300,
                child: Column(children: [
                  const Text('No Lessons yet!'),
                  TextButton(onPressed: resetData, child: const Text("Refresh"))
                ])));
  }
}
