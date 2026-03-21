import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:homiletics/config/sync_config.dart';
import 'package:homiletics/services/auth_storage.dart';
import 'package:homiletics/services/realtime_ws_connect.dart';
import 'package:homiletics/services/sync_api_client.dart';
import 'package:homiletics/services/sync_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void _realtimeLog(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'homiletics.realtime',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('[homiletics.realtime] $message${error != null ? ' | $error' : ''}');
}

/// WebSocket client for real-time sync: when the server has new backup data
/// it sends sync_updated; we pull. Connect when signed in, reconnect with backoff.
///
/// If the socket is unavailable (e.g. proxy returns 404 for `/sync/stream`),
/// we still sync periodically over HTTP ([SyncService.pullIfSignedIn]) until
/// the socket authenticates successfully.
class RealtimeSyncClient {
  RealtimeSyncClient._();
  static final RealtimeSyncClient instance = RealtimeSyncClient._();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _fallbackPollTimer;
  int _backoffSeconds = 1;
  static const int _maxBackoffSeconds = 30;
  static const Duration _fallbackPollInterval = Duration(seconds: 90);
  bool _intentionalClose = false;
  bool _connecting = false;
  /// True after server sends `auth_ok` on the current socket.
  bool _socketAuthed = false;

  /// Build WSS/WS URL from [syncApiBaseUrl] (handles trailing path segments).
  static Uri get _wsUri {
    final u = Uri.parse(syncApiBaseUrl.trim());
    final scheme = u.scheme == 'https'
        ? 'wss'
        : u.scheme == 'http'
            ? 'ws'
            : 'wss';
    final path = (u.path.isEmpty || u.path == '/')
        ? '/sync/stream'
        : (u.path.endsWith('/')
            ? '${u.path}sync/stream'
            : '${u.path}/sync/stream');
    return Uri(
      scheme: scheme,
      host: u.host,
      port: u.hasPort ? u.port : null,
      path: path,
    );
  }

  /// Start connecting if signed in. No-op if already connected or connecting.
  Future<void> start() async {
    final signedIn = await isSignedIn;
    if (!signedIn) {
      _realtimeLog('start: skip (not signed in)');
      return;
    }
    if (_channel != null) {
      _realtimeLog('start: skip (already have channel, authed=$_socketAuthed)');
      return;
    }
    if (_connecting) {
      _realtimeLog('start: skip (connect already in progress)');
      return;
    }
    _intentionalClose = false;
    _realtimeLog('start: connecting to $_wsUri');
    await _connect();
  }

  /// Disconnect and stop reconnect attempts (e.g. on sign out).
  void stop() {
    _realtimeLog('stop: closing socket and timers');
    _intentionalClose = true;
    _socketAuthed = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopFallbackPolling();
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _connecting = false;
    _backoffSeconds = 1;
  }

  void _clearChannel() {
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _socketAuthed = false;
  }

  /// HTTP polling while the realtime channel is down or not yet authenticated.
  void _ensureFallbackPolling() {
    if (_intentionalClose) return;
    if (_fallbackPollTimer != null) return;
    _realtimeLog(
      'fallback poll: starting (interval ${_fallbackPollInterval.inSeconds}s) — '
      'HTTP pull until websocket auth_ok',
    );
    // One immediate pull, then periodic while WS is not healthy.
    SyncService.instance.pullIfSignedIn().catchError((_, __) {});
    _fallbackPollTimer =
        Timer.periodic(_fallbackPollInterval, (_) {
      if (_intentionalClose) return;
      if (_socketAuthed && _channel != null) return;
      _realtimeLog('fallback poll: tick → pullIfSignedIn');
      SyncService.instance.pullIfSignedIn().catchError((_, __) {});
    });
  }

  void _stopFallbackPolling() {
    if (_fallbackPollTimer != null) {
      _realtimeLog('fallback poll: stopped (websocket healthy)');
    }
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = null;
  }

  Future<void> _connect() async {
    if (_intentionalClose) {
      _realtimeLog('_connect: skip (intentional close)');
      return;
    }
    if (_connecting) {
      _realtimeLog('_connect: skip (already connecting)');
      return;
    }
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      _realtimeLog('_connect: skip (no access token)');
      return;
    }

