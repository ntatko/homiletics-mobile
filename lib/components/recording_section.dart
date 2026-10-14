import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';
import 'package:path/path.dart' as p;
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

  /// Length of the saved recording, shown when not recording. Null until
  /// it's known (or when there's no recording).
  Duration? _recordingDuration;

  /// Set synchronously while starting/stopping so a double tap can't start
  /// two recordings or stop one twice.
  bool _busy = false;

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
    _loadRecordingDuration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playerStateSub?.cancel();
    // The file name was saved when recording started, so stopping here
    // finalizes the audio even though nobody is around to transcribe it.
    // The recorder serializes its calls, so dispose runs after stop.
    if (_isRecording || _busy) {
      _recorder.stop().catchError((error) {
        sendError(error, "RecordingSection dispose stop");
        return null;
      });
    }
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadRecordingDuration() async {
    try {
      final String? path = await widget.note.recordingFilePath();
      if (path == null || !await File(path).exists()) return;
      await _player.setSource(DeviceFileSource(path));
      final Duration? duration = await _player.getDuration();
      if (!mounted || _isRecording) return;
      setState(() => _recordingDuration = duration);
    } catch (_) {
      // Only cosmetic; playback reports its own errors.
    }
  }

  Future<bool> _confirmReplace() async {
    final bool? replace = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Replace existing recording?"),
        content: const Text("The old audio and transcript will be deleted."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Replace"),
          ),
        ],
      ),
    );
    return replace == true;
  }

  Future<void> _startRecording() async {
    if (_busy || _isRecording) return;
    _busy = true;
    try {
      if (widget.note.recordingPath != null && !await _confirmReplace()) {
        return;
      }
      if (!mounted) return;
      if (!await _recorder.hasPermission()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Microphone permission is required to record."),
        ));
        return;
      }
      if (!mounted) return;
      try {
        await _player.stop();
      } catch (_) {
        // Nothing was playing.
      }

      final Directory dir = await getApplicationDocumentsDirectory();
      // Once disposed nobody could stop a recording started now.
      if (!mounted) return;
      final String fileName =
          'lecture_${widget.note.id}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      try {
        await _recorder.start(
          const RecordConfig(
            // Runs recording in an Android foreground service (with an
            // ongoing notification) so it keeps going with the screen off.
            // iOS gets the same via UIBackgroundModes=audio in Info.plist.
            androidConfig: AndroidRecordConfig(
              // ignore: deprecated_member_use
              service: AndroidService(
                title: "Recording lecture",
                content: "Homiletics is recording audio",
              ),
            ),
          ),
          path: '${dir.path}/$fileName',
        );
      } catch (error) {
        sendError(error, "RecordingSection start");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Couldn't start recording. The microphone may be in use by another app."),
        ));
        return;
      }

      _isRecording = true;
      _recordingStartedAt = DateTime.now();
      // Save right away (this also deletes the replaced recording and its
      // transcript) so leaving the editor mid-lecture keeps the audio.
      try {
        await widget.note.updateRecordingPath(fileName);
      } catch (error) {
        // _stopRecording saves it again.
        sendError(error, "RecordingSection save recording");
      }

      if (!mounted) return;
      setState(() {
        _elapsed = Duration.zero;
        _recordingDuration = null;
      });
      // Derive elapsed from the start time rather than counting ticks:
      // timers don't fire reliably while the screen is off, so a tick
      // counter would come back short after the phone wakes up.
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(
            () => _elapsed = DateTime.now().difference(_recordingStartedAt!));
      });
    } finally {
      _busy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _stopRecording() async {
    if (_busy || !_isRecording) return;
    _busy = true;
    _timer?.cancel();
    String? path;
    try {
      path = await _recorder.stop();
    } catch (error) {
      sendError(error, "RecordingSection stop");
    } finally {
      _isRecording = false;
      _busy = false;
    }
    // Make sure the note points at this file even if the save when
    // recording started failed; this runs whether or not we're mounted.
    if (path != null && widget.note.recordingPath != p.basename(path)) {
      await widget.note.updateRecordingPath(path);
    }
    if (!mounted) return;
    setState(() {
      if (_recordingStartedAt != null) {
        _recordingDuration = DateTime.now().difference(_recordingStartedAt!);
      }
    });
    if (path == null) return;

    await _maybeTranscribe();
  }

  /// Transcribes the note's current recording if the model is downloaded,
  /// otherwise offers the download once (or every time when
  /// [userRequested]).
  Future<void> _maybeTranscribe({bool userRequested = false}) async {
    if (await WhisperModelService.isModelDownloaded()) {
      await _runTranscription();
      return;
    }

    if (!userRequested && Preferences.hasSeenTranscriptionPrompt) return;
    if (!mounted) return;
    Preferences.hasSeenTranscriptionPrompt = true;

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
    if (download != true || !mounted) return;
    await _downloadModelThenTranscribe();
  }

  Future<void> _downloadModelThenTranscribe() async {
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
      await _runTranscription();
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

  Future<void> _runTranscription() async {
    if (_isTranscribing || _isRecording) return;
    // Captured up front: the result only belongs to this file, and the note
    // may get a new recording (or be deleted) while Whisper runs.
    final String? fileName = widget.note.recordingPath;
    final String? audioPath = await widget.note.recordingFilePath();
    if (!mounted) return;
    if (fileName == null ||
        audioPath == null ||
        !await File(audioPath).exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("The recording file couldn't be found."),
      ));
      return;
    }
    if (!mounted) return;

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
    final bool stillCurrent =
        widget.note.recordingPath == fileName && !widget.note.isDeleted;
    // Save before the mounted check: leaving the editor mid-transcription
    // shouldn't throw away the result.
    if (stillCurrent && text != null && text.trim().isNotEmpty) {
      await widget.note.updateTranscript(text);
    }
    if (!mounted) return;
    setState(() => _isTranscribing = false);
    if (!stillCurrent) return;

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
    if (!mounted) return;
    Preferences.hasSeenFormattingPrompt = true;

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
    if (_isFormatting || !mounted) return;
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
    // Only keep it if it was formatted from the transcript the note still has.
    final bool stillCurrent =
        widget.note.transcript == transcript && !widget.note.isDeleted;
    if (formatted != null && stillCurrent) {
      await widget.note.updateFormattedTranscript(formatted);
    }
    if (!mounted) return;
    setState(() => _isFormatting = false);
    if (formatted == null && stillCurrent) {
      final bool modelMissing =
          await TranscriptFormatterService.availableBackend() ==
              FormatterBackend.none;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(modelMissing
            ? "The formatting model isn't downloaded."
            : "Couldn't format the transcript."),
      ));
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }
      final String? path = await widget.note.recordingFilePath();
      if (path == null || !await File(path).exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("The recording file couldn't be found."),
        ));
        return;
      }
      if (_player.state == PlayerState.paused) {
        await _player.resume();
      } else {
        await _player.play(DeviceFileSource(path));
      }
    } catch (error) {
      sendError(error, "RecordingSection playback");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Couldn't play the recording."),
      ));
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
    final bool hasRecording = widget.note.recordingPath != null;
    // A new recording would delete the audio a transcription is reading.
    final bool canRecord = !_isTranscribing && !_isFormatting;
    final Duration? shownDuration =
        _isRecording ? _elapsed : _recordingDuration;
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic,
              color: _isRecording ? Colors.red : null),
          onPressed: _isRecording
              ? _stopRecording
              : canRecord
                  ? _startRecording
                  : null,
        ),
        if (shownDuration != null)
          Text(_formatDuration(shownDuration),
              style: Theme.of(context).textTheme.bodySmall),
        if (!_isRecording && hasRecording)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle,
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
        if (hasRecording &&
            !hasTranscript &&
            !_isRecording &&
            !_isTranscribing &&
            !_isDownloadingModel)
          TextButton.icon(
            icon: const Icon(Icons.subtitles, size: 18),
            label: const Text("Transcribe"),
            onPressed: () => _maybeTranscribe(userRequested: true),
          ),
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
