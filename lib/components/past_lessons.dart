import 'package:flutter/material.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/common/homiletic_list_item.dart';
import 'package:homiletics/pages/lesson_page.dart';
import 'package:homiletics/services/sync_service.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:loggy/loggy.dart';

/// Refetches from SQLite whenever [SyncService] notifies (pull, push, remote ops).
class PastLessons extends StatefulWidget {
  const PastLessons({Key? key}) : super(key: key);

  @override
  State<PastLessons> createState() => _PastLessonsState();
}

class _PastLessonsState extends State<PastLessons> {
  late Future<List<Homiletic>> _homileticsFuture;

  @override
  void initState() {
    super.initState();
    _homileticsFuture = getAllHomiletics();
    SyncService.instance.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    SyncService.instance.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    if (!mounted) return;
    setState(() {
      _homileticsFuture = getAllHomiletics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Homiletic>>(
        future: _homileticsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) logError('${snapshot.error}');

          return snapshot.hasData
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DisplayLessons(snapshot.data?.reversed.toList() ?? []))
              : const SizedBox.shrink();
        });
  }
}

class DisplayLessons extends StatelessWidget {
  final List<Homiletic> homiletics;

  const DisplayLessons(this.homiletics, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return homiletics.isNotEmpty
        ? Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blueGrey[900]
                : Colors.blueGrey[100],
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeHeader(
                    title: "Past Homiletics",
                    onExpand: homiletics.length > 4
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LessonPage(homiletics: homiletics),
                              ),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: 2),
                  ...homiletics.take(6).map((homiletic) {
                    return HomileticListItem(
                      homiletic: homiletic,
                    );
                  }).toList(),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
