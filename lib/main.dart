import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/services/realtime_sync_client.dart';
import 'package:homiletics/services/sync_service.dart';
import 'package:homiletics/sync_trigger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  runApp(const MyApp());

  try {
    // if the /hive directory does not exist, make it
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory hiveDir = Directory(path.join(appDir.path, 'hive'));

    // create a hive directory if it does not exist
    if (!(await hiveDir.exists())) {
      await hiveDir.create(recursive: true);
    }

    // configure hive (hive boxes MUST BE OPEN BEFORE UI IS RENDERED)
    Hive.init(hiveDir.path);

    await Preferences.init();
    onSyncDataChanged = () {
      unawaited(SyncService.instance.schedulePush());
    };
    SyncService.instance.pullIfSignedIn();
    RealtimeSyncClient.instance.start();
  } catch (e) {
    // print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F8F6B),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F8F6B),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Homiletics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
      ),
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}
