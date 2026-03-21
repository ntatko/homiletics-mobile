import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/services/auth_storage.dart';
import 'package:homiletics/services/realtime_sync_client.dart';
import 'package:homiletics/services/sync_api_client.dart';
import 'package:homiletics/services/sync_service.dart';
import 'package:homiletics/storage/operational_sync_storage.dart';

class PreferencesModal extends StatefulWidget {
  final VoidCallback? onTranslationChanged;
  final VoidCallback? onSignedOut;

  const PreferencesModal({
    Key? key,
    this.onTranslationChanged,
    this.onSignedOut,
  }) : super(key: key);
  @override
  PreferencesModalState createState() => PreferencesModalState();
}

class PreferencesModalState extends State<PreferencesModal> {
  bool? _signedIn;
  String? _userEmail;
  bool _codeSent = false;
  String _emailInput = '';
  String _codeInput = '';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
    SyncService.instance.addListener(_onSyncStatusChanged);
  }

  @override
  void dispose() {
    SyncService.instance.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  void _onSyncStatusChanged() {
    if (mounted) setState(() {});
  }

  static const _authStateTimeout = Duration(seconds: 5);

  Future<void> _loadAuthState() async {
    bool signedIn = false;
    String? email;
    try {
      signedIn = await isSignedIn.timeout(
        _authStateTimeout,
        onTimeout: () => false,
      );
      email = await getStoredUserEmail().timeout(
        _authStateTimeout,
        onTimeout: () => null,
      );
      // Clear partial state: if we have stored email but no token, treat as not signed in.
      if (!signedIn && email != null) {
        await clearTokens();
        email = null;
      }
    } catch (_) {
      signedIn = false;
      email = null;
    }
    if (mounted) {
      setState(() {
        _signedIn = signedIn;
        _userEmail = email;
        _codeSent = false;
        _error = null;
      });
    }
  }

  Future<void> _sendCode() async {
    final email = _emailInput.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SyncApiClient().requestCode(email);
      if (mounted) {
        setState(() {
          _codeSent = true;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeInput.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SyncApiClient().verifyCode(_emailInput.trim(), code);
      if (mounted) {
        await resetReplicationMeta();
        RealtimeSyncClient.instance.start();
        await SyncService.instance.syncNowIfSignedIn();
        await _loadAuthState();
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      RealtimeSyncClient.instance.stop();
      await SyncApiClient().logoutOnServer();
      await clearTokens();
      await resetReplicationMeta();
      if (!mounted) return;
      await _loadAuthState();
      widget.onSignedOut?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        0.5,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.settings),
                    SizedBox(width: 12),
                    Text(
                      'Preferences',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSyncSection(),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Preferred Language:'),
                    Text("English"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Preferred Bible Version:'),
                    DropdownButton<String>(
                      value: Preferences.preferredVersion,
                      items: Translation.all.map((Translation version) {
                        return DropdownMenuItem(
                          value: version.code,
                          child: Text(version.short),
                        );
                      }).toList(),
                      onChanged: (String? selected) {
                        Preferences.preferredVersion =
                            selected ?? Translation.web.code;
                        setState(() {});
                        widget.onTranslationChanged?.call();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    if (_signedIn == null) {
      return const SizedBox(
        height: 24,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_signedIn == true && _userEmail != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signed in as ${_userEmail!}',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            'Sync: ${SyncService.instance.statusLabel}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync now'),
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    await SyncService.instance.syncNowIfSignedIn();
                    if (mounted) setState(() => _loading = false);
                  },
          ),
          TextButton(
            onPressed: _loading ? null : _signOut,
            child: _loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign out'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sign in to sync',
            style: TextStyle(fontWeight: FontWeight.w500)),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12)),
        ],
        if (!_codeSent) ...[
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: (v) => _emailInput = v,
            enabled: !_loading,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _sendCode,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send code'),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '6-digit code',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (v) => _codeInput = v,
            enabled: !_loading,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed:
                    _loading ? null : () => setState(() => _codeSent = false),
                child: const Text('Change email'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : _verifyCode,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
