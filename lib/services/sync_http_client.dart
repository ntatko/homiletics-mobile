import 'package:http/http.dart' as http;

import 'sync_http_client_io.dart'
    if (dart.library.html) 'sync_http_client_web.dart' as impl;

/// HTTP client for sync/auth: uses [BrowserClient] with credentials on web.
http.Client getSyncHttpClient() => impl.getSyncHttpClient();
