import 'dart:io' show Platform;

/// Use Keychain / Keystore only on mobile; desktop uses [SharedPreferences] instead.
bool get useSecureAuthStorage => Platform.isAndroid || Platform.isIOS;
