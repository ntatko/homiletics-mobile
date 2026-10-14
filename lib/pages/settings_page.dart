import 'package:flutter/material.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/components/model_settings.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// Full-screen settings (same controls as the editor preferences dialog),
/// plus the on-device models and help / feedback.
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, this.onTranslationChanged}) : super(key: key);

  final VoidCallback? onTranslationChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 28, 4, 8),
          child: Overline(text),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                heading('Reading'),
                PreferencesPanel(
                  onTranslationChanged: onTranslationChanged,
                  showHeader: false,
                ),
                heading('On-device models'),
                const WhisperModelSettings(),
                const FormattingModelSettings(),
                heading('Help'),
                AppCard(
                  radius: AppRadius.tile,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () => showFeedbackSheet(context),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 20, color: c.accent),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text('Request help / leave feedback',
                              style: AppText.body.copyWith(color: c.ink)),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 22, color: c.muted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Copyright (C) ${DateTime.now().year} 13one.org · '
                    'All rights reserved',
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(color: c.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
