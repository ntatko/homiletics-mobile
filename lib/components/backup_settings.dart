import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/relative_time.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/backup_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

/// Settings → Backup & restore: one .zip of every study (and, optionally,
/// the lecture recordings) that the user keeps wherever they like, and a
/// restore that only ever adds what's missing.
class BackupSettings extends StatefulWidget {
  const BackupSettings({Key? key}) : super(key: key);

  @override
  State<BackupSettings> createState() => _BackupSettingsState();
}

class _BackupSettingsState extends State<BackupSettings> {
  bool _busy = false;
  bool _includeRecordings = true;
  int? _recordingsBytes;
  DateTime? _lastBackup = Preferences.lastBackupAt;

  static const XTypeGroup _zipType = XTypeGroup(
    label: 'zip',
    extensions: ['zip'],
    mimeTypes: [
      'application/zip',
      'application/x-zip-compressed',
      'application/octet-stream',
    ],
    uniformTypeIdentifiers: ['public.zip-archive'],
  );

  /// Phones and tablets hand the file to the share sheet (Google Drive,
  /// Files, AirDrop…); desktops save it where the user picks.
  static bool get _usesShareSheet => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    BackupService.recordingsSize().then((bytes) {
      if (mounted) setState(() => _recordingsBytes = bytes);
    }).catchError((Object _) {});
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(onPressed: () {}, label: context.l10n.commonOk),
    ));
  }

  Future<void> _backUp(Rect origin) async {
    final AppLocalizations l = context.l10n;
    setState(() => _busy = true);
    File? file;
    try {
      String version = '';
      try {
        version = (await PackageInfo.fromPlatform()).version;
      } catch (_) {}
      file = await BackupService.create(
        includeRecordings: _includeRecordings && (_recordingsBytes ?? 0) > 0,
        appVersion: version,
      );
      bool saved;
      if (_usesShareSheet) {
        final ShareResult result = await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path, mimeType: 'application/zip')],
          subject: BackupService.backupFileName(DateTime.now()),
          sharePositionOrigin: origin,
        ));
        saved = result.status != ShareResultStatus.dismissed;
      } else {
        final FileSaveLocation? location = await getSaveLocation(
          suggestedName: BackupService.backupFileName(DateTime.now()),
          acceptedTypeGroups: const [_zipType],
        );
        saved = location != null;
        if (location != null) await file.copy(location.path);
      }
      if (saved) {
        final DateTime now = DateTime.now();
        Preferences.lastBackupAt = now;
        if (mounted) setState(() => _lastBackup = now);
        if (!_usesShareSheet) _snack(l.backupSaved);
      }
    } catch (error) {
      sendError(error, 'Back up');
      _snack(l.backupFailed);
    } finally {
      try {
        await file?.delete();
      } catch (_) {}
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final AppLocalizations l = context.l10n;
    final XFile? picked;
    try {
      picked = await openFile(acceptedTypeGroups: const [_zipType]);
    } catch (error) {
      sendError(error, 'Pick backup');
      _snack(l.restoreFailed);
      return;
    }
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final BackupContents backup = await BackupService.read(picked.path);
      if (!mounted) return;
      setState(() => _busy = false);
      final bool confirmed = await _confirmRestore(backup);
      if (!confirmed || !mounted) return;
      setState(() => _busy = true);
      final RestoreResult result = await BackupService.restore(backup);
      notifyStudyDataChanged();
      _snack(l.restoreDone('${result.added}', '${result.skipped}'));
    } on BackupException catch (error) {
      _snack(switch (error.problem) {
        BackupProblem.notABackup => l.restoreNotABackup,
        BackupProblem.damaged => l.restoreDamaged,
        BackupProblem.newerVersion => l.restoreNewerVersion,
      });
    } catch (error) {
      sendError(error, 'Restore backup');
      _snack(l.restoreFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmRestore(BackupContents backup) async {
    final AppLocalizations l = context.l10n;
    final AppColors c = AppColors.of(context);
    Widget count(String label, int n) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(
                child: Text(label, style: AppText.body.copyWith(color: c.ink))),
            Text('$n', style: AppText.body.copyWith(color: c.muted)),
          ]),
        );
    final DateTime? created = backup.created;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restorePreviewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (created != null) ...[
              Text(
                  l.restorePreviewCreated(
                      DateFormat.yMMMd(Localizations.localeOf(ctx).toString())
                          .format(created.toLocal())),
                  style: AppText.caption.copyWith(color: c.muted)),
              const SizedBox(height: 10),
            ],
            count(l.restoreCountHomiletics, backup.homiletics.length),
            count(l.restoreCountLectureNotes, backup.lectureNotes.length),
            count(l.restoreCountWordStudies, backup.wordStudies.length),
            if (backup.recordingCount > 0)
              count(l.restoreCountRecordings, backup.recordingCount),
            const SizedBox(height: 12),
            Text(l.restorePreviewNote,
                style: AppText.caption.copyWith(color: c.muted)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.commonCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.restoreConfirm)),
        ],
      ),
    );
    return ok ?? false;
  }

  static String _megabytes(int bytes) {
    final double mb = bytes / (1024 * 1024);
    return '${mb < 10 ? mb.toStringAsFixed(1) : mb.round()} MB';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final DateTime? last = _lastBackup;
    final int recordings = _recordingsBytes ?? 0;

    return AppCard(
      radius: AppRadius.tile,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.backupExplainer,
              style: AppText.caption.copyWith(color: c.muted)),
          if (recordings > 0)
            SwitchListTile.adaptive(
              key: const ValueKey('backupIncludeRecordings'),
              contentPadding: EdgeInsets.zero,
              value: _includeRecordings,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _includeRecordings = value),
              title: Text(l.backupIncludeRecordings(_megabytes(recordings)),
                  style: AppText.body.copyWith(color: c.ink)),
            ),
          const SizedBox(height: 10),
          Builder(builder: (buttonContext) {
            return FilledButton.icon(
              key: const ValueKey('backupNow'),
              onPressed: _busy
                  ? null
                  : () {
                      final RenderBox? box =
                          buttonContext.findRenderObject() as RenderBox?;
                      _backUp(box == null
                          ? Rect.zero
                          : box.localToGlobal(Offset.zero) & box.size);
                    },
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.archive_outlined, size: 18),
              label: Text(l.backupNow),
            );
          }),
          const SizedBox(height: 6),
          Text(
            last == null
                ? l.backupNever
                : l.backupLastTime(relativeTime(context, last)),
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: c.muted),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('restoreBackup'),
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.settings_backup_restore_rounded, size: 18),
            label: Text(l.restoreFromBackup),
          ),
        ],
      ),
    );
  }
}
