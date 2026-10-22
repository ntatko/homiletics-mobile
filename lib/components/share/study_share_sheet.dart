import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/share_link.dart';
import 'package:homiletics/storage/pdf_generation.dart' show HandoutImages;
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// The ways to share a study, in one bottom sheet: as a link (system share
/// sheet, which includes AirDrop on Apple devices), copied to the
/// clipboard, as a QR code for another phone to scan, as square images
/// for social media, as a PDF, or printed.
///
/// [buildLink] is called when an option needs the link, so it reflects the
/// study as it is then. [title] (e.g. the passage) heads the QR sheet and
/// is the share subject.
Future<void> showStudyShareSheet(
  BuildContext context, {
  required String Function() buildLink,
  required String title,
  required Future<HandoutImages> Function() buildImages,
  required Future<void> Function() onSharePdf,
  required Future<void> Function() onPrint,
}) {
  final AppLocalizations l = context.l10n;

  // Runs [action] with the outer (editor) context once the sheet is gone.
  // [origin] is the tapped row, where an iPad / Mac popover points.
  void choose(
      BuildContext sheetContext, Future<void> Function(Rect? origin) action) {
    final Rect? origin = _globalRect(sheetContext);
    Navigator.of(sheetContext).pop();
    action(origin);
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final AppColors c = AppColors.of(sheetContext);
      Widget option(IconData icon, String label, String? subtitle,
              Future<void> Function(Rect? origin) action) =>
          Builder(builder: (rowContext) {
            return ListTile(
              leading: Icon(icon, color: c.accent),
              title: Text(label, style: AppText.body.copyWith(color: c.ink)),
              subtitle: subtitle == null
                  ? null
                  : Text(subtitle,
                      style: AppText.caption.copyWith(color: c.muted)),
              onTap: () => choose(rowContext, action),
            );
          });

      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(l.shareSheetTitle,
                    style: AppText.title.copyWith(color: c.ink)),
              ),
              option(
                  Icons.link_rounded,
                  l.shareLink,
                  l.shareLinkSubtitle,
                  (origin) => shareStudyLink(context, buildLink(), title,
                      origin: origin)),
              option(Icons.copy_rounded, l.shareCopyLink, null,
                  (_) => copyStudyLink(context, buildLink())),
              option(Icons.qr_code_2_rounded, l.shareShowQr, null,
                  (_) => showStudyQrCode(context, buildLink(), title)),
              Divider(color: c.line, height: 17, indent: 16, endIndent: 16),
              option(
                  Icons.image_outlined,
                  l.shareImages,
                  l.shareImagesSubtitle,
                  (origin) =>
                      shareStudyImages(context, buildImages, origin: origin)),
              option(Icons.picture_as_pdf_outlined, l.shareSharePdf, null,
                  (_) => onSharePdf()),
              option(
                  Icons.print_outlined, l.commonPrint, null, (_) => onPrint()),
            ],
          ),
        ),
      );
    },
  );
}

Rect? _globalRect(BuildContext context) {
  final RenderObject? box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Asks before sharing a link long enough that some apps may cut it off.
/// Returns whether to go ahead.
Future<bool> _confirmLongLink(BuildContext context, String link) async {
  if (link.length <= ShareLink.recommendedMaxLength) return true;
  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final AppLocalizations l = dialogContext.l10n;
      return AlertDialog(
        title: Text(l.shareLinkTooLongTitle),
        content: Text(l.shareLinkTooLongMessage(link.length)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.shareAnyway)),
        ],
      );
    },
  );
  return ok == true;
}

void _snack(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    action: SnackBarAction(onPressed: () {}, label: context.l10n.commonOk),
  ));
}

/// Opens the system share sheet with [link]. [origin] anchors the popover
/// on iPad / Mac (defaults to the middle of the screen).
Future<void> shareStudyLink(BuildContext context, String link, String title,
    {Rect? origin}) async {
  if (!await _confirmLongLink(context, link) || !context.mounted) return;
  final Size screen = MediaQuery.sizeOf(context);
  final Rect anchor = origin ??
      Rect.fromCenter(
          center: Offset(screen.width / 2, screen.height / 2),
          width: 1,
          height: 1);
  try {
    await SharePlus.instance.share(ShareParams(
      uri: Uri.parse(link),
      subject: title.trim().isEmpty ? null : title.trim(),
      title: title.trim().isEmpty ? null : title.trim(),
      sharePositionOrigin: anchor,
    ));
  } catch (error) {
    sendError(error, 'Share study link');
    if (context.mounted) _snack(context, context.l10n.shareLinkFailed);
  }
}

