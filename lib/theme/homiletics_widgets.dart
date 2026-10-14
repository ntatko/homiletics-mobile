import 'package:flutter/material.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// Corner radius of a collapsed homiletic step row.
const double _tileRadius = 14;

/// Corner radius of the expanded step card.
const double _cardRadius = 16;

/// Corner radius of the tinted rows and fields inside a step.
const double _rowRadius = 10;

/// Width of the verse-range column in a step row ("1–7", "12–14").
const double _verseColumnWidth = 40;

/// Text style of what the user types in a step.
const TextStyle _inputStyle =
    TextStyle(fontFamily: AppFonts.sans, fontSize: 15, height: 1.4);

/// Text style of the verse range in a step row.
const TextStyle _verseStyle = TextStyle(
    fontFamily: AppFonts.serif, fontSize: 14, fontWeight: FontWeight.w600);

/// Shows the explanation of a homiletic step in a dialog.
Future<void> showStepHelp(BuildContext context, String title, String text) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

/// A borderless decoration for text typed on a step's tinted background:
/// the tinted box around the field is what shows it can be edited.
InputDecoration stepInputDecoration(BuildContext context, String hint,
    {TextStyle? hintStyle}) {
  final AppColors c = AppColors.of(context);
  return InputDecoration(
    isDense: true,
    filled: false,
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    hintText: hint,
    hintStyle: hintStyle ?? _inputStyle.copyWith(color: c.muted),
  );
}

/// A collapsed homiletic step: its badge (a check when [done], else the
/// number), title and a short muted [summary] on the right. Tap to expand.
///
/// [compact] drops the summary, for two tiles sharing a row.
class CollapsedStepTile extends StatelessWidget {
  final StudyStep step;
  final String title;
  final String summary;
  final bool done;
  final bool compact;
  final VoidCallback onTap;

  const CollapsedStepTile({
    Key? key,
    required this.step,
    required this.title,
    required this.summary,
    required this.done,
    required this.onTap,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Text titleText = Text(title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.serif,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: c.ink));
    return Semantics(
      button: true,
      expanded: false,
      label: '$title, ${done ? 'done' : 'to do'}${compact ? '' : ', $summary'}',
      excludeSemantics: true,
      child: AppCard(
        radius: _tileRadius,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(children: [
              StepBadge(
                  step: step, state: done ? StudyStepState.done : StudyStepState.pending),
              SizedBox(width: compact ? 10 : 12),
              Expanded(child: titleText),
              if (!compact) ...[
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: constraints.maxWidth * 0.45),
                  child: Text(summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppText.caption.copyWith(color: c.muted)),
                ),
              ],
            ]);
          }),
        ),
      ),
    );
  }
}

/// The open homiletic step: a card outlined in the step's color with the
/// active badge, the title (tap to collapse), a "?" help button and the
/// step's editor ([child]).
class ExpandedStepCard extends StatelessWidget {
  final StudyStep step;
  final String title;
  final String helpTitle;
  final String helpText;
  final VoidCallback onCollapse;
  final Widget child;

