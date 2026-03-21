import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'auth_storage_platform_io.dart'
    if (dart.library.html) 'auth_storage_platform.dart' as platform;

const _accessTokenKey = 'sync_access_token';
const _refreshTokenKey = 'sync_refresh_token';
const _accessExpiresAtMsKey = 'sync_access_expires_at_ms';
const _userEmailKey = 'sync_user_email';
const _sessionIdKey = 'sync_session_id';

const _uuid = Uuid();

/// Mobile: Keychain / Keystore. Desktop & web: app preferences (no Keychain).
final FlutterSecureStorage? _secureStorage = platform.useSecureAuthStorage
    ? FlutterSecureStorage(
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        mOptions: const MacOsOptions(
          groupId: 'com.thirteenone.homiletics',
        ),
      )
    : null;

Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

Future<String?> _read(String key) async {
  if (platform.useSecureAuthStorage) {
    return _secureStorage!.read(key: key);
  }
  return (await _prefs()).getString(key);
}

Future<void> _write(String key, String value) async {
  if (platform.useSecureAuthStorage) {
    await _secureStorage!.write(key: key, value: value);
    return;
  }
  await (await _prefs()).setString(key, value);
}

Future<void> _delete(String key) async {
  if (platform.useSecureAuthStorage) {
    await _secureStorage!.delete(key: key);
    return;
  }
  await (await _prefs()).remove(key);
}

Future<String?> getAccessToken() async {
  return _read(_accessTokenKey);
}

Future<void> setAccessToken(String token) async {
  await _write(_accessTokenKey, token);
}

/// Wall-clock time when the access token should be treated as expired (proactive refresh).
Future<void> setAccessTokenExpiresAtMs(int expiresAtMs) async {
  await _write(_accessExpiresAtMsKey, expiresAtMs.toString());
}

Future<int?> getAccessTokenExpiresAtMs() async {
  final s = await _read(_accessExpiresAtMsKey);
  if (s == null || s.isEmpty) return null;
  return int.tryParse(s);
}

/// Convenience: [expiresInSeconds] from the API `expires_in` field.
Future<void> setAccessTokenExpiryFromExpiresIn(int expiresInSeconds) async {
  final at = DateTime.now()
      .add(Duration(seconds: expiresInSeconds))
      .millisecondsSinceEpoch;
  await setAccessTokenExpiresAtMs(at);
}

Future<String?> getRefreshToken() async {
  return _read(_refreshTokenKey);
}

Future<void> setRefreshToken(String token) async {
  await _write(_refreshTokenKey, token);
}

Future<String?> getStoredUserEmail() async {
  return _read(_userEmailKey);
}

Future<void> setStoredUserEmail(String? email) async {
  if (email == null) {
    await _delete(_userEmailKey);
  } else {
    await _write(_userEmailKey, email);
  }
}

Future<void> clearTokens() async {
  // Clear through the currently selected backend first.
  await _delete(_accessTokenKey);
  await _delete(_refreshTokenKey);
  await _delete(_accessExpiresAtMsKey);
  await _delete(_userEmailKey);

  // Defensive cleanup: always clear SharedPreferences too in case auth backend
  // selection changed across app versions/platforms.
  final prefs = await _prefs();
  await prefs.remove(_accessTokenKey);
  await prefs.remove(_refreshTokenKey);
  await prefs.remove(_accessExpiresAtMsKey);
  await prefs.remove(_userEmailKey);
  await prefs.setString(_accessTokenKey, '');
  await prefs.setString(_refreshTokenKey, '');
  await prefs.setString(_accessExpiresAtMsKey, '');
  await prefs.setString(_userEmailKey, '');

  // Defensive cleanup: also attempt secure storage cleanup (best effort).
  try {
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
      mOptions: MacOsOptions(
        groupId: 'com.thirteenone.homiletics',
      ),
    );
    await secure.delete(key: _accessTokenKey);
    await secure.delete(key: _refreshTokenKey);
    await secure.delete(key: _accessExpiresAtMsKey);
    await secure.delete(key: _userEmailKey);
    await secure.write(key: _accessTokenKey, value: '');
    await secure.write(key: _refreshTokenKey, value: '');
    await secure.write(key: _accessExpiresAtMsKey, value: '');
    await secure.write(key: _userEmailKey, value: '');
  } catch (_) {
    // Ignore unsupported/blocked secure storage backends on this platform.
  }
}

Future<bool> get isSignedIn async {
  final token = await getAccessToken();
  return token != null && token.isNotEmpty;
}

/// Stable session/device id for sync locks. Generated once per install.
Future<String> getSessionId() async {
  var id = await _read(_sessionIdKey);
  if (id == null || id.isEmpty) {
    id = _uuid.v4();
    await _write(_sessionIdKey, id);
  }
  return id;
}
