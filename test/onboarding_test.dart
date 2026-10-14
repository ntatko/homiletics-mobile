import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/l10n/generated/app_localizations.dart';
import 'package:homiletics/pages/onboarding/onboarding_launcher.dart';
import 'package:homiletics/pages/onboarding/onboarding_page.dart';
import 'package:homiletics/pages/settings_page.dart';
import 'package:homiletics/services/suggested_passages_repository.dart';
import 'package:homiletics/theme/app_theme.dart';

final PassageSchedule _week = PassageSchedule(
  passage: 'John 3:1-21',
  rollout: DateTime(2026, 10, 5),
  lesson: 'BSF John #6',
  study: 'https://www.bsfinternational.org/john',
);

Future<PassageSchedule?> _noWeek() async => null;
Future<PassageSchedule?> _someWeek() async => _week;

Widget _app(
  Widget home, {
  Locale locale = const Locale('en'),
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: [for (final l in Language.all) l.locale],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: buildAppTheme(brightness),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
}

/// A screen with one button that opens the guide through [showOnboarding],
/// as Home does.
class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => showOnboarding(context, loadThisWeek: _noWeek),
            child: const Text('open'),
          ),
        ),
      );
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Steps through every page with Next, failing on any layout overflow.
Future<void> _walkAllPages(WidgetTester tester) async {
  for (int page = 0; page < OnboardingPage.pageCount; page++) {
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'page ${page + 1}');
    final Finder next = find.byKey(const ValueKey('onboardingNext'));
    if (page < OnboardingPage.pageCount - 1) {
      expect(next, findsOneWidget);
      await tester.tap(next);
    } else {
      expect(next, findsNothing);
    }
  }
  expect(find.byKey(const ValueKey('onboardingExplore')), findsOneWidget);
}

/// Lets route transitions finish on a screen that never settles.
Future<void> _pumpFor(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    final Directory dir =
        await Directory.systemTemp.createTemp('homiletics_onboarding_test');
    Hive.init(dir.path);
    await Preferences.init();
    await SuggestedPassagesRepository.init();
  });

  setUp(() {
    Preferences.hasSeenOnboarding = false;
    Preferences.hasSeenTranscriptionPrompt = false;
    Preferences.hasSeenFormattingPrompt = false;
  });

  group('layout', () {
    const List<Size> sizes = [
      Size(320, 640),
      Size(390, 844),
      Size(640, 320), // small phone, landscape
      Size(844, 390),
    ];
    for (final Size size in sizes) {
      for (final double scale in [1.0, 1.3]) {
        testWidgets('no overflow at ${size.width}x${size.height}, text $scale',
            (tester) async {
          _setSize(tester, size);
          await tester.pumpWidget(_app(
              const OnboardingPage(loadThisWeek: _someWeek),
              textScale: scale));
          await _walkAllPages(tester);
          expect(find.byKey(const ValueKey('onboardingStartThisWeek')),
              findsOneWidget);
        });
      }
    }

    for (final Language language in Language.all) {
      testWidgets('no overflow in ${language.name} at 320x640, text 1.3',
          (tester) async {
        _setSize(tester, const Size(320, 640));
        await tester.pumpWidget(_app(
            const OnboardingPage(loadThisWeek: _someWeek),
            locale: language.locale,
            textScale: 1.3));
        await _walkAllPages(tester);
      });
    }

    testWidgets('dark theme renders', (tester) async {
      _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const OnboardingPage(loadThisWeek: _noWeek),
          brightness: Brightness.dark));
      await _walkAllPages(tester);
    });
  });

  testWidgets('shows the six steps with their names', (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app(const OnboardingPage(loadThisWeek: _noWeek)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboardingNext')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboardingNext')));
    await tester.pumpAndSettle();
    for (final String name in [
      'Content',
      'Divisions',
      'Summary sentence',
      'FCF',
      'Aim',
      'Application'
    ]) {
      expect(find.text(name), findsOneWidget);
    }
    // Back returns to the previous page.
    await tester.tap(find.byKey(const ValueKey('onboardingBack')));
    await tester.pumpAndSettle();
    expect(find.text('What is a homiletic?'), findsOneWidget);
  });

  testWidgets('Skip closes the guide and marks it seen', (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app(const _Launcher()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(Preferences.hasSeenOnboarding, isFalse);

    await tester.tap(find.byKey(const ValueKey('onboardingSkip')));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsNothing);
    expect(Preferences.hasSeenOnboarding, isTrue);
  });

  testWidgets('Explore on my own closes and marks seen', (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app(const _Launcher()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    for (int i = 0; i < OnboardingPage.pageCount - 1; i++) {
      await tester.tap(find.byKey(const ValueKey('onboardingNext')));
      await tester.pumpAndSettle();
    }
    // No passage: no start button, only explore.
    expect(find.byKey(const ValueKey('onboardingStartThisWeek')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('onboardingExplore')));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsNothing);
    expect(Preferences.hasSeenOnboarding, isTrue);
  });

  testWidgets('Start this week pops with the English passage', (tester) async {
    _setSize(tester, const Size(390, 844));
    String? result = 'unset';
    await tester.pumpWidget(_app(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            result = await Navigator.of(context).push<String>(
              MaterialPageRoute<String>(
                builder: (_) => const OnboardingPage(loadThisWeek: _someWeek),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    for (int i = 0; i < OnboardingPage.pageCount - 1; i++) {
      await tester.tap(find.byKey(const ValueKey('onboardingNext')));
      await tester.pumpAndSettle();
    }
    expect(find.text('This week: John 3:1-21'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('onboardingStartThisWeek')));
    await tester.pumpAndSettle();
    expect(result, 'John 3:1-21');
    expect(Preferences.hasSeenOnboarding, isTrue);
  });

  testWidgets('Settings > How homiletics works reopens the guide',
      (tester) async {
    Preferences.hasSeenOnboarding = true;
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app(const SettingsPage()));
    await tester.pump();
    final Finder row = find.byKey(const ValueKey('settingsOnboarding'));
    await tester.scrollUntilVisible(row, 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('How homiletics works'), findsOneWidget);
    await tester.tap(row);
    // Settings' model rows keep a spinner going, so no pumpAndSettle.
    await _pumpFor(tester);
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Study the Bible, one passage at a time'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboardingSkip')));
    await _pumpFor(tester);
    expect(find.byType(OnboardingPage), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  group('shouldShowOnboarding', () {
    test('fresh install: shows', () async {
      expect(await shouldShowOnboarding(hasSavedStudies: () async => false),
          isTrue);
      // Not marked until the guide actually closes.
      expect(Preferences.hasSeenOnboarding, isFalse);
    });

    test('already seen: does not show or read storage', () async {
      Preferences.hasSeenOnboarding = true;
      expect(
          await shouldShowOnboarding(
              hasSavedStudies: () async => fail('should not read storage')),
          isFalse);
    });

    test('existing user with saved studies: marked seen, not shown', () async {
      expect(await shouldShowOnboarding(hasSavedStudies: () async => true),
          isFalse);
      expect(Preferences.hasSeenOnboarding, isTrue);
    });

    test('existing user who saw an earlier prompt: marked seen', () async {
      Preferences.hasSeenTranscriptionPrompt = true;
      expect(await shouldShowOnboarding(hasSavedStudies: () async => false),
          isFalse);
      expect(Preferences.hasSeenOnboarding, isTrue);
    });

    test('storage error: not shown, checked again next launch', () async {
      expect(
          await shouldShowOnboarding(
              hasSavedStudies: () async => throw Exception('db')),
          isFalse);
      expect(Preferences.hasSeenOnboarding, isFalse);
    });
  });
}
