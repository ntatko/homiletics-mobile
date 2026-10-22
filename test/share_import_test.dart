import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/components/share/import_link_sheet.dart';
import 'package:homiletics/components/share/study_share_sheet.dart';
import 'package:homiletics/l10n/generated/app_localizations.dart';
import 'package:homiletics/pages/import_preview_page.dart';
import 'package:homiletics/services/share_link.dart';
import 'package:homiletics/storage/app_storage.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/pdf_generation.dart' show HandoutImages;
import 'package:homiletics/storage/word_study_storage.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final List<dynamic> _vectors =
    jsonDecode(File('test/fixtures/share_link_vectors.json').readAsStringSync())
        as List<dynamic>;

String _link(String name) =>
    _vectors.firstWhere((v) => v['name'] == name)['link'] as String;

SharedStudy _study(String name) =>
    (ShareLink.decode(_link(name)) as ShareLinkSuccess).study;

Widget _app(Widget home) => MaterialApp(
      supportedLocales: [for (final l in Language.all) l.locale],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: buildAppTheme(Brightness.light),
      home: home,
    );

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('saving a copy', () {
    late Directory tmp;
    AppStorage? storage;

    setUp(() async {
      sqfliteFfiInit();
      tmp = Directory.systemTemp.createTempSync('share_import_');
      storage = await AppStorage.open(
          factory: databaseFactoryFfiNoIsolate, directory: tmp.path);
      AppStorage.debugInstance = Future.value(storage);
    });

    tearDown(() async {
      await storage?.close();
      storage = null;
      AppStorage.debugInstance = null;
      tmp.deleteSync(recursive: true);
    });

    test('a homiletic becomes new records, in order, leaving others alone',
        () async {
      final Homiletic mine = Homiletic(passage: 'Romans 3:1-20', aim: 'Mine');
      await mine.update();
      await ContentSummary(
              homileticId: mine.id, passage: '1', summary: 'my summary')
          .update();

      final SharedHomiletic shared = _study('homiletic') as SharedHomiletic;
      final Homiletic copy = await shared.saveCopy();
      final Homiletic again = await shared.saveCopy();

      expect(copy.id, isNot(mine.id));
      expect(again.id, isNot(copy.id));
      expect((await getAllHomiletics()).length, 3);

      final Homiletic stored = await getHomileticById(copy.id);
      expect(stored.passage, 'Romans 3:1-20');
      expect(stored.subjectSentence, shared.subjectSentence);
      expect(stored.fcf, shared.fcf);
      expect(stored.aim, 'the whole world is accountable to God.');

      final List<ContentSummary> summaries =
          await getSummariesByHomileticId(copy.id);
      expect([
        for (final s in summaries) [s.passage, s.summary]
      ], [
        for (final r in shared.contentSummaries) [r.verses, r.text]
      ]);
      final List<Division> divisions = await getDivisionsByHomileticId(copy.id);
      expect([
        for (final d in divisions) [d.passage, d.title]
      ], [
        for (final r in shared.divisions) [r.verses, r.text]
      ]);
      final List<Application> applications =
          await getApplicationsByHomileticId(copy.id);
      expect([for (final a in applications) a.text], shared.applications);

      // The existing study is untouched.
      final Homiletic mineAgain = await getHomileticById(mine.id);
      expect(mineAgain.aim, 'Mine');
      final List<ContentSummary> mySummaries =
          await getSummariesByHomileticId(mine.id);
      expect(mySummaries.single.summary, 'my summary');
    });

    test('a word study becomes a new record', () async {
      final WordStudy mine = WordStudy(word: 'Righteous', definition: 'Mine');
      await mine.update();

      final SharedWordStudy shared = _study('word_study') as SharedWordStudy;
      final WordStudy copy = await shared.saveCopy();
      expect(copy.id, isNot(mine.id));

      final List<WordStudy> all = await getAllWordStudies();
      expect(all.length, 2);
      final WordStudy stored = all.firstWhere((w) => w.id == copy.id);
      expect(stored.word, 'Righteous');
      expect(stored.otherUsage, 'Genesis 15:6\nRomans 1:17');
      expect(stored.deeperMeaning, 'Greek δίκαιος (dikaios).');
      expect(all.firstWhere((w) => w.id == mine.id).definition, 'Mine');
    });
  });

  group('preview', () {
    testWidgets('shows a shared homiletic read-only', (tester) async {
      _setSize(tester, const Size(390, 844));
      await tester
          .pumpWidget(_app(ImportPreviewPage(study: _study('homiletic'))));
      await tester.pumpAndSettle();
      expect(find.text('Romans 3:1-20'), findsOneWidget);
      expect(find.text('Shared homiletics'.toUpperCase()), findsOneWidget);
      expect(find.text('Written with NIV'), findsOneWidget);
      expect(find.text('Save a copy'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.scrollUntilVisible(
          find.text('How can I thank God for His faithfulness?',
              findRichText: true),
          200,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a shared word study, and a nearly empty one',
        (tester) async {
      _setSize(tester, const Size(320, 640));
      await tester
          .pumpWidget(_app(ImportPreviewPage(study: _study('word_study'))));
      await tester.pumpAndSettle();
      expect(find.text('Righteous'), findsOneWidget);
      expect(find.text('Shared word study'.toUpperCase()), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_app(const ImportPreviewPage(
          key: ValueKey('empty'), study: SharedWordStudy())));
      await tester.pumpAndSettle();
      expect(find.text('Nothing has been written for this word study yet.'),
          findsOneWidget);
    });

    testWidgets('bad links show a friendly error', (tester) async {
      await tester.pumpWidget(_app(Builder(
        builder: (context) => TextButton(
          onPressed: () => openShareLinkResult(
              Navigator.of(context), ShareLink.decode(_link('future_version'))),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Update Homiletics to open this'),
          findsOneWidget);
    });
  });

  group('import sheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.pumpWidget(_app(Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showImportLinkSheet(context),
            child: const Text('import'),
          ),
        ),
      )));
      await tester.tap(find.text('import'));
      await tester.pumpAndSettle();
    }

    testWidgets('rejects garbage and newer versions inline', (tester) async {
      await openSheet(tester);
      await tester.enterText(
          find.byKey(const ValueKey('importLinkField')), _link('garbage'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('importOpen')));
      await tester.pumpAndSettle();
      expect(find.textContaining("isn't a Homiletics link"), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('importLinkField')),
          _link('future_version'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('importOpen')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Update Homiletics'), findsOneWidget);
    });

    testWidgets('Paste reads the clipboard only when tapped, then opens',
        (tester) async {
      int reads = 0;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData') {
          reads++;
          return {'text': 'Look: ${_link('minimal')}'};
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await openSheet(tester);
      expect(reads, 0);
      await tester.tap(find.byKey(const ValueKey('importPaste')));
      await tester.pumpAndSettle();
      expect(reads, 1);
      expect(find.byType(ImportPreviewPage), findsOneWidget);
      expect(find.text('John 1'), findsOneWidget);
    });
  });

  group('share sheet', () {
    Future<void> openSheet(WidgetTester tester, String link) async {
      await tester.pumpWidget(_app(Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showStudyShareSheet(context,
                buildLink: () => link,
                title: 'Homiletics · Romans 3:1-20',
                buildImages: () async => const HandoutImages('study', []),
                onSharePdf: () async {},
                onPrint: () async {}),
            child: const Text('share'),
          ),
        ),
      )));
      await tester.tap(find.text('share'));
      await tester.pumpAndSettle();
    }

    testWidgets('lists the ways to share', (tester) async {
      await openSheet(tester, _link('homiletic'));
      for (final String label in [
        'Share link',
        'Copy link',
        'Show QR code',
        'Share as images',
        'Share PDF',
        'Print',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('Show QR code draws the link under the title', (tester) async {
      _setSize(tester, const Size(390, 844));
      await openSheet(tester, _link('homiletic'));
      await tester.tap(find.text('Show QR code'));
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Homiletics · Romans 3:1-20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a link too big for a QR code says so', (tester) async {
      _setSize(tester, const Size(390, 844));
      await openSheet(tester, 'https://homiletics.app/view#h=${'A' * 5000}');
      await tester.tap(find.text('Show QR code'));
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsNothing);
      expect(find.textContaining('too long for a QR code'), findsOneWidget);
    });

    testWidgets('Copy link copies, warning first when very long',
        (tester) async {
      final List<String?> copied = [];
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String?);
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await openSheet(tester, _link('minimal'));
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();
      expect(copied, [_link('minimal')]);
      expect(find.text('Link copied'), findsOneWidget);

      final String long = 'https://homiletics.app/view#h=${'A' * 9000}';
      await openSheet(tester, long);
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();
      expect(find.text('This link is very long'), findsOneWidget);
      await tester.tap(find.text('Share anyway'));
      await tester.pumpAndSettle();
      expect(copied.last, long);
    });
  });
}
