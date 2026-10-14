import 'package:flutter/material.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';

/// Settings card for the on-device transcription (Whisper) model.
class WhisperModelSettings extends StatelessWidget {
  const WhisperModelSettings({Key? key}) : super(key: key);

  static bool _isWhisperDownloading() => WhisperModelService.isDownloading;

  @override
  Widget build(BuildContext context) {
    return const ModelDownloadSettings(
      title: 'Offline transcription model',
      sizeLabel: '~140MB',
      isDownloaded: WhisperModelService.isModelDownloaded,
      sizeBytes: WhisperModelService.modelSizeBytes,
      download: WhisperModelService.downloadModel,
      delete: WhisperModelService.deleteModel,
      isDownloading: _isWhisperDownloading,
    );
  }
}

/// Settings card for the transcript formatting model. Hidden where the local
/// model can't run, and download-free where Apple Intelligence is available.
class FormattingModelSettings extends StatelessWidget {
  const FormattingModelSettings({Key? key}) : super(key: key);

  static Future<String?> _appleIntelligenceStatus() async =>
      await TranscriptFormatterService.isAppleIntelligenceAvailable()
          ? 'Using Apple Intelligence (no download needed)'
          : null;

  @override
  Widget build(BuildContext context) {
    if (!TranscriptFormatterService.isLocalModelSupported) {
      return const SizedBox.shrink();
    }
    return const ModelDownloadSettings(
      title: 'Transcript formatting model',
      sizeLabel: localModelSizeLabel,
      isDownloaded: TranscriptFormatterService.isLocalModelDownloaded,
      download: TranscriptFormatterService.downloadLocalModel,
      delete: TranscriptFormatterService.deleteLocalModel,
      builtInStatus: _appleIntelligenceStatus,
    );
  }
}

/// Download/delete card for an optional on-device model. Mirrors
/// [PreferencesPanel]'s Card/ListTile visual style.
class ModelDownloadSettings extends StatefulWidget {
  final String title;

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Something went wrong downloading the model. Try again soon."),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong deleting the model."),
      ));
    }
  }

  String get _statusText {
    switch (_state) {
      case _ModelState.checking:
        return "Checking…";
      case _ModelState.builtIn:
        return _builtInMessage!;
      case _ModelState.notDownloaded:
        return "Not downloaded (${widget.sizeLabel})";
      case _ModelState.downloading:
        return "Downloading… ${(_downloadProgress * 100).toStringAsFixed(0)}%";
      case _ModelState.downloaded:
        if (_sizeBytes == null) return "Downloaded";
        final double mb = _sizeBytes! / (1024 * 1024);
        return "Downloaded (${mb.toStringAsFixed(0)}MB)";
    }
  }

  Widget? get _trailing {
    switch (_state) {
      case _ModelState.checking:
        return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2));
      case _ModelState.builtIn:
        return null;
      case _ModelState.notDownloaded:
        return TextButton(onPressed: _download, child: const Text("Download"));
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
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Delete"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(widget.title),
            subtitle: Text(_statusText),
            trailing: _trailing,
          ),
        ),
      ),
    );
  }
}