  const ExpandedStepCard({
    Key? key,
    required this.step,
    required this.title,
    required this.helpTitle,
    required this.helpText,
    required this.onCollapse,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return AppCard(
      radius: _cardRadius,
      highlight: c.step(step),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Semantics(
                button: true,
                expanded: true,
                label: '$title, collapse',
                excludeSemantics: true,
                child: InkWell(
                  onTap: onCollapse,
                  borderRadius: BorderRadius.circular(_rowRadius),
                  child: SizedBox(
                    height: 44,
                    child: Row(children: [
                      StepBadge(step: step, state: StudyStepState.active),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppFonts.serif,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: c.ink)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            _StepHelpButton(step: step, title: helpTitle, text: helpText),
          ]),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// The small tinted "?" circle that opens a step's explanation. Draws a
/// 32px circle inside a 44px tap target.
class _StepHelpButton extends StatelessWidget {
  final StudyStep step;
  final String title;
  final String text;

  const _StepHelpButton(
      {Key? key, required this.step, required this.title, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Tooltip(
      message: 'About $title',
      child: Semantics(
        button: true,
        label: 'About $title',
        excludeSemantics: true,
        child: InkResponse(
          onTap: () => showStepHelp(context, title, text),
          radius: 22,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: c.stepTint(step), shape: BoxShape.circle),
                child: Text('?',
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.step(step))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded box on the step's tint that holds one row or field of a
/// step, outlined in the step color while anything in it has focus.
class StepTintBox extends StatefulWidget {
  final StudyStep step;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const StepTintBox({
    Key? key,
    required this.step,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : super(key: key);

  @override
  State<StepTintBox> createState() => _StepTintBoxState();
}

class _StepTintBoxState extends State<StepTintBox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        if (focused != _focused) setState(() => _focused = focused);
      },
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: c.stepTint(widget.step),
          borderRadius: BorderRadius.circular(_rowRadius),
          border: Border.all(
              color: _focused ? c.step(widget.step) : Colors.transparent,
              width: 1.5),
        ),
        child: widget.child,
      ),
    );
  }
}

/// One row of a list step: an optional verse range (serif, in the step
/// color), the row's text, and an × that removes the row.
class StepListRow extends StatelessWidget {
  final StudyStep step;

  /// The verse-range field; omitted for rows without verses.
  final TextEditingController? versesController;
  final ValueChanged<String>? onVersesChanged;

  final TextEditingController textController;
  final String textHint;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType textKeyboardType;

  /// Focuses the first field when the row is first built (a row the user
  /// just added).
  final bool autofocus;

  final VoidCallback onRemove;
  final String removeTooltip;

  const StepListRow({
    Key? key,
    required this.step,
    required this.textController,
    required this.textHint,
    required this.onTextChanged,
    required this.onRemove,
    required this.removeTooltip,
    this.versesController,
    this.onVersesChanged,
    this.onSubmitted,
    this.textKeyboardType = TextInputType.text,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color color = c.step(step);
    return StepTintBox(
      step: step,
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (versesController != null) ...[
            SizedBox(
              width: _verseColumnWidth,
              child: Semantics(
                label: 'Verses',
                child: TextField(
                  autofocus: autofocus,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller: versesController,
                  style: _verseStyle.copyWith(color: color, height: 1.5),
                  cursorColor: color,
                  decoration: stepInputDecoration(context, 'v.',
                      hintStyle: _verseStyle.copyWith(
                          color: color.withValues(alpha: 0.55), height: 1.5)),
                  onChanged: onVersesChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              autofocus: autofocus && versesController == null,
              maxLines: null,
              keyboardType: textKeyboardType,
              textCapitalization: TextCapitalization.sentences,
              controller: textController,
              style: _inputStyle.copyWith(color: c.ink),
              cursorColor: color,
              decoration: stepInputDecoration(context, textHint),
              onSubmitted: onSubmitted,
              onChanged: onTextChanged,
            ),
          ),
          IconButton(
            tooltip: removeTooltip,
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 16),
            color: c.muted,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

/// The single multiline field of a one-answer step (summary, FCF, aim).
class StepTextField extends StatelessWidget {
  final StudyStep step;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const StepTextField({
    Key? key,
    required this.step,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return StepTintBox(
      step: step,
      child: TextField(
        minLines: 2,
        maxLines: null,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        style: _inputStyle.copyWith(color: c.ink),
        cursorColor: c.step(step),
        decoration: stepInputDecoration(context, hint),
        onChanged: onChanged,
      ),
    );
  }
}

/// The dashed "+ Add …" button under a list step's rows.
class DashedAddButton extends StatelessWidget {
  final StudyStep step;
  final String label;
  final VoidCallback onPressed;

  const DashedAddButton({
    Key? key,
    required this.step,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color color = c.step(step);
    final BorderRadius br = BorderRadius.circular(_rowRadius);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: CustomPaint(
        painter: _DashedRRectPainter(
            color: color.withValues(alpha: 0.6), radius: _rowRadius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: br,
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text('+ $label',
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const double dash = 5;
    const double gap = 4;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Path outline = Path()
      ..addRRect(RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5), Radius.circular(radius)));
    for (final metric in outline.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
