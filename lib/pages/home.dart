import 'dart:math' as math;
import 'package:homiletics/l10n/l10n.dart';

import 'package:flutter/material.dart';
import 'package:homiletics/common/home_header.dart';
import 'package:homiletics/components/application_list.dart';
import 'package:homiletics/components/continue_studies.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/start_activity.dart';
import 'package:homiletics/pages/search_page.dart';
import 'package:homiletics/pages/settings_page.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Home's study lists refresh themselves when an editor closes (see
/// StudyDataBuilder), so they can stay const here.
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const double _wideBreakpoint = 600;
  static const double _homeMaxWidth = 720;

  /// Side gutter of the sections (the week cards add their own).
  static const double _gutter = 20;

  String _searchString = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searching = false;

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _openSearch() {
    setState(() => _searching = true);
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchString = '';
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= _wideBreakpoint;
    final maxW =
        isWide ? math.min(_homeMaxWidth, size.width - 48) : double.infinity;

    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _searching) _closeSearch();
      },
      child: Scaffold(
        backgroundColor: c.ground,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                children: [
                  HomeHeader(
                    searching: _searching,
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    onOpenSearch: _openSearch,
                    onCloseSearch: _closeSearch,
                    onSearchChanged: (value) =>
                        setState(() => _searchString = value),
                    onOpenSettings: _openSettings,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.only(top: 6, bottom: 8),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          children: const [
                            CurrentLessonActions(),
                            ContinueStudies(
                              padding:
                                  EdgeInsets.fromLTRB(_gutter, 20, _gutter, 0),
                            ),
                            ApplicationList(
                              padding:
                                  EdgeInsets.fromLTRB(_gutter, 20, _gutter, 0),
                            ),
                            HelpMenu(),
                          ],
                        ),
                        if (_searching)
                          Positioned.fill(
                            child: _SearchOverlay(searchString: _searchString),
                          ),
                      ],
                    ),
                  ),
                  if (!_searching)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(_gutter, 8, _gutter, 12),
                      child: StartActivity(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

/// Covers Home's content while searching: a hint until something is typed,
/// then the [SearchResults].
class _SearchOverlay extends StatelessWidget {
  final String searchString;

  const _SearchOverlay({required this.searchString});

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return ColoredBox(
      color: c.ground,
      child: searchString.trim().isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                context.l10n.homeSearchIntro,
                style: AppText.body.copyWith(color: c.muted),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [SearchResults(searchString: searchString)],
            ),
    );
  }
}
