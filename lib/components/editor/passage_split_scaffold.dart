import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/vertical_bar.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/editor/fold_aware_split.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:split_view/split_view.dart';

/// An extra entry in the editor's app bar menu (e.g. Share / Print).
class EditorMenuAction {
  final IconData icon;
  final String title;
  final Future<void> Function() onSelected;

  /// Drawn in the danger color (e.g. Delete).
  final bool destructive;

  const EditorMenuAction({
    required this.icon,
    required this.title,
    required this.onSelected,
    this.destructive = false,
  });
}

/// The layout shared by every study editor: an app bar holding the passage
/// field, a back arrow, and a Save / Delete / [extraActions] / Preferences
/// menu; and a body that splits the study pane ([child]) and the passage's
/// verses side by side in landscape or stacked in portrait.
///
/// The verse pane follows the passage field once the user submits it or the
/// field loses focus, not on every keystroke.
class PassageSplitScaffold extends StatefulWidget {
  /// The passage the field and verse pane start with.
  final String initialPassage;

  /// Hint shown in the passage field when it's empty.
  final String? passageHint;

  /// Called on every edit of the passage field.
  final ValueChanged<String> onPassageChanged;

  /// The study pane.
  final Widget child;

  /// What's being deleted, used in the confirmation (e.g. "Word Study").
  final String itemName;

  /// Snack bar text after a successful delete (e.g. "Word Study Deleted").
  final String deletedMessage;

  /// Deletes the study. The scaffold confirms first, then closes the editor.
  final Future<void> Function() onDelete;

  /// Identifier passed to [sendError] if [onDelete] fails.
  final String deleteErrorIdentifier;

  /// Shown between Delete and Preferences in the menu.
  final List<EditorMenuAction> extraActions;

  /// Small label above the passage field (e.g. "Homiletics · Passage").
  /// Defaults to a localized "Passage".
  final String? headerLabel;

  /// In portrait, whether the verse panel sits above the study pane (true)
  /// or below it. In landscape the verses are always on the left.
  final bool versePanelFirst;

  /// Share of the height (portrait) or width (landscape) the verse panel
  /// starts with.
  final double verseWeight;

  /// Called when a verse number in the verse panel is tapped, with "4" —
  /// or "3:4" when the passage spans chapters. Verse numbers are only
  /// tappable when this is set.
  final ValueChanged<String>? onVerseTap;

  const PassageSplitScaffold({
    Key? key,
    required this.initialPassage,
    required this.onPassageChanged,
    required this.child,
    required this.itemName,
    required this.deletedMessage,
    required this.onDelete,
    required this.deleteErrorIdentifier,
    this.passageHint,
    this.extraActions = const [],
    this.headerLabel,
    this.versePanelFirst = true,
    this.verseWeight = 0.34,
    this.onVerseTap,
  }) : super(key: key);

  @override
  State<PassageSplitScaffold> createState() => _PassageSplitScaffoldState();
}

class _PassageSplitScaffoldState extends State<PassageSplitScaffold> {
  static const double _maxStudyWidth = 760;

  late final TextEditingController _passageController;
  final FocusNode _passageFocusNode = FocusNode();

  /// The passage the verse pane shows; lags the field until it's committed.
  late String _versePassage;

  // Global keys let both panes keep their state (scroll position, text
  // controllers, an in-progress recording...) when rotating swaps their
  // order: SplitView puts each child in an unkeyed Positioned, so without
  // these the panes would be torn down and rebuilt.
  final GlobalKey _studyPaneKey = GlobalKey();
  final GlobalKey<VerseContainerState> _versePaneKey =
      GlobalKey<VerseContainerState>();
  final GlobalKey _versePanelKey = GlobalKey();

