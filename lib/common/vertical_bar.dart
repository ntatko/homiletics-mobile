import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Where the iPhone Duo wants an app's bars: a strip down one side (the
/// outer display, and the inner display in landscape), with Back or Close
/// at the top, then the screen's actions. Reported by the iOS bridge (see
/// HingeFeatures); null everywhere else, where bars stay on top.
@immutable
class VerticalBar {
  /// The strip, in window coordinates.
  final Rect rect;

  /// The edge it runs along: [AxisDirection.left] or [AxisDirection.right].
  final AxisDirection side;

  const VerticalBar({required this.rect, required this.side});

  /// The bar for [context], or null when bars should stay horizontal.
  static VerticalBar? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VerticalBarScope>()?.bar;

  @override
  bool operator ==(Object other) =>
      other is VerticalBar && other.rect == rect && other.side == side;

  @override
  int get hashCode => Object.hash(rect, side);
}

/// Provides [VerticalBar.of].
class VerticalBarScope extends InheritedWidget {
  final VerticalBar? bar;

  const VerticalBarScope({Key? key, required this.bar, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(VerticalBarScope oldWidget) => oldWidget.bar != bar;
}

/// Puts a screen's bar buttons ([groups], top first) in the [VerticalBar]
/// when there is one, keeping [child]'s content out from under it (its
/// background still runs to the edge). Without a vertical bar it's just
/// [child], which then shows its usual top bar.
class VerticalBarLayout extends StatelessWidget {
  final List<Widget> groups;
  final Widget child;

  const VerticalBarLayout({Key? key, required this.groups, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VerticalBar? bar = VerticalBar.of(context);
    if (bar == null) return child;
    final MediaQueryData media = MediaQuery.of(context);
    final bool right = bar.side == AxisDirection.right;
    // However much of the edge the bar covers, plus its own margin.
    final double inset =
        right ? media.size.width - bar.rect.left : bar.rect.right;
    EdgeInsets clear(EdgeInsets p) => right
        ? p.copyWith(right: math.max(p.right, inset))
        : p.copyWith(left: math.max(p.left, inset));
    return Stack(
      children: [
        MediaQuery(
          data: media.copyWith(
              padding: clear(media.padding),
              viewPadding: clear(media.viewPadding)),
          child: child,
        ),
        Positioned.fromRect(
          rect: bar.rect,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (int i = 0; i < groups.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  groups[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A frosted capsule of bar buttons, like the system's own bar groups but
/// in the app's colors.
class BarGroup extends StatelessWidget {
  final List<Widget> children;

  const BarGroup({Key? key, required this.children}) : super(key: key);

  static const double width = 52;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    const BorderRadius radius = BorderRadius.all(Radius.circular(width / 2));
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.78),
            borderRadius: radius,
            border: Border.all(color: c.line.withValues(alpha: 0.8)),
          ),
          child: SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        ),
      ),
    );
  }
}
