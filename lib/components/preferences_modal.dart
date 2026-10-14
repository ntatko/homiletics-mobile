import 'package:flutter/material.dart';
// import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// Shared preferences form (used by [PreferencesModal] and [SettingsPage]).
class PreferencesPanel extends StatefulWidget {
  final VoidCallback? onTranslationChanged;
  final bool showHeader;

  const PreferencesPanel({
    Key? key,
    this.onTranslationChanged,
    this.showHeader = true,
  }) : super(key: key);

  @override
  State<PreferencesPanel> createState() => _PreferencesPanelState();
}

class _PreferencesPanelState extends State<PreferencesPanel> {
  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final TextStyle titleStyle =
        AppText.bodyStrong.copyWith(fontSize: 15, color: c.ink);
    final TextStyle subtitleStyle = AppText.caption.copyWith(color: c.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showHeader) ...[
          Row(
            children: [
              Icon(Icons.tune_rounded, color: c.accent),
              const SizedBox(width: 12),
              Text('Preferences', style: AppText.title.copyWith(color: c.ink)),
            ],
          ),
          const SizedBox(height: 20),
        ],
        AppCard(
          radius: AppRadius.tile,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Preferred language', style: titleStyle),
                subtitle: Text('English', style: subtitleStyle),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Preferred Bible version', style: titleStyle),
                trailing: DropdownButton<String>(
                  value: Preferences.preferredVersion,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  dropdownColor: c.surface,
                  style: AppText.body.copyWith(color: c.ink),
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PreferencesModal extends StatelessWidget {
  final VoidCallback? onTranslationChanged;

  const PreferencesModal({Key? key, this.onTranslationChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: PreferencesPanel(
          onTranslationChanged: onTranslationChanged,
        ),
      ),
    );
  }
}
