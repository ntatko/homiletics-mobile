import 'package:flutter/material.dart';
import 'package:homiletics/common/fold_posture.dart';

/// Splits [first] and [second] at a foldable's fold while it's half open
/// (or at a physical hinge): side by side for a book fold, [first] on the
/// left; stacked for a tabletop fold, [first] on top. The panes can't be
/// resized there — a divider across the crease would only get in the way.
///
/// Otherwise, or when the fold doesn't cross this widget with room for both
/// panes, it shows [flat] (the usual draggable split) untouched, so the
/// user's divider position comes back when the device is opened flat.
class FoldAwareSplit extends StatefulWidget {
  /// The verse panel: left of a book fold, above a tabletop fold.
  final Widget first;

  /// The study pane, on the other side of the fold.
  final Widget second;

  /// The layout when there's no fold to split at. Must contain [first] and
  /// [second] (keep them under GlobalKeys so their state survives a switch).
  final WidgetBuilder flat;

  /// Where [first] ends, as a share of the split direction, when snapping
  /// starts; the panes animate from here to the fold.
  final double Function(Axis direction) startFraction;

  /// The smallest share each pane may get; a fold closer to an edge than
  /// this isn't used.
  final double minFirst;
  final double minSecond;

  /// Overrides [FoldPosture.of] (tests).
  final FoldPosture? posture;

  const FoldAwareSplit({
    Key? key,
    required this.first,
    required this.second,
    required this.flat,
    required this.startFraction,
    this.minFirst = 0.12,
    this.minSecond = 0.2,
    this.posture,
  }) : super(key: key);

  @override
  State<FoldAwareSplit> createState() => _FoldAwareSplitState();
}

class _FoldAwareSplitState extends State<FoldAwareSplit> {
  static const Duration _snapDuration = Duration(milliseconds: 220);

  /// This widget's top-left corner in window coordinates (the fold's
  /// bounds are in window coordinates), measured after each frame.
  Offset? _origin;

  void _measureOrigin() {
    if (!mounted) return;
    final RenderObject? box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final Offset origin = box.localToGlobal(Offset.zero);
    if (origin != _origin) setState(() => _origin = origin);
  }

  @override
  Widget build(BuildContext context) {
    final FoldPosture posture = widget.posture ?? FoldPosture.of(context);
    if (posture.isFlat) return widget.flat(context);

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureOrigin());

    return LayoutBuilder(builder: (context, constraints) {
      final Size size = constraints.biggest;
      final Axis direction = posture.kind == FoldPostureKind.book
          ? Axis.horizontal
          : Axis.vertical;
      final bool horizontal = direction == Axis.horizontal;
      final double extent = horizontal ? size.width : size.height;
      final double start = widget.startFraction(direction);

      // Until this widget's position is known, hold at the start fraction;
      // the panes then slide to the fold.
      double target = start;
      double gap = 0;
      final Offset? origin = _origin;
      final Rect bounds = posture.bounds!;
      if (origin != null && extent > 0) {
        final double foldStart =
            (horizontal ? bounds.left - origin.dx : bounds.top - origin.dy);
        final double foldEnd =
            (horizontal ? bounds.right - origin.dx : bounds.bottom - origin.dy);
        final bool fits = foldStart >= extent * widget.minFirst &&
            extent - foldEnd >= extent * widget.minSecond;
        if (!fits) return widget.flat(context);
        target = foldStart / extent;
        gap = foldEnd - foldStart;
      }

      return TweenAnimationBuilder<double>(
        key: ValueKey(posture.kind),
        tween: Tween(begin: start, end: target),
        duration: _snapDuration,
        curve: Curves.easeOutCubic,
        builder: (context, fraction, _) {
          final double firstExtent = fraction * extent;
          final double secondStart = firstExtent + gap;
          return Stack(children: [
            Positioned(
              left: 0,
              top: 0,
              width: horizontal ? firstExtent : size.width,
              height: horizontal ? size.height : firstExtent,
              child: widget.first,
            ),
            Positioned(
              left: horizontal ? secondStart : 0,
              top: horizontal ? 0 : secondStart,
              right: 0,
              bottom: 0,
              child: widget.second,
            ),
          ]);
        },
      );
    });
  }
}
