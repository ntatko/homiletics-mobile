import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:homiletics/common/vertical_bar.dart';

/// How a foldable is being held, as far as the editor layout cares.
enum FoldPostureKind {
  /// No fold to work around: a regular screen, or a foldable opened flat.
  flat,

  /// Half open like a book: the fold runs top to bottom.
  book,

  /// Half open like a laptop: the fold runs across the middle.
  tabletop,
}

/// Where the fold is and how the device is held.
///
/// Built from [MediaQueryData.displayFeatures], which Flutter fills in on
/// Android. On iOS, [HingeFeatures] feeds the same list from a platform
/// channel, so this class doesn't care which platform it's on.
@immutable
class FoldPosture {
  final FoldPostureKind kind;

  /// The fold or hinge, in the same logical-pixel, whole-window coordinates
  /// as [DisplayFeature.bounds]. Null when [kind] is flat.
  final Rect? bounds;

  const FoldPosture._(this.kind, this.bounds);

  static const FoldPosture flat = FoldPosture._(FoldPostureKind.flat, null);

  bool get isFlat => kind == FoldPostureKind.flat;

  /// A fold or hinge the layout should split at: half open, or a hinge with
  /// physical width (which content must never straddle, even when flat).
  /// Cutouts (camera notches) never count.
  static FoldPosture fromDisplayFeatures(Iterable<DisplayFeature> features) {
    for (final DisplayFeature feature in features) {
      if (feature.type == DisplayFeatureType.cutout ||
          feature.type == DisplayFeatureType.unknown) {
        continue;
      }
      final Rect b = feature.bounds;
      final bool runsTopToBottom = b.height >= b.width;
      final double thickness = runsTopToBottom ? b.width : b.height;
      final bool halfOpened =
          feature.state == DisplayFeatureState.postureHalfOpened;
      final bool physicalHinge =
          feature.type == DisplayFeatureType.hinge && thickness > 0;
      if (!halfOpened && !physicalHinge) continue;
      return FoldPosture._(
          runsTopToBottom ? FoldPostureKind.book : FoldPostureKind.tabletop, b);
    }
    return flat;
  }

  static FoldPosture of(BuildContext context) =>
      fromDisplayFeatures(MediaQuery.displayFeaturesOf(context));

  @override
  bool operator ==(Object other) =>
      other is FoldPosture && other.kind == kind && other.bounds == bounds;

  @override
  int get hashCode => Object.hash(kind, bounds);
}

/// Adds the iPhone Duo's fold to [MediaQueryData.displayFeatures], which
/// Flutter only fills in on Android, so [FoldPosture] (and Flutter's own
/// dialogs, which already keep off a hinge) work the same on both; and
/// shares where the Duo wants an app's bars as a [VerticalBar].
///
/// Platform channel contract (ios/Runner/HingeBridge.swift, iOS 27.1+):
///
/// * MethodChannel `homiletics/hinge`, method `isSupported` → `bool`. The
///   app only listens when this returns true, so a missing bridge is silent
///   (no MissingPluginException reaches the error reporter).
/// * EventChannel `homiletics/hinge/events` sends `null` or a map with
///   either or both of
///   - `fold`: `{'type': 'fold' | 'hinge', 'state': 'flat' | 'halfOpened',
///     'left', 'top', 'right', 'bottom'}` — the fold's rectangle;
///   - `bar`: `{'side': 'left' | 'right', 'left', 'top', 'right',
///     'bottom', 'cornerLeft', 'cornerRight'}` — where the vertical bar
///     goes, when the system uses one, and how far a top row must start
///     from each side to clear the screen's rounded corners;
///   rectangles in logical points in the Flutter view's coordinates (the
///   same space as [MediaQueryData.size]). An event comes on every change,
///   and the current state as soon as a listener subscribes.
class HingeFeatures extends StatefulWidget {
  final Widget child;

  const HingeFeatures({Key? key, required this.child}) : super(key: key);

  static const MethodChannel _methods = MethodChannel('homiletics/hinge');
  static const EventChannel _events = EventChannel('homiletics/hinge/events');

  static Rect? _rect(Object? map) {
    if (map is! Map) return null;
    double? number(String key) => (map[key] as num?)?.toDouble();
    final double? left = number('left'), top = number('top');
    final double? right = number('right'), bottom = number('bottom');
    if (left == null || top == null || right == null || bottom == null) {
      return null;
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// The fold in one channel event, or null for none or a malformed event.
  static DisplayFeature? featureFromEvent(Object? event) {
    final Object? fold = event is Map ? event['fold'] : null;
    final Rect? bounds = _rect(fold);
    if (fold is! Map || bounds == null) return null;
    return DisplayFeature(
      bounds: bounds,
      type: fold['type'] == 'hinge'
          ? DisplayFeatureType.hinge
          : DisplayFeatureType.fold,
      state: fold['state'] == 'halfOpened'
          ? DisplayFeatureState.postureHalfOpened
          : DisplayFeatureState.postureFlat,
    );
  }

  /// The vertical bar in one channel event, or null for none.
  static VerticalBar? barFromEvent(Object? event) {
    final Object? bar = event is Map ? event['bar'] : null;
    final Rect? rect = _rect(bar);
    if (bar is! Map || rect == null || rect.isEmpty) return null;
    return VerticalBar(
      rect: rect,
      side: bar['side'] == 'left' ? AxisDirection.left : AxisDirection.right,
      cornerLeft: (bar['cornerLeft'] as num?)?.toDouble() ?? 0,
      cornerRight: (bar['cornerRight'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  State<HingeFeatures> createState() => _HingeFeaturesState();
}

class _HingeFeaturesState extends State<HingeFeatures> {
  StreamSubscription<Object?>? _subscription;
  DisplayFeature? _feature;
  VerticalBar? _bar;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isIOS) _listen();
  }

  Future<void> _listen() async {
    bool supported = false;
    try {
      supported =
          await HingeFeatures._methods.invokeMethod<bool>('isSupported') ??
              false;
    } catch (_) {
      // No bridge on this build or OS version.
    }
    if (!supported || !mounted) return;
    _subscription = HingeFeatures._events.receiveBroadcastStream().listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _feature = HingeFeatures.featureFromEvent(event);
          _bar = HingeFeatures.barFromEvent(event);
        });
      },
      onError: (Object _) {
        if (mounted) {
          setState(() {
            _feature = null;
            _bar = null;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = VerticalBarScope(bar: _bar, child: widget.child);
    final DisplayFeature? feature = _feature;
    if (feature == null) return child;
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data:
          media.copyWith(displayFeatures: [...media.displayFeatures, feature]),
      child: child,
    );
  }
}
