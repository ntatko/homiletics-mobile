import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homiletics/components/application_list.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/past_lecture_notes.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/components/start_activity.dart';
import 'package:homiletics/pages/search_page.dart';
import 'package:homiletics/pages/settings_page.dart';
// import 'package:homiletics/storage/application_storage.dart';
// import 'package:homiletics/storage/content_summary_storage.dart';
// import 'package:homiletics/storage/division_storage.dart';
// import 'package:homiletics/storage/homiletic_storage.dart';
// import 'package:homiletics/storage/lecture_note_storage.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const double _wideBreakpoint = 600;
  static const double _homeMaxWidth = 720;

  String _searchString = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= _wideBreakpoint;
    final maxW = isWide
        ? math.min(_homeMaxWidth, size.width - 48)
        : double.infinity;

    final searchBarFill = isWide
        ? colorScheme.surfaceContainerHigh
        : theme.cardColor;

    return Scaffold(
        backgroundColor:
            isWide ? colorScheme.surfaceContainerLow : colorScheme.surface,
        body: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Stack(children: [
                  ListView(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 20 : 0,
                      0,
                      isWide ? 20 : 0,
                      24,
                    ),
                    children: const [
                      SizedBox(height: 108),
                      CurrentLessonActions(),
                      SizedBox(height: 8),
                      StartActivity(),
                      ApplicationList(),
                      PastLessons(),
                      PastLectureNotes(),
                      HelpMenu(),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    left: isWide ? 20 : 16,
                    right: isWide ? 20 : 16,
                    child: Column(
                      children: [
                        Material(
                          elevation: isWide ? 2 : 1,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(28),
                          color: searchBarFill,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: isWide ? 0.45 : 0.55),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchString = value;
                                  _showSearchResults = value.isNotEmpty;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _showSearchResults =
                                      _searchString.isNotEmpty;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search lessons, passages, notes…',
                                hintStyle: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.55),
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_searchString.isNotEmpty)
                                        IconButton(
                                          tooltip: 'Clear',
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchString = '';
                                              _showSearchResults = false;
                                            });
                                            _searchFocusNode.unfocus();
                                          },
                                        ),
                                      IconButton(
                                        tooltip: 'Settings',
                                        icon: Icon(
                                          Icons.settings_rounded,
                                          color:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                        onPressed: _openSettings,
                                      ),
                                    ],
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_showSearchResults)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            constraints: BoxConstraints(
                              maxHeight: size.height * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: isWide
                                  ? colorScheme.surfaceContainerHigh
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isWide ? 0.08 : 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  const SizedBox(height: 16),
                                  ContentSearches(searchString: _searchString),
                                  DivisionSearches(searchString: _searchString),
                                  ApplicationSearches(
                                      searchString: _searchString),
                                  AimSearches(searchString: _searchString),
                                  SummarySentenceSearches(
                                      searchString: _searchString),
                                  PassageSearches(searchString: _searchString),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
            )));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
