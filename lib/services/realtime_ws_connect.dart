import 'package:web_socket_channel/web_socket_channel.dart';

import 'realtime_ws_connect_io.dart'
    if (dart.library.html) 'realtime_ws_connect_web.dart' as impl;

/// Opens a WebSocket to [uri]. On IO this awaits the handshake so errors are
/// catchable; on web uses [WebSocketChannel.connect].
Future<WebSocketChannel> connectRealtimeWebSocket(Uri uri) =>
    impl.connectRealtimeWebSocket(uri);
