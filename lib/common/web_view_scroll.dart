import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Scrolls an embedded web view from mouse-wheel and trackpad gestures.
///
/// On macOS a web view gets the mouse and trackpad straight from AppKit,
/// except where Flutter paints over it (see the verse panel's border);
/// there the events reach Flutter instead. This catches those and scrolls
/// the page from JavaScript — [WebViewController.scrollBy] scrolls a
/// UIScrollView, which macOS's WKWebView doesn't have. On other platforms
/// it passes [child] through unchanged (touch scrolling already works).
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
    controller
        .runJavaScript('window.scrollBy($dx, $dy);')
        .catchError((Object _) {});
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
