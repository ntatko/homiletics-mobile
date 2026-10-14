import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:hive/hive.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/components/update_prompt.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/services/incoming_links.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/recording_storage_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';
import 'package:homiletics/services/suggested_passages_repository.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!await initializeApp()) return;

  runApp(const MyApp());

  // Share links opened from other apps (and the one that launched us).
  if (!kIsWeb) IncomingLinks.start();

  // Windows has no store to deliver updates; offer new releases (once a
  // day at most). A no-op elsewhere.
  unawaited(checkForUpdatesOnLaunch());

  // Not needed for the first frame (only the recording / model settings UI
  // uses it), so don't delay startup. Reports its own errors.
  unawaited(WhisperModelService.cleanUpConversionFiles());
  // "Remove automatically" (off by default); at most once a day.
  if (!kIsWeb) unawaited(RecordingStorageService.runAutomaticCleanupIfDue());
  unawaited(TranscriptFormatterService.initialize());
}

/// Opens local storage. Returns false (after showing [StartupErrorApp]) if
/// the app can't run. Shared with lib/main_screenshots.dart.
Future<bool> initializeApp() async {
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
    return false;
  }

  try {
    await Preferences.init();
  } catch (error) {
    sendError(error, "main: Preferences.init");
    runApp(const StartupErrorApp());
    return false;
  }

  // Opens the single database and, on the first launch after the upgrade,
  // copies the old per-table files into it. Must finish before any screen
  // reads data. A failed copy doesn't throw (the app keeps using the old
  // files and retries next launch); this only throws if the new database
  // exists but can't be read, when no safe fallback exists.
  if (!kIsWeb) {
    try {
      await AppStorage.useFfiOnDesktop();
      await AppStorage.init();
    } catch (error) {
      sendError(error, "main: AppStorage.init");
      runApp(const StartupErrorApp());
      return false;
    }
  }

  // Non-fatal: the repository reopens its box lazily if this fails.
  try {
    await SuggestedPassagesRepository.init();
  } catch (error) {
    sendError(error, "main: SuggestedPassagesRepository.init");
  }
  return true;
}

ThemeData _buildTheme(Brightness brightness) => buildAppTheme(brightness);

class MyApp extends StatelessWidget {
  /// The first screen; Home unless a screenshot build picks another.
  final Widget home;
  final ThemeMode themeMode;

  const MyApp({
    Key? key,
    this.home = const Home(),
    this.themeMode = ThemeMode.system,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Language?>(
      valueListenable: Preferences.appLanguageNotifier,
      builder: (context, language, _) => MaterialApp(
        navigatorKey: appNavigatorKey,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        locale: language?.locale,
        supportedLocales: [for (final l in Language.all) l.locale],
        localeResolutionCallback: (locale, _) =>
            Language.match(locale ?? const Locale('en')).locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: themeMode,
        home: home,
      ),
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
