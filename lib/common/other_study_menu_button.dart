import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/common/start_passage_item_flow.dart';

/// Button that opens a menu of the non-Homiletics study types (Lecture
/// Note, Word Study, and whatever gets added later e.g. Character Study).
/// Kept as one shared widget since it's used everywhere a lesson/passage
/// offers "start a study" actions.
class OtherStudyMenuButton extends StatelessWidget {
  final String passage;
  final bool enabled;

  const OtherStudyMenuButton({
    Key? key,
    required this.passage,
    this.enabled = true,
  }) : super(key: key);

  Future<void> _showMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final String? choice = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
            value: 'lecture_note',
            child: Text(context.l10n.startMenuLectureNote)),
        PopupMenuItem(
            value: 'word_study', child: Text(context.l10n.startMenuWordStudy)),
      ],
    );

    if (choice == null || !context.mounted) return;
    switch (choice) {
      case 'lecture_note':
        startLectureNoteForPassage(context, passage);
        break;
      case 'word_study':
        startWordStudyForPassage(context, passage);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? () => _showMenu(context) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.startOtherStudy),
          const Icon(Icons.arrow_drop_down_rounded),
        ],
      ),
    );
  }
}