    _connecting = true;
    _realtimeLog(
      '_connect: handshake begin → $_wsUri (next reconnect backoff: ${_backoffSeconds}s)',
    );
    try {
      _ensureFallbackPolling();

      final channel = await connectRealtimeWebSocket(_wsUri);
      if (_intentionalClose) {
        try {
          channel.sink.close();
        } catch (_) {}
        _realtimeLog('_connect: aborted after open (intentional close)');
        return;
      }

      _clearChannel();
      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: _onSocketError,
        cancelOnError: false,
      );

      channel.sink.add(jsonEncode({
        'type': 'auth',
        'access_token': token,
      }));
      _backoffSeconds = 1;
      _realtimeLog('_connect: socket open, auth message sent (await auth_ok)');
    } catch (e, st) {
      _realtimeLog(
        '_connect: handshake failed',
        error: e,
        stackTrace: st,
      );
      _clearChannel();
      if (!_intentionalClose) {
        _ensureFallbackPolling();
        _scheduleReconnect();
      }
    } finally {
      _connecting = false;
    }
  }

  static int _syncUpdatedLogCount = 0;

  void _onMessage(dynamic data) {
    Map<String, dynamic>? msg;
    try {
      final s = data is String ? data : data.toString();
      msg = jsonDecode(s) as Map<String, dynamic>?;
    } catch (_) {
      _realtimeLog('onMessage: skip (non-JSON frame)');
      return;
    }
    final type = msg!['type']?.toString();
    if (type == 'auth_error') {
      _realtimeLog('onMessage: auth_error → try refresh + reconnect');
      _recoverFromAuthError().catchError((Object e, StackTrace st) {
        _realtimeLog(
          '_recoverFromAuthError failed',
          error: e,
          stackTrace: st,
        );
      });
      return;
    }
    if (type == 'auth_ok') {
      _socketAuthed = true;
      _realtimeLog('onMessage: auth_ok → stop fallback poll + catch-up pull');
      _stopFallbackPolling();
      // HTTP pull may have raced with reconnect; ensure we did not miss ops.
      SyncService.instance.pullIfSignedIn().catchError((_, __) {});
      return;
    }
    if (type == 'sync_updated') {
      _syncUpdatedLogCount++;
      if (_syncUpdatedLogCount <= 5 || _syncUpdatedLogCount % 20 == 0) {
        _realtimeLog(
          'onMessage: sync_updated → pullIfSignedIn (#$_syncUpdatedLogCount)',
        );
      }
      SyncService.instance.pullIfSignedIn();
      return;
    }
    if (type == 'sync_ops') {
      final ops = msg['ops'];
      if (ops is List<dynamic> && ops.isNotEmpty) {
        _realtimeLog('onMessage: sync_ops (${ops.length} ops)');
        SyncService.instance.applyRemoteOps(ops).catchError((Object e, StackTrace st) {
          _realtimeLog('applyRemoteOps failed', error: e, stackTrace: st);
        });
      }
    }
  }

  void _onDone() {
    _realtimeLog('onDone: socket closed → fallback + scheduleReconnect');
    _clearChannel();
    if (!_intentionalClose) {
      _ensureFallbackPolling();
      _scheduleReconnect();
    }
  }

  void _onSocketError(Object error, StackTrace stackTrace) {
    _realtimeLog(
      'onError: socket error → fallback + scheduleReconnect',
      error: error,
      stackTrace: stackTrace,
    );
    _clearChannel();
    if (!_intentionalClose) {
      _ensureFallbackPolling();
      _scheduleReconnect();
    }
  }

  Future<void> _recoverFromAuthError() async {
    if (_intentionalClose) return;
    _clearChannel();
    final ok = await SyncApiClient().tryRefreshTokens();
    if (!ok) {
      await clearTokens();
      stop();
      return;
    }
    _backoffSeconds = 1;
    await _connect();
  }

  void _scheduleReconnect() {
    if (_intentionalClose) return;
    final delay = _backoffSeconds;
    _realtimeLog('reconnect: timer scheduled in ${delay}s');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _reconnectTimer = null;
      if (_intentionalClose) return;
      _realtimeLog('reconnect: timer fired → _connect()');
      _connect().catchError((Object e, StackTrace st) {
        _realtimeLog(
          '_connect future error after timer',
          error: e,
          stackTrace: st,
        );
      });
      if (_backoffSeconds < _maxBackoffSeconds) {
        _backoffSeconds = _backoffSeconds * 2;
        if (_backoffSeconds > _maxBackoffSeconds) {
          _backoffSeconds = _maxBackoffSeconds;
        }
      }
    });
  }
}
