import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:hive/hive.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/suggested_passages_repository.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive must be initialized and the preferences box opened before runApp —
  // the UI reads Preferences synchronously on first frame. Without it the app
  // can't work, so show an error screen instead of crashing later.
  try {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory hiveDir = Directory(path.join(appDir.path, 'hive'));
    if (!(await hiveDir.exists())) {
      await hiveDir.create(recursive: true);
    }
    Hive.init(hiveDir.path);
  } catch (error) {
    sendError(error, "main: Hive init");
    runApp(const StartupErrorApp());
    return;
  }

  try {
    await Preferences.init();
  } catch (error) {
    sendError(error, "main: Preferences.init");
    runApp(const StartupErrorApp());
    return;
  }

  // Non-fatal: the repository reopens its box lazily if this fails.
  try {
    await SuggestedPassagesRepository.init();
  } catch (error) {
    sendError(error, "main: SuggestedPassagesRepository.init");
  }

  runApp(const MyApp());

  // Not needed for the first frame (only the recording / model settings UI
  // uses it), so don't delay startup. Reports its own errors.
  unawaited(TranscriptFormatterService.initialize());
}

ThemeData _buildTheme(Brightness brightness) {
  // No explicit colorScheme: with Material 3 the old `primarySwatch` was
  // ignored, so the app has always used the default M3 baseline scheme.
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homiletics',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}

/// Shown when local storage can't be initialized, so the app can't run.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homiletics',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Homiletics could not start',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your saved data could not be opened. Please close and '
                    'reopen the app. If this keeps happening, make sure your '
                    'device has free storage space.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
