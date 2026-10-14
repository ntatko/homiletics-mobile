import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/homiletic_progress.dart';
import 'package:homiletics/common/relative_time.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/home_widgets.dart';
import 'package:loggy/loggy.dart';

/// A saved homiletic in a list: passage, "Homiletics · 2 of 6 steps · 3
/// days ago". Opens the editor.
class HomileticListItem extends StatefulWidget {
  final Homiletic homiletic;
  final bool divider;

  const HomileticListItem(
      {Key? key, required this.homiletic, this.divider = true})
      : super(key: key);

  @override
  State<HomileticListItem> createState() => _HomileticListItemState();
}

class _HomileticListItemState extends State<HomileticListItem> {
  Set<StudyStep>? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didUpdateWidget(HomileticListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A reload hands in a fresh object; its steps may have changed.
    if (!identical(oldWidget.homiletic, widget.homiletic)) _loadProgress();
  }

  Future<void> _loadProgress() async {
    final Homiletic homiletic = widget.homiletic;
    try {
      final Set<StudyStep> done = await loadHomileticProgress(homiletic);
      if (!mounted || !identical(homiletic, widget.homiletic)) return;
      setState(() => _progress = done);
    } catch (error) {
      logError('Loading homiletic progress failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Homiletic homiletic = widget.homiletic;
    final AppLocalizations l = context.l10n;
    final String time =
        relativeTime(context, homiletic.updatedAt ?? DateTime.now());
    final String subtitle = _progress == null
        ? l.studiesHomileticSubtitleNoProgress(time)
        : l.studiesHomileticSubtitle(describeProgress(l, _progress), time);
    return StudyListRow(
      key: Key("${homiletic.id}"),
      leading: const StudyKindTile(StudyKind.homiletic),
      title:
          homiletic.passage.isNotEmpty ? homiletic.passage : l.commonUntitled,
      subtitle: subtitle,
      divider: widget.divider,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomileticEditor(homiletic: homiletic)));
      },
    );
  }
}
