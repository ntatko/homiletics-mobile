import 'package:flutter/material.dart';
import 'package:homiletics/components/preferences_modal.dart';

/// Full-screen settings (same controls as the editor preferences dialog).
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, this.onTranslationChanged}) : super(key: key);

  final VoidCallback? onTranslationChanged;

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                PreferencesPanel(
                  onTranslationChanged: onTranslationChanged,
                  showHeader: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
