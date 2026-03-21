import 'dart:convert';

import 'package:homiletics/config/sync_config.dart';
import 'package:homiletics/services/auth_storage.dart';
import 'package:homiletics/services/sync_http_client.dart';
import 'package:http/http.dart' as http;

class SyncApiClient {
  static final SyncApiClient _instance = SyncApiClient._();
  factory SyncApiClient() => _instance;
  SyncApiClient._();

  String get _base => syncApiBaseUrl;

  static const Duration _proactiveRefreshSkew = Duration(minutes: 10);

  static Future<bool>? _ongoingRefresh;

  Future<Map<String, String>> _headers({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (includeAuth) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final sessionId = await getSessionId();
      headers['x-session-id'] = sessionId;
    }
    return headers;
  }

  Future<void> _persistAuthFromResponse(Map<String, dynamic> data) async {
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('No token in response');
    }
    await setAccessToken(token);
    final exp = (data['expires_in'] as num?)?.toInt() ?? 86400;
    await setAccessTokenExpiryFromExpiresIn(exp);
    final rt = data['refresh_token'] as String?;
    if (rt != null && rt.isNotEmpty) {
      await setRefreshToken(rt);
    }
    final user = data['user'] as Map<String, dynamic>?;
    final userEmail = user?['email'] as String?;
    if (userEmail != null) await setStoredUserEmail(userEmail);
  }

  Future<void> _maybeProactiveRefresh() async {
    final expMs = await getAccessTokenExpiresAtMs();
    if (expMs == null) return;
    final threshold = expMs - _proactiveRefreshSkew.inMilliseconds;
    if (DateTime.now().millisecondsSinceEpoch >= threshold) {
      await tryRefreshTokens();
    }
  }

  Future<bool> tryRefreshTokens() async {
    final existing = _ongoingRefresh;
    if (existing != null) return await existing;
    final fut = _doRefreshTokens();
    _ongoingRefresh = fut;
    try {
      return await fut;
    } finally {
      if (identical(_ongoingRefresh, fut)) {
        _ongoingRefresh = null;
      }
    }
  }

  Future<bool> _doRefreshTokens() async {
    final rt = await getRefreshToken();
    if (rt == null || rt.isEmpty) return false;
    try {
      final response = await getSyncHttpClient().post(
        Uri.parse('$_base/auth/refresh'),
        headers: await _headers(includeAuth: false),
        body: jsonEncode({'refresh_token': rt}),
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _persistAuthFromResponse(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _with401Retry(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    await _maybeProactiveRefresh();
    var headers = await _headers();
    var response = await send(headers);
    if (response.statusCode != 401) return response;
    final ok = await tryRefreshTokens();
    if (!ok) {
      await clearTokens();
      return response;
    }
    headers = await _headers();
    response = await send(headers);
    if (response.statusCode == 401) await clearTokens();
    return response;
  }

  Future<void> logoutOnServer() async {
    final rt = await getRefreshToken();
    if (rt == null || rt.isEmpty) return;
    try {
      await getSyncHttpClient().post(
        Uri.parse('$_base/auth/logout'),
        headers: await _headers(includeAuth: false),
        body: jsonEncode({'refresh_token': rt}),
      );
    } catch (_) {}
  }

  Future<int> requestCode(String email) async {
    final response = await getSyncHttpClient().post(
      Uri.parse('$_base/auth/request-code'),
      headers: await _headers(includeAuth: false),
      body: jsonEncode({'email': email.trim().toLowerCase()}),
    );
    if (response.statusCode == 429) {
      throw Exception('Too many requests. Try again later.');
    }
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to send code');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['expires_in'] as num?)?.toInt() ?? 600;
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await getSyncHttpClient().post(
      Uri.parse('$_base/auth/verify-code'),
      headers: await _headers(includeAuth: false),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Invalid code');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await _persistAuthFromResponse(data);
    return data;
  }

  /// POST /sync/ops — body JSON `{ "device_id", "ops": [...] }`.
  Future<Map<String, dynamic>> postSyncOps(String bodyJson) async {
    final response = await _with401Retry((h) => getSyncHttpClient().post(
          Uri.parse('$_base/sync/ops'),
          headers: h,
          body: bodyJson,
        ));
    if (response.statusCode == 401) {
      throw Exception('Signed out');
    }
    if (response.statusCode != 200) {
      throw Exception('Sync ops failed: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// GET /sync/snapshot — `{ last_seq, data }`.
  Future<Map<String, dynamic>> getSyncSnapshot() async {
    final response = await _with401Retry((h) => getSyncHttpClient().get(
          Uri.parse('$_base/sync/snapshot'),
          headers: h,
        ));
    if (response.statusCode == 401) {
      throw Exception('Signed out');
    }
    if (response.statusCode != 200) {
      throw Exception('Snapshot failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// GET /sync/ops?since_seq=
  Future<Map<String, dynamic>> getSyncOpsSince(int sinceSeq) async {
    final uri = Uri.parse('$_base/sync/ops').replace(
      queryParameters: {'since_seq': sinceSeq.toString()},
    );
    final response = await _with401Retry((h) => getSyncHttpClient().get(
          uri,
          headers: h,
        ));
    if (response.statusCode == 401) {
      throw Exception('Signed out');
    }
    if (response.statusCode != 200) {
      throw Exception('Sync ops pull failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
