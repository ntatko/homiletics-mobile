import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
// import 'package:homiletics/storage/application_storage.dart';
// import 'package:homiletics/storage/content_summary_storage.dart';
// import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:loggy/loggy.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

              return Container(
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
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[200]!,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ]),
                          width: MediaQuery.of(context).size.width - 20,
                          height: 75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: 50,
                                  width: 50,
                                  margin: const EdgeInsets.only(
                                      right: 25, left: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.white)),
                                  child: Center(
                                    child: Text(
                                      homiletic.passage.substring(0, 3),
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
                              Text(timeago.format(
                                  homiletic.updatedAt ?? DateTime.now(),
                                  locale: 'en_short'))
                            ],
                          ))));
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
