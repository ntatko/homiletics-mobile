import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Scrolls an embedded web view from mouse-wheel and trackpad gestures.
///
/// On macOS, Flutter doesn't forward scroll-wheel or two-finger trackpad
/// pans to platform views, so a [WebViewWidget] can't be scrolled with
/// them. This catches those events in Flutter and scrolls the page with
/// [WebViewController.scrollBy]. On other platforms it passes [child]
/// through unchanged (touch scrolling already works there).
class WebViewScrollForwarder extends StatelessWidget {
  final WebViewController controller;
  final Widget child;

  const WebViewScrollForwarder({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  static bool get _needed => !kIsWeb && Platform.isMacOS;

  void _scroll(Offset delta) {
    final int dx = delta.dx.round();
    final int dy = delta.dy.round();
    if (dx == 0 && dy == 0) return;
    controller.scrollBy(dx, dy).catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_needed) return child;
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) _scroll(event.scrollDelta);
      },
      // Trackpad two-finger pans arrive as pan/zoom updates.
      onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) =>
          _scroll(-event.panDelta),
      child: child,
    );
  }
}
