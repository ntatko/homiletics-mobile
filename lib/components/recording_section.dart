import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/lecture_note.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/services/transcript_formatter_service.dart';
import 'package:homiletics/services/whisper_model_service.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/lecture_widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Lets the notes editor play a [RecordingSection]'s recording from a time
/// mark. Pass it to one RecordingSection at a time.
class RecordingSectionController {
  _RecordingSectionState? _state;

  /// While recording, taps on time marks should just place the cursor.
  bool get isRecording => _state?._isRecording ?? false;

  /// Plays the note's recording from [position] (seeking if it's already
  /// playing or paused), or shows a snackbar saying why it can't.
  Future<void> playFrom(Duration position) async {
    await _state?._playFrom(position);
  }
}

/// Record/playback/transcribe a lecture: the dark recording bar, then a
/// "My notes" | "Transcript" tab row. The notes tab shows [notesToolbar]
/// over [notesEditor]; the transcript tab shows the note's transcript.
class RecordingSection extends StatefulWidget {
  final LectureNote note;

  /// Pass the same widget instances on every build so the editor isn't
  /// rebuilt each time the recording clock ticks.
  final Widget notesToolbar;
  final Widget notesEditor;

  /// Inserts a time mark ("[14:02] ") into the notes. The "+ Time mark"
  /// button only shows while recording, and only when this is set.
  final ValueChanged<String>? onTimeMark;

  /// Lets the notes play the recording from a tapped time mark.
  final RecordingSectionController? controller;

  const RecordingSection({
    Key? key,
    required this.note,
    required this.notesToolbar,
    required this.notesEditor,
    this.onTimeMark,
    this.controller,
  }) : super(key: key);

  @override
  State<RecordingSection> createState() => _RecordingSectionState();
}

