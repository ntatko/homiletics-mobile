import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/incoming_links.dart';
import 'package:homiletics/services/update_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// The launch check (Windows only): waits for Home to settle, then offers
/// an update if there is one. Silent when there isn't, or on any error.
Future<void> checkForUpdatesOnLaunch() async {
  if (!UpdateService.isSupported) return;
  await Future<void>.delayed(const Duration(seconds: 4));
  final UpdateCheck? result = await UpdateService.checkOnLaunch();
  final BuildContext? context = appNavigatorKey.currentState?.overlay?.context;
  if (result == null || context == null || !context.mounted) return;
  await showUpdateDialog(context, result.release!,
      currentVersion: result.currentVersion);
}

/// The Settings "Check for updates" row's action: says so when there's
/// nothing new or the check fails.
Future<void> checkForUpdatesManually(BuildContext context) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final AppLocalizations l = context.l10n;
  try {
    final UpdateCheck result = await UpdateService.check();
    if (!context.mounted) return;
    if (result.release == null) {
      messenger.showSnackBar(
          SnackBar(content: Text(l.updateUpToDate(result.currentVersion))));
      return;
    }
    await showUpdateDialog(context, result.release!,
        currentVersion: result.currentVersion, offerSkip: false);
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(l.updateCheckFailed)));
  }
}

/// "Homiletics X.Y.Z is available": release notes plus Update now (installed
/// copies) or Download (portable zip copies), Later and Skip this version.
Future<void> showUpdateDialog(
  BuildContext context,
  ReleaseInfo release, {
  required String currentVersion,
  bool offerSkip = true,
}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _UpdateDialog(
        release: release,
        currentVersion: currentVersion,
        offerSkip: offerSkip,
      ),
    );

enum _Stage { prompt, downloading, installing, failed }

class _UpdateDialog extends StatefulWidget {
  final ReleaseInfo release;
  final String currentVersion;
  final bool offerSkip;

  const _UpdateDialog({
    required this.release,
    required this.currentVersion,
    required this.offerSkip,
  });

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  _Stage _stage = _Stage.prompt;
  double _progress = 0;

  bool get _canSelfUpdate =>
      widget.release.setup != null && UpdateService.isInstalledBySetup;

  Future<void> _openDownloadPage() async {
    Navigator.of(context).pop();
    try {
      await launchUrl(kWindowsDownloadPage,
          mode: LaunchMode.externalApplication);
    } catch (error) {
      sendError(error, 'Update: open download page');
    }
  }

  Future<void> _update() async {
    setState(() {
      _stage = _Stage.downloading;
      _progress = 0;
    });
    try {
      final File setup =
          await UpdateService.download(widget.release.setup!, onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      });
      if (!mounted) return;
      setState(() => _stage = _Stage.installing);
      // Let "Installing…" paint before the app quits.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await UpdateService.installAndExit(setup);
    } catch (error) {
      sendError(error, 'Update: download/install');
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final bool busy =
        _stage == _Stage.downloading || _stage == _Stage.installing;
    final String notes = widget.release.notesSnippet();

    final List<Widget> body = switch (_stage) {
      _Stage.prompt => [
          Text(l.updateAvailableMessage(widget.currentVersion),
              style: AppText.body.copyWith(color: c.muted)),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(notes, style: AppText.body.copyWith(color: c.ink)),
          ],
          if (!_canSelfUpdate) ...[
            const SizedBox(height: 12),
            Text(l.updatePortableNote,
                style: AppText.caption.copyWith(color: c.muted)),
          ],
        ],
      _Stage.downloading => [
          Text(l.updateDownloading, style: AppText.body.copyWith(color: c.ink)),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: _progress > 0 ? _progress : null),
        ],
      _Stage.installing => [
          Text(l.updateInstalling, style: AppText.body.copyWith(color: c.ink)),
          const SizedBox(height: 14),
          const LinearProgressIndicator(),
        ],
      _Stage.failed => [
          Text(l.updateFailed, style: AppText.body.copyWith(color: c.ink)),
        ],
    };

    final List<Widget> actions = switch (_stage) {
      _Stage.prompt => [
          if (widget.offerSkip)
            TextButton(
              onPressed: () {
                Preferences.skippedUpdateVersion = widget.release.version;
                Navigator.of(context).pop();
              },
              child: Text(l.updateSkipVersion),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.updateLater),
          ),
          FilledButton(
            onPressed: _canSelfUpdate ? _update : _openDownloadPage,
            child: Text(_canSelfUpdate ? l.updateNow : l.updateDownload),
          ),
        ],
      _Stage.downloading || _Stage.installing => const [],
      _Stage.failed => [
          TextButton(
            onPressed: _openDownloadPage,
            child: Text(l.updateDownload),
          ),
          FilledButton(onPressed: _update, child: Text(l.updateTryAgain)),
        ],
    };

    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        title: Text(l.updateAvailableTitle(widget.release.version)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 360),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: body,
            ),
          ),
        ),
        actions: actions,
      ),
    );
  }
}
