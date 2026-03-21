import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

BrowserClient? _client;

/// Browser [http.Client] with credentials so **cookies** set by the sync API
/// (e.g. `Set-Cookie`) are stored and sent on later requests to that origin.
///
/// Your API must respond with CORS that allows credentialed requests when the
/// app and API are on different origins, e.g.:
/// `Access-Control-Allow-Credentials: true` and a concrete
/// `Access-Control-Allow-Origin` (not `*`).
http.Client getSyncHttpClient() {
  _client ??= BrowserClient()..withCredentials = true;
  return _client!;
}