class _RecordingSectionState extends State<RecordingSection>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Amplitude>? _amplitudeSub;

  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (mounted) setState(() {});
    });

  /// Playback position and the player's idea of the file length.
  Duration _position = Duration.zero;
  Duration? _playerDuration;

  /// Recent microphone levels (0–1, oldest first) for the level meter.
  List<double> _levels = List.filled(5, 0);

  /// Formatted vs. raw transcript in the transcript tab.
  bool _showFormatted = true;

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
    widget.controller?._state = this;
    _playerStateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          _position = Duration.zero;
        }
      });
    });
    _positionSub = _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _durationSub = _player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() => _playerDuration = duration);
    });
    _loadRecordingDuration();
  }

  /// Starts feeding the level meter. Called once a recording has started:
  /// the recorder polls the level only while it's recording, and subscribing
  /// earlier would start that polling before there's anything to record.
  void _listenToLevel() {
    _amplitudeSub ??= _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 160))
        .listen((amplitude) {
      if (!mounted) return;
      // dBFS: about -45 is room noise, 0 is clipping.
      final double level = ((amplitude.current + 45) / 45).clamp(0.0, 1.0);
      setState(() => _levels = [..._levels.skip(1), level]);
    }, onError: (_) {
      // Only cosmetic.
    });
  }

  @override
  void didUpdateWidget(covariant RecordingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) {
        oldWidget.controller!._state = null;
      }
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller!._state = null;
    _timer?.cancel();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _amplitudeSub?.cancel();
    _tabs.dispose();
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
        title: Text(context.l10n.lectureReplaceTitle),
        content: Text(context.l10n.lectureReplaceMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.lectureReplaceConfirm),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.lectureMicPermissionRequired),
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
      final AppLocalizations l10n = context.l10n;
      final String fileName =
          'lecture_${widget.note.id}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      try {
        await _recorder.start(
          RecordConfig(
            // Runs recording in an Android foreground service (with an
            // ongoing notification) so it keeps going with the screen off.
            // iOS gets the same via UIBackgroundModes=audio in Info.plist.
            androidConfig: AndroidRecordConfig(
              // ignore: deprecated_member_use
              service: AndroidService(
                title: l10n.lectureNotificationTitle,
                content: l10n.lectureNotificationContent(l10n.appTitle),
              ),
            ),
          ),
          path: '${dir.path}/$fileName',
        );
      } catch (error) {
        sendError(error, "RecordingSection start");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.lectureStartFailed),
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
      _listenToLevel();
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
        title: Text(context.l10n.lectureTranscriptionModelTitle),
        content: Text(context.l10n.lectureTranscriptionModelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.lectureNotNow),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.lectureDownload),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.lectureModelDownloadFailed),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.lectureRecordingFileNotFound),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.lectureTranscriptionEmpty),
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
        title: Text(context.l10n.lectureFormattingModelTitle),
        content: Text(
            context.l10n.lectureFormattingModelMessage(localModelSizeLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.lectureNotNow),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.lectureDownload),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.lectureModelDownloadFailed),
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
            ? context.l10n.lectureFormattingModelMissing
            : context.l10n.lectureFormattingFailed),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.lectureRecordingFileNotFound),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.lecturePlaybackFailed),
      ));
    }
  }

  /// Only once something is playing or paused: before that the player has
  /// no position to move, and play() always starts from the beginning.
  bool get _canSeek =>
      _player.state == PlayerState.playing ||
      _player.state == PlayerState.paused;

  Future<void> _seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (error) {
      sendError(error, "RecordingSection seek");
    }
  }

  /// Plays from a tapped time mark: seeks if the recording is already
  /// playing or paused (resuming if paused), otherwise starts it there.
  Future<void> _playFrom(Duration position) async {
    if (!mounted) return;
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    void tell(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (_isRecording || _busy) {
      tell(l10n.lectureTimeMarkStopRecordingFirst);
      return;
    }
    if (widget.note.recordingPath == null) {
      tell(l10n.lectureTimeMarkNoRecording);
      return;
    }
    final Duration? total = _recordingDuration ?? _playerDuration;
    if (total != null && total > Duration.zero && position >= total) {
      tell(l10n.lectureTimeMarkPastEnd);
      return;
    }
    try {
      if (_canSeek) {
        await _player.seek(position);
        if (_player.state == PlayerState.paused) await _player.resume();
        return;
      }
      final String? path = await widget.note.recordingFilePath();
      if (path == null || !await File(path).exists()) {
        if (!mounted) return;
        tell(l10n.lectureRecordingFileNotFound);
        return;
      }
      if (!mounted) return;
      // Show the new spot right away instead of 0:00 until the first
      // position update arrives.
      setState(() => _position = position);
      await _player.play(DeviceFileSource(path), position: position);
    } catch (error) {
      sendError(error, "RecordingSection play from time mark");
      if (!mounted) return;
      tell(l10n.lecturePlaybackFailed);
    }
  }

  void _insertTimeMark() {
    final DateTime? startedAt = _recordingStartedAt;
    if (!_isRecording || startedAt == null) return;
    widget.onTimeMark
        ?.call('[${formatClock(DateTime.now().difference(startedAt))}] ');
  }

  /// The model download / transcription / formatting progress line, if any
  /// of those is running.
  Widget? _progressLine() {
    if (_isDownloadingModel) {
      return RecordingBarProgress(
        label: context.l10n.lectureDownloadingModel(
            (_downloadProgress * 100).toStringAsFixed(0)),
        value: _downloadProgress > 0 ? _downloadProgress : null,
      );
    }
    if (_isTranscribing) {
      return RecordingBarProgress(
        label: context.l10n.lectureTranscribingProgress(_transcribeProgress),
        value: _transcribeProgress > 0 ? _transcribeProgress / 100 : null,
      );
    }
    if (_isFormatting) {
      return RecordingBarProgress(
        label: _formatTotal > 0
            ? context.l10n.lectureFormattingProgress(_formatDone, _formatTotal)
            : context.l10n.lectureFormattingIndeterminate,
        value: _formatTotal > 0 ? _formatDone / _formatTotal : null,
      );
    }
    return null;
  }

  Widget _buildBar(BuildContext context, bool canRecord, bool canTranscribe) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final bool hasRecording = widget.note.recordingPath != null;

    if (_isRecording) {
      return RecordingBar(
        child: Row(
          children: [
            const RecordingDot(),
            const SizedBox(width: 14),
            Expanded(
              child: Semantics(
                label: l10n.lectureRecordingSemantics(formatClock(_elapsed)),
                excludeSemantics: true,
                child: RecordingBarTitle(
                  title: formatClock(_elapsed),
                  subtitle: l10n.lectureRecordingSubtitle,
                  clock: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            LevelMeter(levels: _levels),
            const SizedBox(width: 14),
            RecordingBarButton(
              tooltip: l10n.lectureStopRecording,
              size: 48,
              onPressed: _stopRecording,
              child: const StopGlyph(),
            ),
          ],
        ),
      );
    }

    final Widget? progress = _progressLine();

    if (!hasRecording) {
      return RecordingBar(
        onTap: canRecord ? _startRecording : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                RecordingBarButton(
                  tooltip: l10n.lectureRecordLecture,
                  size: 48,
                  onPressed: canRecord ? _startRecording : null,
                  child: const RecordGlyph(size: 16),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: RecordingBarTitle(
                    title: l10n.lectureRecordLecture,
                    subtitle: l10n.lectureRecordIdleSubtitle,
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              progress,
            ],
          ],
        ),
      );
    }

    return RecordingBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              RecordingBarButton(
                tooltip:
                    _isPlaying ? l10n.lecturePause : l10n.lecturePlayRecording,
                onPressed: _togglePlayback,
                child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PlaybackScrubber(
                  position: _position,
                  duration: _recordingDuration ?? _playerDuration,
                  onSeek: _canSeek ? _seek : null,
                ),
              ),
              const SizedBox(width: 12),
              RecordingBarButton(
                tooltip: l10n.lectureRecordAgain,
                filled: false,
                onPressed: canRecord ? _startRecording : null,
                child: const RecordGlyph(size: 12),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            progress,
          ] else if (canTranscribe)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.lectureNotTranscribedYet,
                        style: AppText.caption
                            .copyWith(color: recordingBarMuted(c))),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: recordingBarAccent(c),
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.subtitles_outlined, size: 18),
                    label: Text(l10n.lectureTranscribe),
                    onPressed: () => _maybeTranscribe(userRequested: true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            children: [
              Flexible(child: widget.notesToolbar),
              if (_isRecording && widget.onTimeMark != null)
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle:
                        AppText.caption.copyWith(fontWeight: FontWeight.w500),
                  ),
                  onPressed: _insertTimeMark,
                  child: Text(context.l10n.lectureTimeMark),
                ),
            ],
          ),
        ),
        Divider(height: 1, indent: 24, endIndent: 24, color: c.line),
        Expanded(child: widget.notesEditor),
      ],
    );
  }

  Widget _buildTranscriptTab(BuildContext context, bool canTranscribe) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final String raw = widget.note.transcript ?? '';
    final String? formatted = widget.note.formattedTranscript;

    if (raw.isEmpty) {
      final String message;
      if (_isRecording) {
        message = l10n.lectureTranscriptEmptyRecording;
      } else if (_isTranscribing || _isDownloadingModel) {
        message = l10n.lectureTranscriptEmptyPending;
      } else if (widget.note.recordingPath != null) {
        message = l10n.lectureTranscriptEmptyNotTranscribed;
      } else {
        message = l10n.lectureTranscriptEmptyNoRecording;
      }
      return TranscriptEmptyState(
        title: _isTranscribing
            ? l10n.lectureTranscribing
            : l10n.lectureNoTranscriptYet,
        message: message,
        action: canTranscribe
            ? FilledButton.icon(
                icon: const Icon(Icons.subtitles_outlined, size: 18),
                label: Text(l10n.lectureTranscribe),
                onPressed: () => _maybeTranscribe(userRequested: true),
              )
            : null,
      );
    }

    final bool showFormatted = formatted != null && _showFormatted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: formatted != null
                ? SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      selectedBackgroundColor: c.accentTint,
                      selectedForegroundColor: c.ink,
                      foregroundColor: c.muted,
                      side: BorderSide(color: c.line),
                      textStyle:
                          AppText.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    segments: [
                      ButtonSegment(
                          value: true, label: Text(l10n.lectureFormatted)),
                      ButtonSegment(value: false, label: Text(l10n.lectureRaw)),
                    ],
                    selected: {showFormatted},
                    onSelectionChanged: (selection) =>
                        setState(() => _showFormatted = selection.first),
                  )
                : !_isFormatting && !_isTranscribing
                    ? TextButton.icon(
                        style: TextButton.styleFrom(
                            minimumSize: const Size(0, 44)),
                        icon: const Icon(Icons.auto_fix_high, size: 18),
                        label: Text(l10n.lectureFormatTranscript),
                        onPressed: () => _maybeFormat(raw, userRequested: true),
                      )
                    : const SizedBox(height: 44),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: SelectableText(
              showFormatted ? formatted : raw,
              style: AppText.body.copyWith(height: 1.55, color: c.ink),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTranscript = (widget.note.transcript ?? '').isNotEmpty;
    final bool hasRecording = widget.note.recordingPath != null;
    // A new recording would delete the audio a transcription is reading.
    final bool canRecord = !_isTranscribing && !_isFormatting;
    final bool canTranscribe = hasRecording &&
        !hasTranscript &&
        !_isRecording &&
        !_isTranscribing &&
        !_isDownloadingModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBar(context, canRecord, canTranscribe),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          labelPadding: const EdgeInsets.only(right: 22),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(height: 44, text: context.l10n.lectureTabMyNotes),
            Tab(height: 44, text: context.l10n.lectureTabTranscript),
          ],
        ),
        Expanded(
          child: IndexedStack(
            index: _tabs.index,
            sizing: StackFit.expand,
            children: [
              _buildNotesTab(context),
              _buildTranscriptTab(context, canTranscribe),
            ],
          ),
        ),
      ],
    );
  }
}
