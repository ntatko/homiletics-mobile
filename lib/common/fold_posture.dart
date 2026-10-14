import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
/// dialogs, which already keep off a hinge) work the same on both.
///
/// Platform channel contract, for the iOS bridge (needs the iOS 27.1 SDK's
/// hinge API; until it exists this widget does nothing):
///
/// * MethodChannel `homiletics/hinge`, method `isSupported` → `bool`. The
///   app only listens when this returns true, so a missing bridge is silent
///   (no MissingPluginException reaches the error reporter).
/// * EventChannel `homiletics/hinge/events` sends `null` when there's no
///   fold to report (closed, or a phone without one), or a map:
///   `{'type': 'fold' | 'hinge', 'state': 'flat' | 'halfOpened',
///     'left': double, 'top': double, 'right': double, 'bottom': double}`
///   with the fold's rectangle in logical points in the Flutter view's
///   coordinates (the same space as [MediaQueryData.size]); a fold is a
///   zero-width line. Send an event on every posture change, and the
///   current state as soon as a listener subscribes.
class HingeFeatures extends StatefulWidget {
  final Widget child;

  const HingeFeatures({Key? key, required this.child}) : super(key: key);

  static const MethodChannel _methods = MethodChannel('homiletics/hinge');
  static const EventChannel _events = EventChannel('homiletics/hinge/events');

  /// Turns one channel event into a display feature, or null for none or a
  /// malformed event.
  static DisplayFeature? featureFromEvent(Object? event) {
    if (event is! Map) return null;
    double? number(String key) => (event[key] as num?)?.toDouble();
    final double? left = number('left'), top = number('top');
    final double? right = number('right'), bottom = number('bottom');
    if (left == null || top == null || right == null || bottom == null) {
      return null;
    }
    return DisplayFeature(
      bounds: Rect.fromLTRB(left, top, right, bottom),
      type: event['type'] == 'hinge'
          ? DisplayFeatureType.hinge
          : DisplayFeatureType.fold,
      state: event['state'] == 'halfOpened'
          ? DisplayFeatureState.postureHalfOpened
          : DisplayFeatureState.postureFlat,
    );
  }

  @override
  State<HingeFeatures> createState() => _HingeFeaturesState();
}

class _HingeFeaturesState extends State<HingeFeatures> {
  StreamSubscription<Object?>? _subscription;
  DisplayFeature? _feature;

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
        if (mounted) {
          setState(() => _feature = HingeFeatures.featureFromEvent(event));
        }
      },
      onError: (Object _) {
        if (mounted) setState(() => _feature = null);
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
    final DisplayFeature? feature = _feature;
    if (feature == null) return widget.child;
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data:
          media.copyWith(displayFeatures: [...media.displayFeatures, feature]),
      child: widget.child,
    );
  }
}
