import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/common/start_passage_item_flow.dart';
import 'package:homiletics/pages/import_preview_page.dart';
import 'package:homiletics/services/share_link.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Home's pinned "＋ Study another passage…" field. Once a reference is
/// typed, buttons to start a homiletic, lecture note or word study on it
/// appear above the field; the keyboard's go key starts a homiletic. A
/// pasted share link instead offers "Open shared study".
class StartActivity extends StatefulWidget {
  const StartActivity({Key? key}) : super(key: key);

  @override
  State<StartActivity> createState() => _StartActivityState();
}

class _StartActivityState extends State<StartActivity> {
  final TextEditingController _controller = TextEditingController();
  String _passageReference = "";

  String get _passage => _passageReference.trim();

  bool get _isShareLink => ShareLink.looksLikeShareLink(_passage);

  void _openSharedStudy() {
    FocusScope.of(context).unfocus();
    final ShareLinkResult result = ShareLink.decode(_passage);
    if (result is ShareLinkSuccess) {
      _controller.clear();
      setState(() => _passageReference = '');
    }
    openShareLinkResult(Navigator.of(context), result);
  }

  void _start(Future<void> Function(BuildContext, String) flow) {
    if (_passage.isEmpty) return;
    if (_isShareLink) {
      _openSharedStudy();
      return;
    }
    FocusScope.of(context).unfocus();
    flow(context, _passage);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final bool hasPassage = _passage.isNotEmpty;
    final AppLocalizations l = context.l10n;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.tile),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.bottomCenter,
          child: hasPassage && _isShareLink
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton.icon(
                    key: const ValueKey('startOpenSharedStudy'),
                    onPressed: _openSharedStudy,
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: Text(l.startOpenSharedStudy,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                )
              : hasPassage
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _start(startHomileticForPassage),
                              child: Text(l.startHomiletics,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _start(startLectureNoteForPassage),
                              child: Text(l.startLecture,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _start(startWordStudyForPassage),
                              child: Text(l.startWordStudy,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
        ),
        TextField(
          controller: _controller,
          onChanged: (value) => setState(() {
            _passageReference = value;
          }),
          onSubmitted: (_) => _start(startHomileticForPassage),
          textInputAction: TextInputAction.go,
          style: AppText.body.copyWith(color: c.ink),
          decoration: InputDecoration(
            hintText: l.startPassageHint,
            prefixIcon: Icon(Icons.add_rounded, size: 20, color: c.muted),
            suffixIcon: hasPassage
                ? IconButton(
                    tooltip: l.startClear,
                    icon: Icon(Icons.close_rounded, size: 20, color: c.muted),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _passageReference = '');
                    },
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: border(c.line),
            enabledBorder: border(c.line),
            focusedBorder: border(c.accent, 1.5),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
