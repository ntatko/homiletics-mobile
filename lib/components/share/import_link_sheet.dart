import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/pages/import_preview_page.dart';
import 'package:homiletics/services/share_link.dart';
import 'package:homiletics/theme/app_theme.dart';

/// "Import from link": a field to paste a share link (or bare payload)
/// into, with a Paste button. The clipboard is only read when the user taps
/// Paste — never automatically (privacy, and iOS would show a paste
/// prompt). A good link closes the sheet and opens the preview.
Future<void> showImportLinkSheet(BuildContext context, {String? initialText}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) => _ImportLinkSheet(initialText: initialText),
  );
}

class _ImportLinkSheet extends StatefulWidget {
  final String? initialText;

  const _ImportLinkSheet({this.initialText});

  @override
  State<_ImportLinkSheet> createState() => _ImportLinkSheetState();
}

class _ImportLinkSheetState extends State<_ImportLinkSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final String text = data?.text?.trim() ?? '';
    setState(() {
      if (text.isEmpty) {
        _error = context.l10n.importClipboardEmpty;
      } else {
        _controller.text = text;
        _error = null;
      }
    });
    if (text.isNotEmpty) _open();
  }

  void _open() {
    final AppLocalizations l = context.l10n;
    final ShareLinkResult result = ShareLink.decode(_controller.text);
    switch (result) {
      case ShareLinkSuccess():
        final NavigatorState navigator = Navigator.of(context);
        navigator.pop();
        openShareLinkResult(navigator, result);
      case ShareLinkUnsupportedVersion():
        setState(() => _error = l.importNewerVersion);
      case ShareLinkInvalid():
        setState(() => _error = l.importInvalidLink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final bool hasText = _controller.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.importFromLink,
                  style: AppText.title.copyWith(color: c.ink)),
              const SizedBox(height: 6),
              Text(l.importSheetMessage,
                  style: AppText.body.copyWith(color: c.muted)),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('importLinkField'),
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.go,
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _open(),
                style: AppText.body.copyWith(color: c.ink),
                decoration: InputDecoration(
                  hintText: l.importFieldHint,
                  errorText: _error,
                  errorMaxLines: 4,
                  prefixIcon: Icon(Icons.link_rounded, color: c.muted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.tile),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('importPaste'),
                    onPressed: _paste,
                    icon: const Icon(Icons.content_paste_rounded, size: 18),
                    label: Text(l.importPaste),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('importOpen'),
                    onPressed: hasText ? _open : null,
                    child: Text(l.importOpen),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
