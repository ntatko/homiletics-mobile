import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';

/// "mm:ss" (minutes keep counting past an hour), as shown on the recording
/// bar and in time marks.
String formatClock(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
}

/// Tabular figures, so a running clock doesn't jitter.
const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

/// How a tappable time mark ("[14:02]") reads inside the notes: accent
/// text on the accent tint, with tabular figures. (Quill draws marks as
/// plain text runs, so the tint is a flat highlight rather than a pill.)
TextStyle timeMarkTextStyle(AppColors c) => TextStyle(
      color: c.accent,
      backgroundColor: c.accentTint,
      fontWeight: FontWeight.w600,
      fontFeatures: _tabular,
    );

/// Secondary text on the dark recording bar.
Color recordingBarMuted(AppColors c) =>
    c.onRecordingBar.withValues(alpha: 0.72);

/// The accent as it reads on the dark recording bar (level meter, links).
Color recordingBarAccent(AppColors c) =>
    Color.lerp(c.accent, c.onRecordingBar, 0.5)!;

/// The dark rounded card at the top of the lecture editor that holds the
/// record / playback controls.
class RecordingBar extends StatelessWidget {
  final Widget child;

  /// Makes the whole bar tappable (the idle "Record lecture" state).
  final VoidCallback? onTap;

  const RecordingBar({Key? key, required this.child, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final BorderRadius br = BorderRadius.circular(AppRadius.panel);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Material(
        color: c.recordingBar,
        borderRadius: br,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
            child: IconTheme(
              data: IconThemeData(color: c.onRecordingBar),
              child: DefaultTextStyle(
                style: AppText.body.copyWith(color: c.onRecordingBar),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Big tabular clock + one line of secondary text, for the recording bar.
class RecordingBarTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Uses the large 22px clock style instead of the 16px label style.
  final bool clock;

  const RecordingBarTitle({
    Key? key,
    required this.title,
    required this.subtitle,
    this.clock = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: clock
              ? TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  fontFeatures: _tabular,
                  color: c.onRecordingBar)
              : AppText.bodyStrong.copyWith(
                  fontWeight: FontWeight.w600, color: c.onRecordingBar),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12,
              color: recordingBarMuted(c)),
        ),
      ],
    );
  }
}

/// The live-recording dot; pulses unless animations are disabled.
class RecordingDot extends StatefulWidget {
  const RecordingDot({Key? key}) : super(key: key);

  @override
  State<RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<RecordingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.35,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.of(context).recording,
        shape: BoxShape.circle,
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return dot;
    return FadeTransition(opacity: _pulse, child: dot);
  }
}

/// A few bars showing the live microphone level. Each of [levels] is 0–1,
/// oldest first.
class LevelMeter extends StatelessWidget {
  final List<double> levels;

  const LevelMeter({Key? key, required this.levels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = recordingBarAccent(AppColors.of(context));
    return ExcludeSemantics(
      child: SizedBox(
        height: 28,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final double level in levels)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 3,
                  height: 4 + 24 * level.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A circular button on the recording bar.
class RecordingBarButton extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  /// Filled with the bar's foreground color (stop, play) instead of a
  /// subtle outline (record again).
  final bool filled;

  const RecordingBarButton({
    Key? key,
    required this.child,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.filled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final bool enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: filled
              ? c.onRecordingBar
              : c.onRecordingBar.withValues(alpha: 0.08),
          shape: CircleBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(color: c.onRecordingBar.withValues(alpha: 0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: c.recordingBar, size: 22),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The red square inside the stop button.
class StopGlyph extends StatelessWidget {
  const StopGlyph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.of(context).recording,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// The red dot inside the record buttons.
class RecordGlyph extends StatelessWidget {
  final double size;

  const RecordGlyph({Key? key, this.size = 14}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.of(context).recording,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Playback progress with current/total time. Dragging calls [onSeek] when
/// it's set; otherwise the bar is read-only.
class PlaybackScrubber extends StatefulWidget {
  final Duration position;
  final Duration? duration;
  final ValueChanged<Duration>? onSeek;

  const PlaybackScrubber({
    Key? key,
    required this.position,
    required this.duration,
    this.onSeek,
  }) : super(key: key);

  @override
  State<PlaybackScrubber> createState() => _PlaybackScrubberState();
}

class _PlaybackScrubberState extends State<PlaybackScrubber> {
  /// The thumb position while dragging, in milliseconds.
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final double totalMs =
        (widget.duration?.inMilliseconds ?? 0).toDouble().clamp(0, 1e12);
    final double positionMs =
        (_dragMs ?? widget.position.inMilliseconds.toDouble())
            .clamp(0, totalMs > 0 ? totalMs : 0);
    final bool canSeek = widget.onSeek != null && totalMs > 0;
    final TextStyle timeStyle = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFeatures: _tabular,
        color: recordingBarMuted(c));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              padding: EdgeInsets.zero,
              activeTrackColor: c.onRecordingBar,
              inactiveTrackColor: c.onRecordingBar.withValues(alpha: 0.22),
              disabledActiveTrackColor: c.onRecordingBar,
              disabledInactiveTrackColor:
                  c.onRecordingBar.withValues(alpha: 0.22),
              thumbColor: c.onRecordingBar,
              disabledThumbColor: c.onRecordingBar,
              overlayColor: c.onRecordingBar.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6, disabledThumbRadius: 0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: positionMs,
              max: totalMs > 0 ? totalMs : 1,
              onChanged:
                  canSeek ? (value) => setState(() => _dragMs = value) : null,
              onChangeEnd: canSeek
                  ? (value) {
                      setState(() => _dragMs = null);
                      widget.onSeek!(Duration(milliseconds: value.round()));
                    }
                  : null,
            ),
          ),
        ),
        Row(
          children: [
            Text(formatClock(Duration(milliseconds: positionMs.round())),
                style: timeStyle),
            const Spacer(),
            Text(
                widget.duration == null
                    ? '--:--'
                    : formatClock(widget.duration!),
                style: timeStyle),
          ],
        ),
      ],
    );
  }
}

/// A spinner/progress line with a label, shown on the recording bar while
/// a model downloads or a transcript is made.
class RecordingBarProgress extends StatelessWidget {
  final String label;

  /// 0–1, or null for indeterminate.
  final double? value;

  const RecordingBarProgress({Key? key, required this.label, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFeatures: _tabular,
                color: recordingBarMuted(c))),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 3,
            color: recordingBarAccent(c),
            backgroundColor: c.onRecordingBar.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}

/// A flat, muted formatting button for the compact notes toolbar; tinted
/// with the accent while its style is on.
class NotesToolbarButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  const NotesToolbarButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: selected,
      icon: icon,
      iconSize: 20,
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: c.muted,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control)),
      ).copyWith(
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? c.accent : c.muted),
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? c.accentTint
                : Colors.transparent),
      ),
    );
  }
}

/// The empty state of the transcript tab.
class TranscriptEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;

  const TranscriptEmptyState({
    Key? key,
    required this.title,
    required this.message,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subject_rounded, size: 28, color: c.muted),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: AppText.bodyStrong.copyWith(color: c.ink)),
            const SizedBox(height: 4),
            Text(message,
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(color: c.muted, height: 1.4)),
            if (action != null) ...[
              const SizedBox(height: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
