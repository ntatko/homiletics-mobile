import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/preferences_modal.dart';
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

  @override
  Widget build(BuildContext context) {
    final List<EditorMenuAction> menu = [
      EditorMenuAction(
          icon: Icons.save, title: "Save", onSelected: () async => _close()),
      EditorMenuAction(
          icon: Icons.delete, title: "Delete", onSelected: _confirmDelete),
      ...widget.extraActions,
      EditorMenuAction(
          icon: Icons.settings,
          title: "Preferences",
          onSelected: _openPreferences),
    ];

    final Widget studyPane =
        KeyedSubtree(key: _studyPaneKey, child: widget.child);
    final Widget versePane = VerseContainer(
        key: _versePaneKey,
        passage: _versePassage,
        translation: Preferences.translation);

    return Scaffold(
        appBar: AppBar(
          title: TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: _passageController,
            focusNode: _passageFocusNode,
            decoration: InputDecoration(
                hintText: widget.passageHint,
                suffixIcon: const Icon(Icons.edit)),
            onChanged: widget.onPassageChanged,
            onSubmitted: (_) => _commitPassage(),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
          actions: [
            PopupMenuButton<EditorMenuAction>(
                onSelected: (action) => action.onSelected(),
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => menu
                    .map((action) => PopupMenuItem<EditorMenuAction>(
                          value: action,
                          child: ListTile(
                              leading: Icon(action.icon),
                              title: Text(action.title)),
                        ))
                    .toList()),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          // Use screen size to determine orientation, not available space
          // This prevents keyboard opening from triggering layout changes
          final screenSize = MediaQuery.sizeOf(context);
          final isLandscape = screenSize.width > screenSize.height;

          return SafeArea(
            bottom: false,
            child: SplitView(
                indicator: SplitIndicator(
                    viewMode: isLandscape
                        ? SplitViewMode.Horizontal
                        : SplitViewMode.Vertical),
                viewMode: isLandscape
                    ? SplitViewMode.Horizontal
                    : SplitViewMode.Vertical,
                children: isLandscape
                    ? [versePane, studyPane]
                    : [studyPane, versePane]),
          );
        }));
  }
}
