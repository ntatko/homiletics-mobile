import 'package:flutter/material.dart';
// import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';

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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showHeader) ...[
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Preferences',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Preferred language'),
                  subtitle: Text('English'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Preferred Bible version'),
                  trailing: DropdownButton<String>(
                    value: Preferences.preferredVersion,
                    underline: const SizedBox.shrink(),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: PreferencesPanel(
          onTranslationChanged: onTranslationChanged,
        ),
      ),
    );
  }
}
