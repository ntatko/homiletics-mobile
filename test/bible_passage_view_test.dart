import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/bible_reference.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/bible/bible_passage_view.dart';
import 'package:homiletics/l10n/generated/app_localizations.dart';
import 'package:homiletics/services/bible_text.dart';
import 'package:homiletics/services/bible_text_service.dart';
import 'package:homiletics/theme/app_theme.dart';

import 'bible_text_test.dart' show sampleBibleJson;

Widget _app(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: [for (final l in Language.all) l.locale],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: buildAppTheme(brightness),
      home: Scaffold(body: child),
    );

/// The verse-number span showing [label] in the rendered passage.
TextSpan _verseSpan(WidgetTester tester, String label) {
  for (final RichText rt
      in tester.widgetList<RichText>(find.byType(RichText))) {
    TextSpan? found;
    rt.text.visitChildren((span) {
      if (span is TextSpan && span.text == '$label ') {
        found = span;
        return false;
      }
      return true;
    });
    if (found != null) return found!;
  }
  throw StateError('No verse number $label');
}

void _tapVerse(WidgetTester tester, String label) =>
    (_verseSpan(tester, label).recognizer! as TapGestureRecognizer).onTap!();

/// Offline texts held in memory: [downloaded] are available, and a
/// download "succeeds" by adding to it.
class _FakeService extends BibleTextService {
  final Map<String, BibleText> downloaded;
  final Map<String, BibleText> server;
  int downloads = 0;

  _FakeService({this.downloaded = const {}, this.server = const {}})
      : super(directory: () => throw UnimplementedError());

  @override
  Future<bool> isDownloaded(Translation t) async =>
      downloaded.containsKey(t.code);

  @override
  bool? isDownloadedNow(Translation t) => downloaded.containsKey(t.code);

  @override
  Future<BibleText?> load(Translation t) async => downloaded[t.code];

  @override
  Future<bool> autoDownload(Translation t) => download(t);

  @override
  Future<bool> download(Translation t) async {
    downloads++;
    final BibleText? text = server[t.code];
    if (text == null) return false;
    downloaded[t.code] = text;
    changes.value++;
    return true;
  }
}

