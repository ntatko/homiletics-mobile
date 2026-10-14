import 'package:flutter/material.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/l10n/l10n.dart';
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
  Future<void> _pickAppLanguage() async {
    final String before = Preferences.translation.code;
    final _LanguageChoice? choice = await showModalBottomSheet<_LanguageChoice>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AppLanguageSheet(),
    );
    if (choice == null || !mounted) return;
    Preferences.appLanguage = choice.language;
    setState(() {});
    // With no explicit Bible choice, the default follows the app language.
    if (Preferences.translation.code != before) {
      widget.onTranslationChanged?.call();
    }
  }

  Future<void> _pickTranslation() async {
    final Translation? selected = await showModalBottomSheet<Translation>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _TranslationSheet(),
    );
    if (selected == null || !mounted) return;
    Preferences.preferredVersion = selected.code;
    setState(() {});
    widget.onTranslationChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final Language? appLanguage = Preferences.appLanguage;
    final Translation translation = Preferences.translation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showHeader) ...[
          Row(
            children: [
              Icon(Icons.tune_rounded, color: c.accent),
              const SizedBox(width: 12),
              Text(l.prefsTitle, style: AppText.title.copyWith(color: c.ink)),
            ],
          ),
          const SizedBox(height: 20),
        ],
        AppCard(
          radius: AppRadius.tile,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _PrefRow(
                title: l.prefsAppLanguage,
                value: appLanguage?.name ?? l.languageSystemDefault,
                onTap: _pickAppLanguage,
              ),
              const Divider(height: 1),
              _PrefRow(
                title: l.prefsBibleVersion,
                value: translation.name,
                trailing: translation.short,
                onTap: _pickTranslation,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A tappable preferences row: title, current value, chevron.
class _PrefRow extends StatelessWidget {
  final String title;
  final String value;
  final String? trailing;
  final VoidCallback onTap;

  const _PrefRow({
    required this.title,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title,
          style: AppText.bodyStrong.copyWith(fontSize: 15, color: c.ink)),
      subtitle: Text(value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption.copyWith(color: c.muted)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing!,
                style: AppText.bodyStrong.copyWith(color: c.accent)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: c.muted),
        ],
      ),
    );
  }
}

/// Wraps a nullable [Language] so "phone language" (null) can be returned
/// from a sheet distinctly from "dismissed".
class _LanguageChoice {
  final Language? language;
  const _LanguageChoice(this.language);
}

/// The sheet frame shared by both pickers: handle, title, scrolling body.
class _PickerSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double initialSize;

  const _PickerSheet({
    required this.title,
    required this.children,
    this.initialSize = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialSize,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const DragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Text(title, style: AppText.title.copyWith(color: c.ink)),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// One option in a picker sheet; checked when [selected].
class _PickerRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  const _PickerRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.accentTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.control),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            style:
                                (selected ? AppText.bodyStrong : AppText.body)
                                    .copyWith(color: c.ink)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: AppText.caption.copyWith(color: c.muted)),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    Text(trailing!,
                        style: AppText.caption.copyWith(
                            color: selected ? c.accent : c.muted,
                            fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 22,
                    child: selected
                        ? Icon(Icons.check_rounded, size: 20, color: c.accent)
                        : null,
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

class _AppLanguageSheet extends StatelessWidget {
  const _AppLanguageSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    final Language? current = Preferences.appLanguage;
    return _PickerSheet(
      title: l.prefsAppLanguage,
      initialSize: 0.6,
      children: [
        _PickerRow(
          title: l.languageSystemDefault,
          selected: current == null,
          onTap: () => Navigator.pop(context, const _LanguageChoice(null)),
        ),
        for (final Language language in Language.all)
          _PickerRow(
            title: language.name,
            selected: current?.code == language.code,
            onTap: () => Navigator.pop(context, _LanguageChoice(language)),
          ),
      ],
    );
  }
}

/// Bible translations grouped by language (the app language's first).
class _TranslationSheet extends StatelessWidget {
  const _TranslationSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    final String current = Preferences.translation.code;
    final groups = Translation.groupedFor(Preferences.effectiveLanguage);
    return _PickerSheet(
      title: l.prefsBibleVersion,
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
            child: Overline(Translation.languageNames[group.key] ?? group.key),
          ),
          for (final Translation t in group.value)
            _PickerRow(
              title: t.name,
              subtitle: t.newTestamentOnly ? l.bibleNewTestamentOnly : null,
              trailing: t.short,
              selected: t.code == current,
              onTap: () => Navigator.pop(context, t),
            ),
        ],
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
