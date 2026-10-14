import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Record/playback/transcribe a lecture. Wires the already-existing
/// [LectureNote.recordingPath]/[LectureNote.transcript] fields into a real
/// UI for the first time.
class RecordingSection extends StatefulWidget {
  final LectureNote note;

  const RecordingSection({Key? key, required this.note}) : super(key: key);

  @override
  State<RecordingSection> createState() => _RecordingSectionState();
}

class _RecordingSectionState extends State<RecordingSection> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;

  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _elapsed = Duration.zero;
  DateTime? _recordingStartedAt;
  Timer? _timer;

  bool _isDownloadingModel = false;
  double _downloadProgress = 0;

  bool _isTranscribing = false;
  int _transcribeProgress = 0;

  bool _isFormatting = false;
  int _formatDone = 0;
  int _formatTotal = 0;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playerStateSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Microphone permission is required to record."),
      ));
      return;
    }

    final Directory dir = await getApplicationDocumentsDirectory();
    final String path =
        '${dir.path}/lecture_${widget.note.id}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        // Runs recording in an Android foreground service (with an ongoing
        // notification) so it keeps going with the screen off. iOS gets the
        // same via UIBackgroundModes=audio in Info.plist.
        androidConfig: AndroidRecordConfig(
          // ignore: deprecated_member_use
          service: AndroidService(
            title: "Recording lecture",
            content: "Homiletics is recording audio",
          ),
        ),
      ),
      path: path,
    );

    _recordingStartedAt = DateTime.now();
    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
    });
    // Derive elapsed from the start time rather than counting ticks: timers
    // don't fire reliably while the screen is off, so a tick counter would
    // come back short after the phone wakes up.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(
          () => _elapsed = DateTime.now().difference(_recordingStartedAt!));
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final String? path = await _recorder.stop();
    if (!mounted) return;
    setState(() => _isRecording = false);
    if (path == null) return;

    await widget.note.updateRecordingPath(path);
    if (!mounted) return;
    setState(() {});

    await _maybeTranscribe(path);
  }

  Future<void> _maybeTranscribe(String audioPath) async {
    if (await WhisperModelService.isModelDownloaded()) {
      await _runTranscription(audioPath);
      return;
    }

    if (Preferences.hasSeenTranscriptionPrompt) return;
    Preferences.hasSeenTranscriptionPrompt = true;
    if (!mounted) return;

    final bool? download = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Download offline transcription model?"),
        content: const Text(
            "A one-time ~140MB download lets your recordings be automatically transcribed and searched. You can skip this and download it later from Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Not now"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Download"),
          ),
        ],
      ),
    );
    if (download != true) return;
    await _downloadModelThenTranscribe(audioPath);
  }

  Future<void> _downloadModelThenTranscribe(String audioPath) async {
    setState(() {
      _isDownloadingModel = true;
      _downloadProgress = 0;
    });
    try {
      await WhisperModelService.downloadModel(onProgress: (progress) {
        if (!mounted) return;
        setState(() => _downloadProgress = progress);
      });
      if (!mounted) return;
      setState(() => _isDownloadingModel = false);
      await _runTranscription(audioPath);
    } catch (error) {
      sendError(error, "RecordingSection model download");
      if (!mounted) return;
      setState(() => _isDownloadingModel = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Something went wrong downloading the model. You can try again from Settings."),
      ));
    }
  }

  Future<void> _runTranscription(String audioPath) async {
    setState(() {
      _isTranscribing = true;
      _transcribeProgress = 0;
    });
    final String? text = await WhisperModelService.transcribe(
      audioPath,
      onProgress: (percent) {
        if (!mounted) return;
        setState(() => _transcribeProgress = percent);
      },
    );
    // Save before the mounted check: leaving the editor mid-transcription
    // shouldn't throw away the result.
    if (text != null && text.trim().isNotEmpty) {
      await widget.note.updateTranscript(text);
    }
    if (!mounted) return;
    setState(() => _isTranscribing = false);

    if (text == null || text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transcription didn't produce any text."),
      ));
      return;
    }

    await _maybeFormat(text);
  }

  /// Formats [transcript] if a formatting model is available. Otherwise
  /// offers the download once (or every time when [userRequested]).
  Future<void> _maybeFormat(String transcript,
      {bool userRequested = false}) async {
    if (await TranscriptFormatterService.availableBackend() !=
        FormatterBackend.none) {
      await _runFormatting(transcript);
      return;
    }
    if (!TranscriptFormatterService.isLocalModelSupported) return;
    if (!userRequested && Preferences.hasSeenFormattingPrompt) return;
    Preferences.hasSeenFormattingPrompt = true;
    if (!mounted) return;

    final bool? download = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Download transcript formatting model?"),
        content: const Text(
            "A one-time $localModelSizeLabel download lets transcripts be cleaned up into readable paragraphs, entirely on your device. Wi-Fi recommended. You can also do this later from Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Not now"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Download"),
          ),
        ],
      ),
    );
    if (download != true || !mounted) return;

    setState(() {
      _isDownloadingModel = true;
      _downloadProgress = 0;
    });
    try {
      await TranscriptFormatterService.downloadLocalModel(
          onProgress: (progress) {
        if (!mounted) return;
        setState(() => _downloadProgress = progress);
      });
    } catch (error) {
      sendError(error, "RecordingSection formatting model download");
      if (!mounted) return;
      setState(() => _isDownloadingModel = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Something went wrong downloading the model. You can try again from Settings."),
      ));
      return;
    }
    if (!mounted) return;
    setState(() => _isDownloadingModel = false);
    await _runFormatting(transcript);
  }

  Future<void> _runFormatting(String transcript) async {
    setState(() {
      _isFormatting = true;
      _formatDone = 0;
      _formatTotal = 0;
    });
    final String? formatted = await TranscriptFormatterService.format(
      transcript,
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() {
          _formatDone = done;
          _formatTotal = total;
        });
      },
    );
    if (formatted != null) {
      await widget.note.updateFormattedTranscript(formatted);
    }
    if (!mounted) return;
    setState(() => _isFormatting = false);
    if (formatted == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Couldn't format the transcript."),
      ));
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else if (widget.note.recordingPath != null) {
      await _player.play(DeviceFileSource(widget.note.recordingPath!));
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  void _showTranscriptSheet(BuildContext context) {
    final String raw = widget.note.transcript ?? '';
    final String? formatted = widget.note.formattedTranscript;
    bool showFormatted = formatted != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (formatted != null)
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text("Formatted")),
                        ButtonSegment(value: false, label: Text("Original")),
                      ],
                      selected: {showFormatted},
                      onSelectionChanged: (selection) =>
                          setSheetState(() => showFormatted = selection.first),
                    )
                  else if (!_isFormatting)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.auto_fix_high, size: 18),
                        label: const Text("Format transcript"),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _maybeFormat(raw, userRequested: true);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SelectableText(
                        showFormatted ? formatted! : raw,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTranscript = (widget.note.transcript ?? '').isNotEmpty;
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic,
              color: _isRecording ? Colors.red : null),
          onPressed: _isRecording ? _stopRecording : _startRecording,
        ),
        Text(_formatDuration(_elapsed),
            style: Theme.of(context).textTheme.bodySmall),
        if (!_isRecording && widget.note.recordingPath != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 20),
            onPressed: _togglePlayback,
          ),
        if (_isDownloadingModel) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: _downloadProgress > 0 ? _downloadProgress : null,
            ),
          ),
          const SizedBox(width: 4),
          Text("${(_downloadProgress * 100).toStringAsFixed(0)}%",
              style: Theme.of(context).textTheme.bodySmall),
        ],
        if (_isTranscribing) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 4),
          Text("Transcribing $_transcribeProgress%",
              style: Theme.of(context).textTheme.bodySmall),
        ],
        if (_isFormatting) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: _formatTotal > 0 ? _formatDone / _formatTotal : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(
              _formatTotal > 0
                  ? "Formatting $_formatDone/$_formatTotal"
                  : "Formatting…",
              style: Theme.of(context).textTheme.bodySmall),
        ],
        const Spacer(),
        if (hasTranscript && !_isTranscribing && !_isFormatting)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.subject, size: 20),
            tooltip: "View transcript",
            onPressed: () => _showTranscriptSheet(context),
          ),
      ],
    );
  }
}