/// Copies [link] to the clipboard.
Future<void> copyStudyLink(BuildContext context, String link) async {
  if (!await _confirmLongLink(context, link) || !context.mounted) return;
  try {
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) _snack(context, context.l10n.shareLinkCopied);
  } catch (error) {
    sendError(error, 'Copy study link');
    if (context.mounted) _snack(context, context.l10n.shareLinkFailed);
  }
}

/// A sheet with [link] as a QR code big enough to scan from another phone,
/// under the study's [title].
Future<void> showStudyQrCode(BuildContext context, String link, String title) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _QrSheet(link: link, title: title),
  );
}

/// The QR code for [link], or null if it holds too much data. (The
/// package's validator only checks lazily, so the data is built here.)
QrCode? _qrFor(String link) {
  try {
    // Low error correction leaves the most room for data, which keeps the
    // modules as large as possible for a given link.
    final QrCode code =
        QrCode.fromData(data: link, errorCorrectLevel: QrErrorCorrectLevel.L);
    QrImage(code);
    return code;
  } on Exception {
    return null;
  }
}

class _QrSheet extends StatelessWidget {
  final String link;
  final String title;

  const _QrSheet({required this.link, required this.title});

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    final QrCode? qr = _qrFor(link);
    final Size screen = MediaQuery.sizeOf(context);
    final double side =
        (screen.shortestSide - 48).clamp(200.0, 440.0).toDouble();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Overline(l.shareQrTitle),
            const SizedBox(height: 6),
            if (title.trim().isNotEmpty)
              Text(title.trim(),
                  textAlign: TextAlign.center,
                  style: AppText.title.copyWith(color: c.ink)),
            const SizedBox(height: 16),
            if (qr != null)
              Semantics(
                image: true,
                label: l.shareQrSemantics,
                child: Container(
                  // Dark-on-white with a quiet zone, whatever the theme:
                  // scanners need the contrast.
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: QrImageView.withQr(
                    qr: qr,
                    size: side - 32,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square, color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.shareQrTooLong,
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(color: c.muted)),
              ),
            const SizedBox(height: 16),
            if (qr != null)
              Text(l.shareQrHint,
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(color: c.muted)),
          ],
        ),
      ),
    );
  }
}

/// Renders the study as square images and opens the system share sheet
/// with them on Android and iOS, or saves them to a folder the user picks
/// on desktop. [origin] anchors the popover on iPad / Mac.
Future<void> shareStudyImages(
    BuildContext context, Future<HandoutImages> Function() buildImages,
    {Rect? origin}) async {
  final AppLocalizations l = context.l10n;
  final Size screen = MediaQuery.sizeOf(context);
  final Rect anchor = origin ??
      Rect.fromCenter(
          center: Offset(screen.width / 2, screen.height / 2),
          width: 1,
          height: 1);
  try {
    final HandoutImages images = await buildImages();
    final List<String> names = images.fileNames;
    if (Platform.isAndroid || Platform.isIOS) {
      // Replaced on the next share rather than deleted now: the app the
      // images go to may still be reading them after the sheet closes.
      final Directory dir = Directory(
          path.join((await getTemporaryDirectory()).path, 'share_images'));
      if (await dir.exists()) await dir.delete(recursive: true);
      await dir.create(recursive: true);
      final List<XFile> files = [];
      for (final (int i, Uint8List png) in images.pngs.indexed) {
        final File file = File(path.join(dir.path, names[i]));
        await file.writeAsBytes(png);
        files.add(XFile(file.path, mimeType: 'image/png'));
      }
      await SharePlus.instance
          .share(ShareParams(files: files, sharePositionOrigin: anchor));
    } else {
      final String? folder = await getDirectoryPath();
      if (folder == null) return;
      for (final (int i, Uint8List png) in images.pngs.indexed) {
        await File(path.join(folder, names[i])).writeAsBytes(png);
      }
      if (context.mounted) _snack(context, l.shareImagesSaved);
    }
  } catch (error) {
    sendError(error, 'Share study images');
    if (context.mounted) _snack(context, l.shareImagesFailed);
  }
}
