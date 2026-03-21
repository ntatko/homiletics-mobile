import 'package:flutter/material.dart';
import 'package:homiletics/services/realtime_sync_client.dart';
import 'package:homiletics/services/sync_api_client.dart';
import 'package:homiletics/services/sync_service.dart';
import 'package:homiletics/storage/operational_sync_storage.dart';

/// Modal that prompts for email, then for the 6-digit code from the API.
/// Calls [onSignedIn] on success and closes.
class SignInModal extends StatefulWidget {
  final VoidCallback? onSignedIn;

  const SignInModal({Key? key, this.onSignedIn}) : super(key: key);

  @override
  State<SignInModal> createState() => _SignInModalState();
}

class _SignInModalState extends State<SignInModal> {
  bool _codeSent = false;
  String _emailInput = '';
  String _codeInput = '';
  bool _loading = false;
  String? _error;

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
        widget.onSignedIn?.call();
        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'Sign in',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to sync your data across devices.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
                if (!_codeSent) ...[
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onChanged: (v) => setState(() => _emailInput = v),
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 16),
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
                  Text(
                    'We sent a 6-digit code to $_emailInput',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '6-digit code',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (v) => setState(() => _codeInput = v),
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() => _codeSent = false),
                        child: const Text('Change email'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _verifyCode,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Verify'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
