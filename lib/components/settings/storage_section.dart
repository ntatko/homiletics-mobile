import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/recording_storage_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// Settings card for lecture recordings: how much space they take, "Remove
/// recordings older than …" with a confirmation, and the optional daily
/// automatic removal. Only the audio goes; notes and transcripts stay.
class RecordingStorageSettings extends StatefulWidget {
  const RecordingStorageSettings({Key? key}) : super(key: key);

  @override
  State<RecordingStorageSettings> createState() =>
      _RecordingStorageSettingsState();
}

class _RecordingStorageSettingsState extends State<RecordingStorageSettings> {
  RecordingUsage? _usage;
  RecordingAge _age =
      RecordingAge.fromDays(Preferences.recordingRemovalAgeDays);
  bool _autoRemove = Preferences.autoRemoveRecordings;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    try {
      final RecordingUsage usage = await RecordingStorageService.scan();
      if (!mounted) return;
      setState(() => _usage = usage);
    } catch (error) {
      sendError(error, "RecordingStorageSettings scan");
      if (!mounted) return;
      setState(() => _usage = const RecordingUsage(recordings: []));
    }
  }

  static String ageLabel(AppLocalizations l, RecordingAge age) {
    switch (age) {
      case RecordingAge.oneMonth:
        return l.storageAgeOneMonth;
      case RecordingAge.threeMonths:
        return l.storageAgeThreeMonths;
      case RecordingAge.sixMonths:
        return l.storageAgeSixMonths;
      case RecordingAge.oneYear:
        return l.storageAgeOneYear;
    }
  }

  void _setAge(RecordingAge? age) {
    if (age == null) return;
    Preferences.recordingRemovalAgeDays = age.days;
    setState(() => _age = age);
  }

  void _setAutoRemove(bool enabled) {
    Preferences.autoRemoveRecordings = enabled;
    setState(() => _autoRemove = enabled);
  }

  Future<void> _freeUpSpace(List<StoredRecording> old) async {
    final RecordingUsage usage = _usage!;
    final AppLocalizations l = context.l10n;
    final AppColors c = AppColors.of(context);
    final int bytes =
        old.fold(0, (int sum, r) => sum + r.bytes) + usage.orphanBytes;
    final int untranscribed = old.where((r) => !r.isTranscribed).length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.storageConfirmTitle(old.length)),
        content: Text([
          l.storageConfirmMessage(formatStorageSize(bytes)),
          if (untranscribed > 0) l.storageConfirmUntranscribed(untranscribed),
        ].join('\n\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.storageConfirmRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _removing = true);
    final RecordingRemoval result =
        await RecordingStorageService.remove(old, orphans: usage.orphans);
    if (!mounted) return;
    setState(() => _removing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.failed > 0
          ? l.storageRemoveFailed
          : l.storageFreed(formatStorageSize(result.bytes))),
    ));
    await _scan();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final RecordingUsage? usage = _usage;
    final List<StoredRecording> old =
        usage?.olderThan(_age, DateTime.now()) ?? const [];
    final int oldBytes = old.fold(0, (int sum, r) => sum + r.bytes);
    // Unreferenced files go with any removal, and on their own if that's
    // all there is.
    final bool canRemove = usage != null &&
        !_removing &&
        (old.isNotEmpty || usage.orphans.isNotEmpty);
    final TextStyle caption = AppText.caption.copyWith(color: c.muted);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.tile,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.storageRecordingsTitle,
                style: AppText.bodyStrong.copyWith(fontSize: 15, color: c.ink)),
            const SizedBox(height: 2),
            Text(
              usage == null
                  ? l.storageChecking
                  : l.storageRecordingsSummary(usage.recordings.length,
                      formatStorageSize(usage.totalBytes)),
              style: caption,
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: c.line),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(l.storageRemoveOlderThan,
                      style: AppText.body.copyWith(color: c.ink)),
                ),
                const SizedBox(width: 8),
                DropdownButton<RecordingAge>(
                  value: _age,
                  underline: const SizedBox.shrink(),
                  onChanged: _removing ? null : _setAge,
                  items: [
                    for (final RecordingAge age in RecordingAge.values)
                      DropdownMenuItem(
                          value: age, child: Text(ageLabel(l, age))),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    usage == null
                        ? l.storageChecking
                        : l.storageOlderSummary(
                            old.length, formatStorageSize(oldBytes)),
                    style: caption,
                  ),
                ),
                const SizedBox(width: 8),
                _removing
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : TextButton(
                        onPressed: canRemove ? () => _freeUpSpace(old) : null,
                        style: TextButton.styleFrom(
                            foregroundColor: c.danger,
                            minimumSize: const Size(0, 44)),
                        child: Text(l.storageFreeUpSpace),
                      ),
              ],
            ),
            Divider(height: 17, color: c.line),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _autoRemove,
              onChanged: _setAutoRemove,
              title: Text(l.storageAutoRemove,
                  style: AppText.body.copyWith(color: c.ink)),
              subtitle: Text(l.storageAutoRemoveDetail(ageLabel(l, _age)),
                  style: caption),
            ),
          ],
        ),
      ),
    );
  }
}
