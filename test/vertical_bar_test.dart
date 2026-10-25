import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/common/vertical_bar.dart';
import 'package:homiletics/components/homiletics/too_many_summaries_dialog.dart';
import 'package:homiletics/l10n/l10n.dart';

const Size _window = Size(800, 600);

Widget _app(VerticalBar? bar) => MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
            size: _window, padding: EdgeInsets.only(top: 20)),
        child: VerticalBarScope(
          bar: bar,
          child: VerticalBarLayout(
            groups: [
              BarGroup(children: [
                IconButton(
                    key: const ValueKey('back'),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {}),
              ]),
            ],
            child: Builder(
              builder: (context) => SafeArea(
                child: Container(
                    key: const ValueKey('content'),
                    color: const Color(0xFF00FF00)),
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('without a vertical bar the screen is untouched',
      (tester) async {
    tester.view.physicalSize = _window;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(null));
    expect(find.byKey(const ValueKey('back')), findsNothing);
    expect(tester.getRect(find.byKey(const ValueKey('content'))),
        const Rect.fromLTRB(0, 20, 800, 600));
  });

  testWidgets('with one, the buttons sit in it and content keeps clear',
      (tester) async {
    tester.view.physicalSize = _window;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const Rect bar = Rect.fromLTRB(740, 20, 800, 600);
    await tester.pumpWidget(
        _app(const VerticalBar(rect: bar, side: AxisDirection.right)));
    final Rect back = tester.getRect(find.byKey(const ValueKey('back')));
    expect(bar.contains(back.center), isTrue);
    expect(back.top, lessThan(80), reason: 'Back goes at the top');
    expect(tester.getRect(find.byKey(const ValueKey('content'))),
        const Rect.fromLTRB(0, 20, 740, 600));
  });

  testWidgets('a bar on the left clears the left edge', (tester) async {
    tester.view.physicalSize = _window;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const VerticalBar(
        rect: Rect.fromLTRB(0, 0, 60, 600), side: AxisDirection.left)));
    expect(tester.getRect(find.byKey(const ValueKey('content'))).left, 60);
  });

  group('the 21st content summary', () {
    Future<bool?> ask(WidgetTester tester, String button) async {
      bool? answer;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                answer = await confirmExtraContentSummary(context, 21),
            child: const Text('add'),
          ),
        ),
      ));
      await tester.tap(find.text('add'));
      await tester.pumpAndSettle();
      expect(find.text('Bawk! Summary number 21?'), findsOneWidget);
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('can be added anyway', (tester) async {
      expect(await ask(tester, 'Add anyway'), isTrue);
    });

    testWidgets('or left out to combine summaries', (tester) async {
      expect(await ask(tester, "I'll combine some"), isFalse);
    });
  });
}
