import 'package:flutter/material.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

/// Settings cards for the on-device transcription (Whisper) models: the
/// English-only model and the multilingual one. The model the current app
/// language needs comes first; the other can still be downloaded or deleted.
class WhisperModelSettings extends StatelessWidget {
  const WhisperModelSettings({Key? key}) : super(key: key);

  static const String _sizeLabel = '~140MB';

  String _detail(
      AppLocalizations l, WhisperModel model, bool needed, String language) {
    if (model == kEnglishTranscriptionModel) {
      return needed
          ? l.modelTranscriptionEnglishNeeded(language)
          : l.modelTranscriptionEnglishNotNeeded(language);
    }
    return needed
        ? l.modelTranscriptionMultilingualNeeded(language)
        : l.modelTranscriptionMultilingualNotNeeded(language);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l10n;
    final Language language = Preferences.effectiveLanguage;
    final WhisperModel required = whisperModelFor(language);
    final List<WhisperModel> models = [
      required,
      ...kTranscriptionModels.where((m) => m != required),
    ];
    return Column(
      children: [
        for (final WhisperModel model in models)
          ModelDownloadSettings(
            key: ValueKey(model),
            title: l.modelTranscriptionTitle,
            detail: _detail(l, model, model == required, language.name),
            sizeLabel: _sizeLabel,
            isDownloaded: () =>
                WhisperModelService.isModelDownloaded(model: model),
            sizeBytes: () => WhisperModelService.modelSizeBytes(model: model),
            download: ({onProgress}) => WhisperModelService.downloadModel(
                onProgress: onProgress, model: model),
            delete: () => WhisperModelService.deleteModel(model: model),
            isDownloading: () => WhisperModelService.isDownloadingModel(model),
          ),
      ],
    );
  }
}

/// Settings card for the transcript formatting model. Hidden where the local
/// model can't run, and download-free where Apple Intelligence is available.
class FormattingModelSettings extends StatelessWidget {
  const FormattingModelSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!TranscriptFormatterService.isLocalModelSupported) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l = context.l10n;
    return ModelDownloadSettings(
      title: l.modelFormattingTitle,
      sizeLabel: localModelSizeLabel,
      isDownloaded: TranscriptFormatterService.isLocalModelDownloaded,
      download: TranscriptFormatterService.downloadLocalModel,
      delete: TranscriptFormatterService.deleteLocalModel,
      builtInStatus: () async =>
          await TranscriptFormatterService.isAppleIntelligenceAvailable()
              ? l.modelAppleIntelligenceStatus
              : null,
    );
  }
}

/// Download/delete card for an optional on-device model. Mirrors
/// [PreferencesPanel]'s card style.
class ModelDownloadSettings extends StatefulWidget {
  final String title;

  /// Optional line under the title, e.g. which languages the model serves.
  final String? detail;

  /// Shown while not downloaded, e.g. "~140MB".
  final String sizeLabel;
  final Future<bool> Function() isDownloaded;

  /// Actual on-disk size once downloaded; the status omits it when null.
  final Future<int?> Function()? sizeBytes;
  final Future<void> Function({void Function(double progress)? onProgress})
      download;
  final Future<void> Function() delete;

  /// When this returns a message, the platform provides the model itself:
  /// the message is shown and the download controls are hidden.
  final Future<String?> Function()? builtInStatus;

  /// Whether a download started elsewhere (e.g. the editor prompt) is still
  /// running; the card then joins it instead of offering another one.
  final bool Function()? isDownloading;

  const ModelDownloadSettings({
    Key? key,
    required this.title,
    this.detail,
    required this.sizeLabel,
    required this.isDownloaded,
    this.sizeBytes,
    required this.download,
    required this.delete,
    this.builtInStatus,
    this.isDownloading,
  }) : super(key: key);

  @override
  State<ModelDownloadSettings> createState() => _ModelDownloadSettingsState();
}

enum _ModelState { checking, builtIn, notDownloaded, downloading, downloaded }

class _ModelDownloadSettingsState extends State<ModelDownloadSettings> {
  _ModelState _state = _ModelState.checking;
  double _downloadProgress = 0;
  int? _sizeBytes;
  String? _builtInMessage;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final String? builtIn = await widget.builtInStatus?.call();
    if (builtIn != null) {
      if (!mounted) return;
      setState(() {
        _state = _ModelState.builtIn;
        _builtInMessage = builtIn;
      });
      return;
    }

    if (widget.isDownloading?.call() == true) {
      if (mounted && _state != _ModelState.downloading) _download();
      return;
    }

    final bool downloaded = await widget.isDownloaded();
    final int? size = await widget.sizeBytes?.call();
    // A download started while this was checking owns the status now.
    if (!mounted || _state == _ModelState.downloading) return;
    setState(() {
      _state = downloaded ? _ModelState.downloaded : _ModelState.notDownloaded;
      _sizeBytes = size;
    });
  }

  Future<void> _download() async {
    setState(() {
      _state = _ModelState.downloading;
      _downloadProgress = 0;
    });
    try {
      await widget.download(
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _downloadProgress = progress);
        },
      );
      if (!mounted) return;
      setState(() => _state = _ModelState.checking);
      await _refreshStatus();
    } catch (error) {
      sendError(error, "ModelDownloadSettings download (${widget.title})");
      if (!mounted) return;
      setState(() => _state = _ModelState.notDownloaded);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.modelDownloadFailed),
      ));
    }
  }

  Future<void> _delete() async {
    try {
      await widget.delete();
      await _refreshStatus();
    } catch (error) {
      sendError(error, "ModelDownloadSettings delete (${widget.title})");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.modelDeleteFailed),
      ));
    }
  }

  String _statusText(AppLocalizations l) {
    switch (_state) {
      case _ModelState.checking:
        return l.modelStatusChecking;
      case _ModelState.builtIn:
        return _builtInMessage!;
      case _ModelState.notDownloaded:
        return l.modelStatusNotDownloaded(widget.sizeLabel);
      case _ModelState.downloading:
        return l.modelStatusDownloading(
            (_downloadProgress * 100).toStringAsFixed(0));
      case _ModelState.downloaded:
        if (_sizeBytes == null) return l.modelStatusDownloaded;
        final double mb = _sizeBytes! / (1024 * 1024);
        return l.modelStatusDownloadedSize(mb.toStringAsFixed(0));
    }
  }

  Widget? _trailing(AppLocalizations l) {
    switch (_state) {
      case _ModelState.checking:
        return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2));
      case _ModelState.builtIn:
        return null;
      case _ModelState.notDownloaded:
        return TextButton(onPressed: _download, child: Text(l.modelDownload));
      case _ModelState.downloading:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: _downloadProgress > 0 ? _downloadProgress : null,
          ),
        );
      case _ModelState.downloaded:
        return TextButton(
          onPressed: _delete,
          style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).danger),
          child: Text(l.modelDelete),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.tile,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(widget.title,
              style: AppText.bodyStrong.copyWith(fontSize: 15, color: c.ink)),
          subtitle: Text(
              widget.detail == null
                  ? _statusText(l)
                  : '${widget.detail}\n${_statusText(l)}',
              style: AppText.caption.copyWith(color: c.muted)),
          trailing: _trailing(l),
        ),
      ),
    );
  }
}
