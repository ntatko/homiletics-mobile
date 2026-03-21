/// Whether to use OS secure storage (Keychain / Keystore).
/// False on web and desktop so we avoid Keychain / signing issues on macOS, etc.
bool get useSecureAuthStorage => false;
