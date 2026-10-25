import 'package:flutter/material.dart';
import 'package:homiletics/common/vertical_bar.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/components/backup_settings.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/components/model_settings.dart';
import 'package:homiletics/components/settings/storage_section.dart';
import 'package:homiletics/components/update_prompt.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/pages/onboarding/onboarding_launcher.dart';
import 'package:homiletics/services/update_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Full-screen settings (same controls as the editor preferences dialog),
/// plus the app language, the on-device models, backup & restore and
/// help / feedback.
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, this.onTranslationChanged}) : super(key: key);

  final VoidCallback? onTranslationChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 28, 4, 8),
          child: Overline(text),
        );

    final bool verticalBar = VerticalBar.of(context) != null;
    return VerticalBarLayout(
      groups: const [
        BarGroup(children: [BackButton()])
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !verticalBar,
          title: Text(l.settingsTitle),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  heading(l.settingsSectionLanguage),
                  const _AppLanguageRow(),
                  heading(l.settingsSectionReading),
                  PreferencesPanel(
                    onTranslationChanged: onTranslationChanged,
                    showHeader: false,
                    showAppLanguage: false,
                  ),
                  heading(l.settingsSectionModels),
                  const WhisperModelSettings(),
                  const FormattingModelSettings(),
                  heading(l.settingsSectionStorage),
                  const RecordingStorageSettings(),
                  heading(l.settingsSectionBackup),
                  const BackupSettings(),
                  heading(l.settingsSectionHelp),
                  _SettingsRow(
                    key: const ValueKey('settingsOnboarding'),
                    icon: Icons.school_outlined,
                    label: l.onboardingSettingsRow,
                    onTap: () => showOnboarding(context),
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: l.helpRequestFeedback,
                    onTap: () => showFeedbackSheet(context),
                  ),
                  if (UpdateService.isSupported) ...[
                    const SizedBox(height: 10),
                    const _CheckForUpdatesRow(),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l.settingsCopyright('${DateTime.now().year}'),
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(color: c.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable settings card: icon, label, optional trailing value, chevron.
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return AppCard(
      radius: AppRadius.tile,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppText.body.copyWith(color: c.ink)),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppText.body.copyWith(color: c.muted),
                ),
              ),
            ],
            Icon(Icons.chevron_right_rounded, size: 22, color: c.muted),
          ],
        ),
      ),
    );
  }
}

/// "App language — Español": opens a picker of [Language.all] plus "Phone
/// language". The app re-localizes as soon as [Preferences.appLanguage]
/// changes.
class _AppLanguageRow extends StatelessWidget {
  const _AppLanguageRow();

  Future<void> _pick(BuildContext context) async {
    final Language? current = Preferences.appLanguage;
    final AppColors c = AppColors.of(context);
    // Wrapped so "Phone language" (null) differs from dismissing (no result).
    final ({Language? language})? choice =
        await showDialog<({Language? language})>(
      context: context,
      builder: (ctx) {
        Widget option(Language? language, String name) => ListTile(
              title: Text(name),
              trailing: language == current
                  ? Icon(Icons.check_rounded, color: c.accent)
                  : null,
              onTap: () => Navigator.pop(ctx, (language: language)),
            );
        return SimpleDialog(
          title: Text(ctx.l10n.settingsAppLanguage),
          children: [
            option(null, ctx.l10n.languageSystemDefault),
            for (final Language language in Language.all)
              option(language, language.name),
          ],
        );
      },
    );
    if (choice == null) return;
    Preferences.appLanguage = choice.language;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    return ValueListenableBuilder<Language?>(
      valueListenable: Preferences.appLanguageNotifier,
      builder: (context, language, _) => _SettingsRow(
        icon: Icons.translate_rounded,
        label: l.settingsAppLanguage,
        value: language?.name ?? l.languageSystemDefault,
        onTap: () => _pick(context),
      ),
    );
  }
}

/// Windows only: "Check for updates — Version 3.0.0". Other platforms
/// update through their stores.
class _CheckForUpdatesRow extends StatefulWidget {
  const _CheckForUpdatesRow();

  @override
  State<_CheckForUpdatesRow> createState() => _CheckForUpdatesRowState();
}

class _CheckForUpdatesRowState extends State<_CheckForUpdatesRow> {
  String? _version;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    }).catchError((_) {});
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await checkForUpdatesManually(context);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    return _SettingsRow(
      key: const ValueKey('settingsCheckForUpdates'),
      icon: Icons.system_update_alt_rounded,
      label: l.settingsCheckForUpdates,
      value: _version == null ? null : l.settingsVersion(_version!),
      onTap: _check,
    );
  }
}
