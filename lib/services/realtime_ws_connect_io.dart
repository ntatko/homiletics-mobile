import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Await handshake so failures are catchable (avoids unhandled async errors from
/// [WebSocketChannel.connect] on VM).
Future<WebSocketChannel> connectRealtimeWebSocket(Uri uri) async {
  final url = uri.toString();
  developer.log('WebSocket.connect → $url', name: 'homiletics.realtime');
  debugPrint('[homiletics.realtime] WebSocket.connect → $url');
  final socket = await WebSocket.connect(url);
  debugPrint('[homiletics.realtime] WebSocket.connect ok');
  return IOWebSocketChannel(socket);
}
