import 'package:http/http.dart' as http;

http.Client? _client;

/// Shared [http.Client] for sync/auth API (VM / mobile / desktop).
http.Client getSyncHttpClient() {
  _client ??= http.Client();
  return _client!;
}
