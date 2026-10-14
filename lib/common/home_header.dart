import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Home's top bar: the serif "Homiletics" wordmark with search and settings
/// buttons, or — while [searching] — a search field with a close button.
class HomeHeader extends StatelessWidget {
  final bool searching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenSettings;

  const HomeHeader({
    Key? key,
    required this.searching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.onSearchChanged,
    required this.onOpenSettings,
  }) : super(key: key);

  static const TextStyle _wordmark = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.26,
  );

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 12, 8),
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
                          hintText: 'Search lessons, passages, notes…',
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
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Close search',
                      icon: Icon(Icons.close_rounded, color: c.ink),
                      onPressed: onCloseSearch,
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('title'),
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Homiletics',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _wordmark.copyWith(color: c.ink)),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Search',
                      icon: Icon(Icons.search_rounded, size: 24, color: c.ink),
                      onPressed: onOpenSearch,
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      icon:
                          Icon(Icons.settings_outlined, size: 24, color: c.ink),
                      onPressed: onOpenSettings,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
