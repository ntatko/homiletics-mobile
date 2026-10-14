import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/pages/import_preview_page.dart';
import 'package:homiletics/services/share_link.dart';

/// The app's root navigator, so links that arrive from the OS can open
/// the import preview from outside the widget tree.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Opens share links handed to the app by the OS (universal links / App
/// Links for https://homiletics.app/view, and homiletics://view), both the
/// one that launched the app and any that arrive while it's running.
class IncomingLinks {
  IncomingLinks._();

  static StreamSubscription<Uri>? _subscription;
  static Uri? _lastUri;
  static DateTime? _lastAt;

  /// Starts listening. Safe to call more than once.
  static void start() {
    if (_subscription != null) return;
    try {
      // app_links' stream also delivers the link that launched the app.
      _subscription = AppLinks().uriLinkStream.listen(
            handle,
            onError: (Object error) => sendError(error, 'Incoming link'),
          );
    } catch (error) {
      // No plugin on this platform (e.g. tests): links just won't open.
      sendError(error, 'Incoming links: start');
    }
  }

  /// Opens [uri] if it's a share link; ignores anything else.
  static Future<void> handle(Uri uri) async {
    if (!ShareLink.isShareUri(uri)) return;
    // Some platforms report the same link twice (e.g. the launch link
    // through both the initial-link and stream paths).
    final DateTime now = DateTime.now();
    if (uri == _lastUri &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastUri = uri;
    _lastAt = now;

    final NavigatorState? navigator = await _navigator();
    if (navigator == null) return;
    await openShareLinkResult(navigator, ShareLink.decodeUri(uri));
  }

  /// Waits (briefly) for the first frame on a cold start, when the link can
  /// arrive before the navigator exists.
  static Future<NavigatorState?> _navigator() async {
    for (int i = 0; i < 50; i++) {
      final NavigatorState? navigator = appNavigatorKey.currentState;
      if (navigator != null && navigator.mounted) return navigator;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return null;
  }
}
