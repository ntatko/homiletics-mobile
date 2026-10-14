import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:split_view/split_view.dart';

/// An extra entry in the editor's app bar menu (e.g. Share / Print).
class EditorMenuAction {
  final IconData icon;
  final String title;
  final Future<void> Function() onSelected;

  const EditorMenuAction({
    required this.icon,
    required this.title,
    required this.onSelected,
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
  final String headerLabel;

  /// In portrait, whether the verse panel sits above the study pane (true)
  /// or below it. In landscape the verses are always on the left.
  final bool versePanelFirst;

  /// Share of the height (portrait) or width (landscape) the verse panel
  /// starts with.
  final double verseWeight;

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
    this.headerLabel = 'Passage',
    this.versePanelFirst = true,
    this.verseWeight = 0.34,
  }) : super(key: key);

  @override
  State<PassageSplitScaffold> createState() => _PassageSplitScaffoldState();
}

class _PassageSplitScaffoldState extends State<PassageSplitScaffold> {
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
            title: const Text("Are you sure?"),
            content: Text(
                "Deleting this ${widget.itemName} is permanent and cannot be undone. Are you sure you wish to proceed?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text("Delete"),
              )
            ],
          );
        });
    if (confirmed != true || !mounted || _deleting) return;

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    _deleting = true;
    try {
      await widget.onDelete();
      if (mounted) navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text(widget.deletedMessage),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
        ),
      ));
    } catch (error) {
      messenger.showSnackBar(SnackBar(
        content: const Text("Something went wrong. Try again soon."),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 2),
              child: Row(children: [
                Expanded(child: Overline(translation.name)),
                Semantics(
                  button: true,
                  label: 'Change translation',
                  child: OutlinedButton(
                    onPressed: _openPreferences,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: BorderSide(color: c.line),
                      textStyle: AppText.caption
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(translation.short),
                      const Icon(Icons.expand_more_rounded, size: 16),
                    ]),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: VerseContainer(
                  key: _versePaneKey,
                  passage: _versePassage,
                  translation: translation),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final List<EditorMenuAction> menu = [
      EditorMenuAction(
          icon: Icons.check_rounded,
          title: "Save and close",
          onSelected: () async => _close()),
      ...widget.extraActions,
      EditorMenuAction(
          icon: Icons.tune_rounded,
          title: "Preferences",
          onSelected: _openPreferences),
      EditorMenuAction(
          icon: Icons.delete_outline_rounded,
          title: "Delete",
          onSelected: _confirmDelete),
    ];

    final Widget studyPane =
        KeyedSubtree(key: _studyPaneKey, child: widget.child);
    final Widget versePane =
        KeyedSubtree(key: _versePanelKey, child: _buildVersePanel(c));

    return Scaffold(
        backgroundColor: c.ground,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Row(children: [
                IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: c.ink,
                  onPressed: _close,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Overline(widget.headerLabel),
                      TextField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: _passageController,
                        focusNode: _passageFocusNode,
                        style: AppText.passageField.copyWith(color: c.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: widget.passageHint ?? 'Add a passage',
                          hintStyle:
                              AppText.passageField.copyWith(color: c.muted),
                        ),
                        onChanged: widget.onPassageChanged,
                        onSubmitted: (_) => _commitPassage(),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<EditorMenuAction>(
                    tooltip: 'More options',
                    onSelected: (action) => action.onSelected(),
                    icon: Icon(Icons.more_vert_rounded, color: c.ink),
                    itemBuilder: (context) => menu
                        .map((action) => PopupMenuItem<EditorMenuAction>(
                              value: action,
                              child: Row(children: [
                                Icon(action.icon,
                                    size: 20,
                                    color: action.title == 'Delete'
                                        ? c.danger
                                        : c.ink),
                                const SizedBox(width: 12),
                                Text(action.title,
                                    style: AppText.body.copyWith(
                                        color: action.title == 'Delete'
                                            ? c.danger
                                            : c.ink)),
                              ]),
                            ))
                        .toList()),
              ]),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                // Use screen size to determine orientation, not available
                // space, so opening the keyboard doesn't flip the layout.
                final screenSize = MediaQuery.sizeOf(context);
                final isLandscape = screenSize.width > screenSize.height;
                final bool verseFirst = isLandscape || widget.versePanelFirst;
                final mode = isLandscape
                    ? SplitViewMode.Horizontal
                    : SplitViewMode.Vertical;
                final controller = _splitControllers.putIfAbsent(
                    isLandscape,
                    () => SplitViewController(
                          weights: verseFirst
                              ? [widget.verseWeight, 1 - widget.verseWeight]
                              : [1 - widget.verseWeight, widget.verseWeight],
                          limits: [
                            WeightLimit(min: 0.12),
                            WeightLimit(min: 0.2)
                          ],
                        ));
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
          ]),
        ));
  }
}
