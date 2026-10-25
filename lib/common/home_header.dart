import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Home's top bar: the serif "Homiletics" wordmark with import-from-link,
/// search and settings buttons, or — while [searching] — a search field with a close button.
/// Without [showButtons] (the buttons are on the iPhone Duo's vertical bar)
/// it's just the wordmark or the field.
class HomeHeader extends StatelessWidget {
  final bool searching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenSettings;
  final VoidCallback onImportLink;
  final bool showButtons;

  const HomeHeader({
    Key? key,
    required this.searching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.onSearchChanged,
    required this.onOpenSettings,
    required this.onImportLink,
    this.showButtons = true,
  }) : super(key: key);

  static const TextStyle _wordmark = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.26,
  );

  /// Import from link, search and settings: on the right of the wordmark,
  /// or on the vertical bar.
  List<Widget> buttons(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    return [
      IconButton(
        key: const ValueKey('homeImportLink'),
        tooltip: l.importFromLink,
        icon: Icon(Icons.add_link_rounded, size: 24, color: c.ink),
        onPressed: onImportLink,
      ),
      IconButton(
        tooltip: l.homeSearchTooltip,
        icon: Icon(Icons.search_rounded, size: 24, color: c.ink),
        onPressed: onOpenSearch,
      ),
      IconButton(
        tooltip: l.settingsTitle,
        icon: Icon(Icons.settings_outlined, size: 24, color: c.ink),
        onPressed: onOpenSettings,
      ),
    ];
  }

  /// The close-search button, for the vertical bar while [searching].
  Widget closeSearchButton(BuildContext context) => IconButton(
        tooltip: context.l10n.homeCloseSearch,
        icon: Icon(Icons.close_rounded, color: AppColors.of(context).ink),
        onPressed: onCloseSearch,
      );

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, showButtons ? 12 : 24, 8),
      child: SizedBox(
        height: 48,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: searching
              ? Row(
                  key: const ValueKey('search'),
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        autofocus: true,
                        onChanged: onSearchChanged,
                        textInputAction: TextInputAction.search,
                        style: AppText.body.copyWith(color: c.ink),
                        decoration: InputDecoration(
                          hintText: l.homeSearchFieldHint,
                          isDense: true,
                          prefixIcon: Icon(Icons.search_rounded,
                              size: 20, color: c.muted),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.tile),
                            borderSide: BorderSide(color: c.line),
                          ),
                        ),
                      ),
                    ),
                    if (showButtons) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: l.homeCloseSearch,
                        icon: Icon(Icons.close_rounded, color: c.ink),
                        onPressed: onCloseSearch,
                      ),
                    ],
                  ],
                )
              : Row(
                  key: const ValueKey('title'),
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(l.appTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _wordmark.copyWith(color: c.ink)),
                      ),
                    ),
                    if (showButtons) ...buttons(context),
                  ],
                ),
        ),
      ),
    );
  }
}
