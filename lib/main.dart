import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/pages/home.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  runApp(MyApp());

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
  } catch (e) {
    // print(e);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homiletics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}
