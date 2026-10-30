import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/common/fold_posture.dart';
import 'package:homiletics/common/vertical_bar.dart';
import 'package:homiletics/components/editor/fold_aware_split.dart';
import 'package:split_view/split_view.dart';

const Size _window = Size(800, 600);

DisplayFeature _verticalFold(DisplayFeatureState state) => DisplayFeature(
    bounds: const Rect.fromLTRB(400, 0, 400, 600),
    type: DisplayFeatureType.fold,
    state: state);

DisplayFeature _horizontalFold(DisplayFeatureState state) => DisplayFeature(
    bounds: const Rect.fromLTRB(0, 350, 800, 350),
    type: DisplayFeatureType.fold,
    state: state);

const DisplayFeature _hinge = DisplayFeature(
    bounds: Rect.fromLTRB(390, 0, 410, 600),
    type: DisplayFeatureType.hinge,
    state: DisplayFeatureState.postureFlat);

/// Counts how often it's created, to prove a pane keeps its state.
class _Pane extends StatefulWidget {
  final String label;
  static final Map<String, int> created = {};

  const _Pane(this.label, {Key? key}) : super(key: key);

  @override
  State<_Pane> createState() => _PaneState();
}

class _PaneState extends State<_Pane> {
  @override
  void initState() {
    super.initState();
    _Pane.created[widget.label] = (_Pane.created[widget.label] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(child: Text(widget.label));
}

void main() {
  group('FoldPosture.fromDisplayFeatures', () {
    test('no features or a flat fold is flat', () {
      expect(FoldPosture.fromDisplayFeatures(const []).isFlat, isTrue);
      expect(
          FoldPosture.fromDisplayFeatures(
              [_verticalFold(DisplayFeatureState.postureFlat)]).isFlat,
          isTrue);
    });

    test('a half-opened vertical fold is a book', () {
      final FoldPosture p = FoldPosture.fromDisplayFeatures(
          [_verticalFold(DisplayFeatureState.postureHalfOpened)]);
      expect(p.kind, FoldPostureKind.book);
      expect(p.bounds, const Rect.fromLTRB(400, 0, 400, 600));
    });

    test('a half-opened horizontal fold is a tabletop', () {
      expect(
          FoldPosture.fromDisplayFeatures(
              [_horizontalFold(DisplayFeatureState.postureHalfOpened)]).kind,
          FoldPostureKind.tabletop);
    });

    test('a physical hinge counts even when flat', () {
      expect(
          FoldPosture.fromDisplayFeatures([_hinge]).kind, FoldPostureKind.book);
    });

    test('cutouts are ignored', () {
      expect(
          FoldPosture.fromDisplayFeatures(const [
            DisplayFeature(
                bounds: Rect.fromLTRB(380, 0, 420, 30),
                type: DisplayFeatureType.cutout,
                state: DisplayFeatureState.unknown),
          ]).isFlat,
          isTrue);
    });
  });

  group('HingeFeatures events', () {
    test('reads a half-opened fold', () {
      final DisplayFeature? f = HingeFeatures.featureFromEvent({
        'fold': {
          'type': 'fold',
          'state': 'halfOpened',
          'left': 412.0,
          'top': 0,
          'right': 412.0,
          'bottom': 951,
        },
      });
      expect(f, isNotNull);
      expect(f!.bounds, const Rect.fromLTRB(412, 0, 412, 951));
      expect(f.type, DisplayFeatureType.fold);
      expect(f.state, DisplayFeatureState.postureHalfOpened);
      expect(FoldPosture.fromDisplayFeatures([f]).kind, FoldPostureKind.book);
    });

    test('null and malformed events mean no fold', () {
      expect(HingeFeatures.featureFromEvent(null), isNull);
      expect(
          HingeFeatures.featureFromEvent({
            'fold': {'type': 'fold'}
          }),
          isNull);
      expect(HingeFeatures.featureFromEvent('flat'), isNull);
      expect(HingeFeatures.featureFromEvent(<String, Object?>{}), isNull);
    });

    test('reads the vertical bar', () {
      final VerticalBar? bar = HingeFeatures.barFromEvent({
        'bar': {
          'side': 'right',
          'left': 740.0,
          'top': 20,
          'right': 800,
          'bottom': 580,
        },
      });
      expect(bar, isNotNull);
      expect(bar!.rect, const Rect.fromLTRB(740, 20, 800, 580));
      expect(bar.side, AxisDirection.right);
      expect(bar.cornerLeft, 0, reason: 'older bridges send no corners');
      expect(
          HingeFeatures.barFromEvent({
            'bar': {
              'side': 'right',
              'left': 740.0,
              'top': 0,
              'right': 800,
              'bottom': 600,
              'cornerLeft': 34.5,
              'cornerRight': 12,
            },
          })!
              .cornerLeft,
          34.5);
      expect(HingeFeatures.barFromEvent({'fold': null}), isNull);
      expect(HingeFeatures.barFromEvent(null), isNull);
    });
  });

  group('FoldAwareSplit', () {
    late SplitViewController controller;
    final GlobalKey firstKey = GlobalKey();
    final GlobalKey secondKey = GlobalKey();

    setUp(() {
      _Pane.created.clear();
      controller = SplitViewController(weights: [0.3, 0.7]);
    });

    Widget app(List<DisplayFeature> features, {double header = 0}) {
      final Widget first =
          KeyedSubtree(key: firstKey, child: const _Pane('verses'));
      final Widget second =
          KeyedSubtree(key: secondKey, child: const _Pane('study'));
      return MediaQuery(
        data: MediaQueryData(size: _window, displayFeatures: features),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(children: [
            SizedBox(height: header),
            Expanded(
              child: FoldAwareSplit(
                first: first,
                second: second,
                startFraction: (_) => controller.weights[0] ?? 0.3,
                flat: (context) => SplitView(
                  controller: controller,
                  viewMode: SplitViewMode.Horizontal,
                  children: [first, second],
                ),
              ),
            ),
          ]),
        ),
      );
    }

    Future<void> pump(WidgetTester tester, Widget widget) async {
      tester.view.physicalSize = _window;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    }

    testWidgets('flat: the draggable split, untouched', (tester) async {
      await pump(tester, app(const []));
      expect(find.byType(SplitView), findsOneWidget);
    });

    testWidgets('book fold: side by side, split at the fold', (tester) async {
      await pump(
          tester, app([_verticalFold(DisplayFeatureState.postureHalfOpened)]));
      expect(find.byType(SplitView), findsNothing);
      expect(tester.getRect(find.byKey(firstKey)),
          const Rect.fromLTRB(0, 0, 400, 600));
      expect(tester.getRect(find.byKey(secondKey)),
          const Rect.fromLTRB(400, 0, 800, 600));
    });

    testWidgets('tabletop fold: stacked, measured from this widget',
        (tester) async {
      await pump(
          tester,
          app([_horizontalFold(DisplayFeatureState.postureHalfOpened)],
              header: 100));
      // The fold is at y = 350 in the window, 250 into the split area.
      expect(tester.getRect(find.byKey(firstKey)),
          const Rect.fromLTRB(0, 100, 800, 350));
      expect(tester.getRect(find.byKey(secondKey)),
          const Rect.fromLTRB(0, 350, 800, 600));
    });

    testWidgets('physical hinge: nothing drawn under it', (tester) async {
      await pump(tester, app(const [_hinge]));
      expect(tester.getRect(find.byKey(firstKey)).right, 390);
      expect(tester.getRect(find.byKey(secondKey)).left, 410);
    });

    testWidgets('a fold near the edge is ignored', (tester) async {
      await pump(
          tester,
          app(const [
            DisplayFeature(
                bounds: Rect.fromLTRB(40, 0, 40, 600),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened),
          ]));
      expect(find.byType(SplitView), findsOneWidget);
    });

    testWidgets('opening flat restores the divider and keeps pane state',
        (tester) async {
      await pump(tester, app(const []));
      await pump(
          tester, app([_verticalFold(DisplayFeatureState.postureHalfOpened)]));
      expect(tester.getRect(find.byKey(firstKey)).right, 400);
      await pump(tester, app(const []));

      expect(find.byType(SplitView), findsOneWidget);
      expect(controller.weights[0], closeTo(0.3, 1e-9));
      expect(_Pane.created, {'verses': 1, 'study': 1});
    });
  });
}