void main() {
  final BibleText web = BibleText.fromJson(sampleBibleJson());

  group('BiblePassageView', () {
    testWidgets('renders headings, verses and the licence line',
        (tester) async {
      final chapters = web.select(BibleReference.parse('Romans 3:1-22')!)!;
      bool headerTapped = false;
      await tester.pumpWidget(_app(BiblePassageView(
        chapters: chapters,
        translationName: 'World English Bible',
        translationShort: 'WEB',
        copyright: 'Public Domain.',
        onTranslationTap: () => headerTapped = true,
      )));
      expect(find.text('Romanos 3'), findsOneWidget);
      expect(find.text('God’s Faithfulness'), findsOneWidget);
      expect(find.text('Righteousness Through Faith'), findsOneWidget);
      expect(find.textContaining('Romans three verse 9.', findRichText: true),
          findsOneWidget);
      await tester.scrollUntilVisible(find.text('Public Domain.'), 200);
      expect(find.text('Public Domain.'), findsOneWidget);
      expect(find.byType(SelectionArea), findsOneWidget);

      await tester.scrollUntilVisible(find.text('WEB'), -200);
      await tester.tap(find.text('WEB'));
      expect(headerTapped, isTrue);
      // The header's touch target is at least 44 tall.
      expect(
          tester
              .getSize(find.ancestor(
                  of: find.text('WEB'), matching: find.byType(InkWell)))
              .height,
          greaterThanOrEqualTo(44));
    });

    testWidgets('verse taps report the verse, with the chapter when needed',
        (tester) async {
      final List<String> taps = [];
      await tester.pumpWidget(_app(BiblePassageView(
        chapters: web.select(BibleReference.parse('Romans 3:1-8')!)!,
        translationName: 'WEB',
        translationShort: 'WEB',
        copyright: '',
        onVerseTap: taps.add,
      )));
      _tapVerse(tester, '4');
      expect(taps, ['4']);

      await tester.pumpWidget(_app(BiblePassageView(
        chapters: web.select(BibleReference.parse('Romans 3:30-4:4')!)!,
        translationName: 'WEB',
        translationShort: 'WEB',
        copyright: '',
        onVerseTap: taps.add,
      )));
      _tapVerse(tester, '31');
      _tapVerse(tester, '2-3');
      expect(taps, ['4', '3:31', '4:2']);
    });

    testWidgets('verse numbers are plain text without a tap callback',
        (tester) async {
      await tester.pumpWidget(_app(BiblePassageView(
        chapters: web.select(BibleReference.parse('Romans 3:1-8')!)!,
        translationName: 'WEB',
        translationShort: 'WEB',
        copyright: '',
      )));
      expect(_verseSpan(tester, '4').recognizer, isNull);
    });

    testWidgets('draws in dark mode', (tester) async {
      await tester.pumpWidget(_app(
          BiblePassageView(
            chapters: web.select(BibleReference.parse('Psalm 3')!)!,
            translationName: 'WEB',
            translationShort: 'WEB',
            copyright: '',
          ),
          brightness: Brightness.dark));
      expect(find.text('A Psalm by David.'), findsOneWidget);
    });
  });

  group('VerseContainer', () {
    testWidgets('shows a downloaded translation natively', (tester) async {
      final service = _FakeService(downloaded: {'web': web});
      final List<String> taps = [];
      await tester.pumpWidget(_app(VerseContainer(
        passage: 'Romans 3:1-8',
        translation: Translation.web,
        bibleTextService: service,
        onTranslationTap: () {},
        onVerseTap: taps.add,
      )));
      await tester.pump();
      expect(find.byType(BiblePassageView), findsOneWidget);
      expect(find.text('World English Bible'.toUpperCase()), findsOneWidget);
      _tapVerse(tester, '5');
      expect(taps, ['5']);
    });

    testWidgets('localized book names from the text parse too', (tester) async {
      final service = _FakeService(downloaded: {'web': web});
      await tester.pumpWidget(_app(VerseContainer(
        passage: 'Romanos 4',
        translation: Translation.web,
        bibleTextService: service,
      )));
      await tester.pump();
      expect(find.text('Romanos 4'), findsOneWidget);
    });

    testWidgets('offline-only translation: download prompt, then the text',
        (tester) async {
      final BibleText blivre =
          BibleText.fromJson(sampleBibleJson(code: 'blivre'));
      // Auto-download fails (offline), so the prompt stays.
      final service = _FakeService(downloaded: {}, server: {});
      await tester.pumpWidget(_app(VerseContainer(
        passage: 'Romans 3',
        translation: Translation.blivre,
        bibleTextService: service,
      )));
      await tester.pump();
      expect(service.downloads, 1);
      expect(find.byType(BiblePassageView), findsNothing);
      expect(find.text('Download BLIVRE'), findsOneWidget);
      // CC BY attribution is shown with the prompt.
      expect(find.text(Translation.blivre.attribution!), findsOneWidget);

      // Back online: the button downloads and shows the passage.
      service.server['blivre'] = blivre;
      await tester.tap(find.text('Download for offline'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(BiblePassageView), findsOneWidget);
      expect(find.text('Public Domain.', skipOffstage: false), findsOneWidget);
    });

    testWidgets('offline-only translation without the passage says so',
        (tester) async {
      final service = _FakeService(downloaded: {
        'blivre': BibleText.fromJson(sampleBibleJson(code: 'blivre')),
      });
      await tester.pumpWidget(_app(VerseContainer(
        passage: 'John 3',
        translation: Translation.blivre,
        bibleTextService: service,
      )));
      await tester.pump();
      expect(find.byType(BiblePassageView), findsNothing);
      expect(find.textContaining('couldn’t be found', findRichText: true),
          findsNothing);
      expect(find.textContaining("couldn't be found"), findsOneWidget);
    });
  });
}
