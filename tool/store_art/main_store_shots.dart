// Store-art capture entry point: a copy of lib/main_screenshots.dart with
// extra HSCREEN values for the later homiletic steps. Never shipped; build
// with `-t tool/store_art/main_store_shots.dart`.
//   homiletic_mid   Divisions + Summary sentence expanded
//   homiletic_late  FCF + Aim + Application expanded
//   chicken         Content at 20 summaries, asking about a 21st
//   share_images    The homiletic's square share images, light and dark
//
// It keeps all data in a throwaway folder (so it can't touch real
// studies, even on a device that has them), seeds sample studies, and
// opens one screen. Choose it with environment variables (simctl:
// SIMCTL_CHILD_HSCREEN=…) or --dart-define:
//   HSCREEN  home | homiletic | lecture | wordstudy | walkthrough
//   HLANG    en | es | zh_Hans | zh_Hant | fr | pt | sw   (default en)
//   HTHEME   light | dark                                 (default light)
//   HVERSION a translation code, e.g. niv for Bible Gateway (default web)
//   HPASSAGE the sample homiletic's passage (default Romans 3:1-20)
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:homiletics/components/homiletics/too_many_summaries_dialog.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/services/incoming_links.dart' show appNavigatorKey;
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/main.dart';
import 'package:homiletics/pages/home.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/pages/notes_editor.dart';
import 'package:homiletics/pages/onboarding/onboarding_page.dart';
import 'package:homiletics/pages/word_study_editor.dart';
import 'package:homiletics/services/bible_text_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite/sqflite.dart';

/// Settings written by the screenshot script into the app's real
/// documents folder as screenshot.json (simulators don't reliably pass
/// launch environment variables through).
Map<String, dynamic> _fileSettings = const {};

String _setting(String name, String fallback) {
  final Object? fromFile = _fileSettings[name];
  if (fromFile is String && fromFile.isNotEmpty) return fromFile;
  final String? env = Platform.environment[name];
  if (env != null && env.isNotEmpty) return env;
  final String defined = switch (name) {
    'HSCREEN' => const String.fromEnvironment('HSCREEN'),
    'HLANG' => const String.fromEnvironment('HLANG'),
    'HTHEME' => const String.fromEnvironment('HTHEME'),
    'HVERSION' => const String.fromEnvironment('HVERSION'),
    'HPASSAGE' => const String.fromEnvironment('HPASSAGE'),
    _ => '',
  };
  return defined.isNotEmpty ? defined : fallback;
}

/// Points every path_provider directory at one throwaway folder.
class _SandboxPaths extends PathProviderPlatform {
  final String root;
  _SandboxPaths(this.root);

  String _dir(String name) {
    final Directory d = Directory('$root/$name')..createSync(recursive: true);
    return d.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir('documents');
  @override
  Future<String?> getApplicationSupportPath() async => _dir('support');
  @override
  Future<String?> getTemporaryPath() async => _dir('tmp');
  @override
  Future<String?> getApplicationCachePath() async => _dir('cache');
  @override
  Future<String?> getLibraryPath() async => _dir('library');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final File config = File(
        '${(await getApplicationDocumentsDirectory()).path}/screenshot.json');
    if (config.existsSync()) {
      _fileSettings =
          jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
    }
  } catch (_) {
    // No config: environment variables or --dart-define decide.
  }

  final Directory sandbox =
      Directory('${Directory.systemTemp.path}/homiletics_screenshots');
  if (sandbox.existsSync()) sandbox.deleteSync(recursive: true);
  sandbox.createSync(recursive: true);
  PathProviderPlatform.instance = _SandboxPaths(sandbox.path);
  await databaseFactory.setDatabasesPath('${sandbox.path}/databases');

  if (!await initializeApp()) return;

  final Language language =
      Language.fromCode(_setting('HLANG', 'en')) ?? Language.english;
  Preferences.appLanguage = language;
  Preferences.hasSeenOnboarding = true;
  // The offline World English Bible renders natively (and identically on
  // every platform); fall back to the web view if it can't download.
  final String version = _setting('HVERSION', Translation.web.code);
  Preferences.preferredVersion = version;
  if (version == Translation.web.code) {
    await BibleTextService.instance.download(Translation.web);
  }

