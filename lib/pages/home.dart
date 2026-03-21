import 'package:flutter/material.dart';
import 'package:homiletics/components/application_list.dart';
import 'package:homiletics/components/current_lesson.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/past_lecture_notes.dart';
import 'package:homiletics/components/past_lessons.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/components/sign_in_modal.dart';
import 'package:homiletics/components/start_activity.dart';
import 'package:homiletics/pages/search_page.dart';
import 'package:homiletics/services/auth_storage.dart';
import 'package:homiletics/services/realtime_sync_client.dart';
import 'package:homiletics/services/sync_service.dart';
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

class _HomeSearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeSearchBarHeaderDelegate({
    required this.extent,
    required this.child,
  });

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 1 : 0,
      shadowColor: Colors.black26,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _HomeSearchBarHeaderDelegate oldDelegate) =>
      oldDelegate.extent != extent || oldDelegate.child != child;
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  String _searchString = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  bool? _signedIn;

  /// Bumped on pull-to-refresh so [CurrentLessonActions] is recreated and refetches suggested passages.
  int _suggestedPassagesRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAuthState();
  }

  static const _authStateTimeout = Duration(seconds: 5);
  static const _maxBodyWidthTablet = 760.0;
  static const _maxBodyWidthDesktop = 900.0;

  double _contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return _maxBodyWidthDesktop;
    if (width >= 840) return _maxBodyWidthTablet;
    return width;
  }

  Future<void> _loadAuthState() async {
    bool signedIn = false;
    try {
      signedIn = await isSignedIn.timeout(
        _authStateTimeout,
        onTimeout: () => false,
      );
    } catch (_) {
      signedIn = false;
    }
    if (mounted) setState(() => _signedIn = signedIn);
  }

  Future<void> _onRefresh() async {
    await SyncService.instance.syncNowIfSignedIn();
    await _loadAuthState();
    if (mounted) {
      setState(() {
        _suggestedPassagesRefreshKey++;
      });
    }
  }

  Future<void> _openPreferences() async {
    await showDialog(
      context: context,
      builder: (context) => PreferencesModal(
        onSignedOut: () {
          _loadAuthState();
          if (mounted) setState(() {});
        },
      ),
    );
    await _loadAuthState();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAuthState();
      SyncService.instance.pullIfSignedIn();
      RealtimeSyncClient.instance.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = _contentMaxWidth(context);

    return Scaffold(
        // appBar: AppBar(title: const Text('Homiletics')),
        // bottomNavigationBar: BottomAppBar(
        //   shape: const CircularNotchedRectangle(),
        //   child: TextButton(
        //     child: const Text("reset the data"),
        //     onPressed: () async {
        //       await resetTable();
        //       await resetApplicationsTable();
        //       await resetDivisionsTable();
        //       await resetSummariesTable();
        //       await resetLectureNoteTable();
        //     },
        //   ),
        // ),
        body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _HomeSearchBarHeaderDelegate(
                      extent: 16 +
                          60 +
                          (_showSearchResults
                              ? 8 + MediaQuery.of(context).size.height * 0.5
                              : 0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _searchString = value;
                                            _showSearchResults =
                                                value.isNotEmpty;
                                          });
                                        },
                                        onTap: () {
                                          setState(() {
                                            _showSearchResults =
                                                _searchString.isNotEmpty;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Search...",
                                          hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withOpacity(0.6),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                          suffixIcon: _searchString.isNotEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _searchString = '';
                                                      _showSearchResults =
                                                          false;
                                                    });
                                                    _searchFocusNode.unfocus();
                                                  },
                                                )
                                              : null,
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Settings',
                                      icon: const Icon(Icons.settings_outlined),
                                      onPressed: _openPreferences,
                                    ),
                                    const SizedBox(width: 8),
                                  ]),
                                ),
                                if (_showSearchResults)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          const SizedBox(height: 16),
                                          ContentSearches(
                                              searchString: _searchString),
                                          DivisionSearches(
                                              searchString: _searchString),
                                          ApplicationSearches(
                                              searchString: _searchString),
                                          AimSearches(
                                              searchString: _searchString),
                                          SummarySentenceSearches(
                                              searchString: _searchString),
                                          PassageSearches(
                                              searchString: _searchString),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(children: [
                          const SizedBox(height: 16),
                          // Sign in (in scroll flow when not signed in)
                          if (_signedIn == false) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'You can sign in to sync your data across devices. The app works fully without signing in.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.75),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => SignInModal(
                                              onSignedIn: () {
                                                _loadAuthState();
                                              },
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Sign in',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          CurrentLessonActions(
                            key: ValueKey(_suggestedPassagesRefreshKey),
                          ),
                          const StartActivity(),
                          const ApplicationList(),
                          const PastLessons(),
                          const PastLectureNotes(),
                          HelpMenu(onOpenSettings: _openPreferences),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