  /// One per orientation (the pane order can differ between them); each
  /// keeps the user's divider position.
  final Map<bool, SplitViewController> _splitControllers = {};

  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _passageController = TextEditingController(text: widget.initialPassage);
    _versePassage = widget.initialPassage;
    _passageFocusNode.addListener(_onPassageFocusChange);
  }

  @override
  void dispose() {
    _passageFocusNode.removeListener(_onPassageFocusChange);
    _passageFocusNode.dispose();
    _passageController.dispose();
    super.dispose();
  }

  void _onPassageFocusChange() {
    if (!_passageFocusNode.hasFocus) _commitPassage();
  }

  void _commitPassage() {
    if (!mounted || _versePassage == _passageController.text) return;
    setState(() {
      _versePassage = _passageController.text;
    });
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  Future<void> _confirmDelete() async {
    if (_deleting) return;
    final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.l10n.editorDeleteConfirmTitle),
            content:
                Text(context.l10n.editorDeleteConfirmMessage(widget.itemName)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.commonCancel)),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text(context.l10n.commonDelete),
              )
            ],
          );
        });
    if (confirmed != true || !mounted || _deleting) return;

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l = context.l10n;
    _deleting = true;
    try {
      await widget.onDelete();
      if (mounted) navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text(widget.deletedMessage),
        action: SnackBarAction(
          onPressed: () {},
          label: l.commonOk,
        ),
      ));
    } catch (error) {
      messenger.showSnackBar(SnackBar(
        content: Text(l.commonSomethingWentWrong),
        action: SnackBarAction(
          onPressed: () {},
          label: l.commonOk,
        ),
      ));
      sendError(error, widget.deleteErrorIdentifier);
    } finally {
      _deleting = false;
    }
  }

  Future<void> _openPreferences() async {
    await showDialog(
        context: context,
        builder: ((context) => PreferencesModal(
              onTranslationChanged: () {
                // Rebuilding hands VerseContainer the new translation, and
                // its didUpdateWidget reloads the passage.
                if (mounted) setState(() {});
              },
            )));
  }

  Widget _buildVersePanel(AppColors c) {
    final translation = Preferences.translation;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          side: BorderSide(color: c.line),
        ),
        clipBehavior: Clip.antiAlias,
        // Nothing may be painted over the web view: on macOS, wherever
        // Flutter draws above a platform view it takes that view's mouse
        // events, so a border drawn on top cost the passage its clicks,
        // trackpad scrolling and text selection. The border goes
        // underneath instead, kept visible by the 1px inset.
        borderOnForeground: false,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.panel - 1),
            child: VerseContainer(
                key: _versePaneKey,
                passage: _versePassage,
                translation: translation,
                onTranslationTap: _openPreferences,
                onVerseTap: widget.onVerseTap),
          ),
        ),
      ),
    );
  }

  /// Whether the verse panel comes first in the draggable split.
  bool _verseFirst(bool isLandscape) => isLandscape || widget.versePanelFirst;

  SplitViewController _splitController(bool isLandscape) =>
      _splitControllers.putIfAbsent(isLandscape, () {
        final bool verseFirst = _verseFirst(isLandscape);
        return SplitViewController(
          weights: verseFirst
              ? [widget.verseWeight, 1 - widget.verseWeight]
              : [1 - widget.verseWeight, widget.verseWeight],
          limits: [WeightLimit(min: 0.12), WeightLimit(min: 0.2)],
        );
      });

  /// The verse panel's current share of the draggable split in [direction]
  /// (where a fold snap starts from). Reading it doesn't change the user's
  /// saved divider position.
  double _verseShare(Axis direction) {
    final bool isLandscape = direction == Axis.horizontal;
    final List<double?> weights = _splitController(isLandscape).weights;
    final double? share = weights[_verseFirst(isLandscape) ? 0 : 1];
    return share ?? widget.verseWeight;
  }

  /// Room around the passage header. With a vertical bar there's no back
  /// button on the left, and no status bar above to keep the overline off
  /// the screen's rounded corners, so it starts at least as far in as the
  /// corners need.
  static EdgeInsets _headerPadding(BuildContext context, VerticalBar? bar) {
    if (bar == null) return const EdgeInsets.fromLTRB(4, 8, 4, 4);
    // The bar already keeps its own side clear.
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    final bool barOnRight = bar.side == AxisDirection.right;
    return EdgeInsets.fromLTRB(
      barOnRight ? math.max(16, bar.cornerLeft - safe.left) : 16,
      8,
      barOnRight ? 4 : math.max(4, bar.cornerRight - safe.right),
      4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    // Preferences and Delete are always in the menu; on top it also holds
    // Save & close and the study's own actions, which the vertical bar
    // shows as buttons instead.
    final List<EditorMenuAction> settingsActions = [
      EditorMenuAction(
          icon: Icons.tune_rounded,
          title: l.commonPreferences,
          onSelected: _openPreferences),
      EditorMenuAction(
          icon: Icons.delete_outline_rounded,
          title: l.commonDelete,
          onSelected: _confirmDelete,
          destructive: true),
    ];
    final List<EditorMenuAction> menu = [
      EditorMenuAction(
          icon: Icons.check_rounded,
          title: l.editorSaveAndClose,
          onSelected: () async => _close()),
      ...widget.extraActions,
      ...settingsActions,
    ];

    // On desktops and wide tablets the editor would otherwise stretch to
    // 1000+ px; keep it at a comfortable reading width beside the verses.
    final Widget studyPane = KeyedSubtree(
      key: _studyPaneKey,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxStudyWidth),
          child: widget.child,
        ),
      ),
    );
    final Widget versePane =
        KeyedSubtree(key: _versePanelKey, child: _buildVersePanel(c));

    final VerticalBar? bar = VerticalBar.of(context);
    final Widget backButton = IconButton(
      tooltip: l.editorBack,
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      color: c.ink,
      onPressed: _close,
    );
    Widget menuButton(List<EditorMenuAction> actions) =>
        PopupMenuButton<EditorMenuAction>(
            tooltip: l.editorMoreOptions,
            onSelected: (action) => action.onSelected(),
            icon: Icon(Icons.more_vert_rounded, color: c.ink),
            itemBuilder: (context) => actions
                .map((action) => PopupMenuItem<EditorMenuAction>(
                      value: action,
                      child: Row(children: [
                        Icon(action.icon,
                            size: 20,
                            color: action.destructive ? c.danger : c.ink),
                        const SizedBox(width: 12),
                        Text(action.title,
                            style: AppText.body.copyWith(
                                color: action.destructive ? c.danger : c.ink)),
                      ]),
                    ))
                .toList());

    return VerticalBarLayout(
      // On the iPhone Duo's vertical bar: Back on top, then the study's
      // own actions as buttons, with the rest in the menu.
      groups: [
        BarGroup(children: [backButton]),
        BarGroup(children: [
          for (final EditorMenuAction action in widget.extraActions)
            IconButton(
              tooltip: action.title,
              icon: Icon(action.icon,
                  color: action.destructive ? c.danger : c.ink),
              onPressed: action.onSelected,
            ),
          menuButton(settingsActions),
        ]),
      ],
      child: Scaffold(
        backgroundColor: c.ground,
        body: SafeArea(
          bottom: true,
          child: Column(children: [
            Padding(
              padding: _headerPadding(context, bar),
              child: Row(children: [
                if (bar == null) backButton,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Overline(widget.headerLabel ?? l.editorPassageLabel),
                      TextField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: _passageController,
                        focusNode: _passageFocusNode,
                        style: AppText.passageField.copyWith(color: c.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          // A light underline marks the passage as
                          // editable; it turns accent while editing.
                          contentPadding: const EdgeInsets.only(bottom: 4),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: c.lineStrong)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: c.lineStrong)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: c.accent, width: 1.5)),
                          hintText:
                              widget.passageHint ?? l.editorAddPassageHint,
                          hintStyle:
                              AppText.passageField.copyWith(color: c.muted),
                        ),
                        onChanged: widget.onPassageChanged,
                        onSubmitted: (_) => _commitPassage(),
                      ),
                    ],
                  ),
                ),
                if (bar == null)
                  menuButton(menu)
                else
                  const SizedBox(width: 12),
              ]),
            ),
            Expanded(
              child: FoldAwareSplit(
                first: versePane,
                second: studyPane,
                startFraction: _verseShare,
                flat: (context) =>
                    LayoutBuilder(builder: (context, constraints) {
                  // Use screen size to determine orientation, not available
                  // space, so opening the keyboard doesn't flip the layout.
                  final screenSize = MediaQuery.sizeOf(context);
                  final isLandscape = screenSize.width > screenSize.height;
                  final bool verseFirst = _verseFirst(isLandscape);
                  final mode = isLandscape
                      ? SplitViewMode.Horizontal
                      : SplitViewMode.Vertical;
                  final controller = _splitController(isLandscape);
                  return SplitView(
                      controller: controller,
                      viewMode: mode,
                      gripSize: 22,
                      gripColor: c.ground,
                      gripColorActive: c.surfaceSunken,
                      indicator: DragHandle(
                          axis: isLandscape ? Axis.vertical : Axis.horizontal),
                      activeIndicator: DragHandle(
                          axis: isLandscape ? Axis.vertical : Axis.horizontal),
                      children: verseFirst
                          ? [versePane, studyPane]
                          : [studyPane, versePane]);
                }),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