  final _Samples samples = await _Samples.seed();
  final String screen = _setting('HSCREEN', 'home');
  if (screen == 'chicken') await samples.fillContent(20);
  final String passage = _setting('HPASSAGE', '');
  if (passage.isNotEmpty) await samples.homiletic.updatePassage(passage);
  final Widget home = switch (screen) {
    'chicken' => HomileticEditor(
        homiletic: samples.homiletic,
        initialExpanded: const {StudyStep.content}),
    'share_images' => _ShareImages(samples),
    'homiletic' => HomileticEditor(
        homiletic: samples.homiletic,
        initialExpanded: const {StudyStep.content, StudyStep.divisions}),
    'homiletic_mid' => HomileticEditor(
        homiletic: samples.homiletic,
        initialExpanded: const {StudyStep.divisions, StudyStep.summary}),
    'homiletic_late' => HomileticEditor(
          homiletic: samples.homiletic,
          initialExpanded: const {
            StudyStep.fcf,
            StudyStep.aim,
            StudyStep.application
          }),
    'lecture' => NotesEditor(note: samples.lecture),
    'wordstudy' => WordStudyEditor(study: samples.wordStudy),
    'walkthrough' => OnboardingPage(loadThisWeek: () async => null),
    _ => const Home(),
  };
  if (screen == 'chicken') {
    // Ask about a 21st once the editor has loaded.
    Future<void>.delayed(const Duration(seconds: 3), () {
      final BuildContext? context = appNavigatorKey.currentContext;
      if (context != null) confirmExtraContentSummary(context, 21);
    });
  }
  runApp(MyApp(
    home: home,
    themeMode: _setting('HTHEME', 'light') == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light,
  ));
}

class _Samples {
  final Homiletic homiletic;
  final LectureNote lecture;
  final WordStudy wordStudy;

  _Samples(this.homiletic, this.lecture, this.wordStudy);

  /// Splits the homiletic's Content into [count] rows, a verse or so each.
  Future<void> fillContent(int count) async {
    for (final ContentSummary s
        in await getSummariesByHomileticId(homiletic.id)) {
      await s.delete();
    }
    const List<String> lines = [
      'Advantage of the Jews',
      'Entrusted with the oracles of God',
      'Unbelief does not nullify faithfulness',
      'Let God be true',
      'Our unrighteousness shows His',
      'Is God unjust to inflict wrath?',
      'By no means: He judges the world',
      'Why not do evil that good may come?',
      'Are we any better? No',
      'None is righteous, not even one',
      'No one understands or seeks God',
      'All have turned aside',
      'Their throat an open grave',
      'Mouths full of curses',
      'Feet swift to shed blood',
      'Ruin and misery in their paths',
      'The way of peace not known',
      'No fear of God',
      'The law speaks to those under it',
      'By the law comes knowledge of sin',
    ];
    for (int i = 0; i < count; i++) {
      await (ContentSummary.blank(homiletic.id)
            ..passage = '${i + 1}'
            ..summary = lines[i % lines.length])
          .update();
    }
  }

  static Future<_Samples> seed() async {
    // An earlier, unfinished study so Home's lists aren't a single item.
    final Homiletic earlier = Homiletic(passage: 'Romans 2:17-29');
    await earlier.update();
    for (final (String v, String text) in [
      ('17-20', 'The Jews rely on the law and boast in God.'),
      ('21-24', 'Teaching others, they break the law themselves.'),
      ('25-29', 'True circumcision is of the heart, by the Spirit.'),
    ]) {
      await (ContentSummary.blank(earlier.id)
            ..passage = v
            ..summary = text)
          .update();
    }
    await Application(
            homileticsId: earlier.id,
            text: 'Where am I trusting religious habits instead of God?')
        .update();

    final Homiletic h = Homiletic(
      passage: 'Romans 3:1-20',
      subjectSentence: 'God is faithful; every person is guilty before Him.',
      fcf: 'We excuse our own sin and assume we are better than others.',
      aim: 'the whole world is accountable to God, so we need His '
          'righteousness, not our own.',
    );
    await h.update();
    for (final (String v, String text) in [
      ('1-2', "God entrusted the Jews with His very words."),
      ('3-4', "Human unfaithfulness can't cancel God's faithfulness."),
      ('5-8', "Our sin doesn't make God unjust in judging it."),
      ('9', 'Jews and Gentiles alike are under sin.'),
      ('10-12', 'No one is righteous; no one seeks God.'),
      ('13-14', 'Our words show the corruption of our hearts.'),
      ('15-18', 'Our ways lead to ruin; there is no fear of God.'),
      ('19-20', 'The law silences every mouth and shows us our sin.'),
    ]) {
      await (ContentSummary.blank(h.id)
            ..passage = v
            ..summary = text)
          .update();
    }
    for (final (String v, String text) in [
      ('1-8', 'God stays faithful even when His people fail.'),
      ('9-18', "Scripture's verdict: all are under sin."),
      ('19-20', 'The law shows our need, not our righteousness.'),
    ]) {
      await Division(h.id, passage: v, title: text).update();
    }
    for (final String q in [
      'Where am I comparing myself to others instead of to God?',
      'What excuse do I make for a sin I keep returning to?',
      "How can I thank God this week for His faithfulness?",
    ]) {
      await Application(homileticsId: h.id, text: q).update();
    }

    final LectureNote lecture = LectureNote(
      passage: 'Romans 3:1-20',
      note: jsonEncode([
        {
          'insert': 'No one is righteous',
          'attributes': {'bold': true}
        },
        {'insert': '\n'},
        {'insert': '[04:12] Paul lets his reader ask the hard questions first'},
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'}
        },
        {
          'insert': '[12:40] Verses 10–18 weave Psalms and Isaiah into '
              "Scripture's own verdict"
        },
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'}
        },
        {'insert': '[21:05] "Every mouth may be stopped" — no more excuses'},
        {
          'insert': '\n',
          'attributes': {'list': 'bullet'}
        },
        {'insert': 'For group: where do I quietly think I am the exception?\n'},
      ]),
      transcript: 'Paul has just shown that the Jewish people, who had the '
          'law, are as guilty as anyone. So he anticipates the objection. '
          'What advantage, then, is there in being a Jew?',
      formattedTranscript: 'Paul has just shown that the Jewish people, '
          'who had the law, are as guilty as anyone. So he anticipates the '
          'objection: "What advantage, then, is there in being a Jew?"\n\n'
          'His answer is surprising. Much in every way — because God '
          'entrusted them with His very words. Our unfaithfulness does not '
          "cancel God's faithfulness.",
    );
    await lecture.update();

    final WordStudy wordStudy = WordStudy(
      passage: 'Romans 3:10',
      word: 'Righteous',
      definition: 'Right with God: meeting His standard, fully in the right '
          'before the Judge.',
      otherUsage: 'Genesis 15:6\nHabakkuk 2:4\nRomans 1:17\nPhilippians 3:9',
      contextualMeaning: 'Paul quotes Psalm 14 to show that no one, Jew or '
          "Gentile, meets God's standard on their own.",
      deeperMeaning: 'The Greek δίκαιος (dikaios) describes someone in the '
          'right before a judge. Romans 3:21–26 answers verse 10: God gives '
          'His righteousness through faith in Christ.',
      application: "Stop measuring myself against others and rest in "
          "Christ's righteousness.",
    );
    await wordStudy.update();

    return _Samples(h, lecture, wordStudy);
  }
}

/// The homiletic's square share images, light and dark side by side.
class _ShareImages extends StatelessWidget {
  final _Samples samples;

  const _ShareImages(this.samples);

  Future<List<Uint8List>> _render(AppColors colors) async {
    final Homiletic h = samples.homiletic;
    final HomileticPdfFonts fonts =
        await HomileticPdfFonts.load(rootBundle.load);
    final pw.Document doc = buildHomileticsDocument(
        h,
        await getSummariesByHomileticId(h.id),
        await getDivisionsByHomileticId(h.id),
        await getApplicationsByHomileticId(h.id),
        fonts: fonts,
        layout: HandoutLayout.square,
        colors: colors);
    return [
      await for (final PdfRaster page
          in Printing.raster(await doc.save(), dpi: squareImageDpi))
        await page.toPng()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF808080),
      body: FutureBuilder<List<List<Uint8List>>>(
        future:
            Future.wait([_render(AppColors.light), _render(AppColors.dark)]),
        builder: (context, snapshot) {
          final List<List<Uint8List>>? sets = snapshot.data;
          if (sets == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final List<Uint8List> set in sets)
                  Expanded(
                    child: Row(
                      children: [
                        for (final Uint8List png in set)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.memory(png),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
