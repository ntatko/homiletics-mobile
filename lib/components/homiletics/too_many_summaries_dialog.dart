import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';

/// The most content summaries a homiletic is meant to have.
const int maxContentSummaries = 20;

/// Asks before adding content summary number [count] (past
/// [maxContentSummaries]), with a hen clucking about it. Returns whether to
/// add it anyway.
Future<bool> confirmExtraContentSummary(BuildContext context, int count) async {
  final bool? addAnyway = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations l = context.l10n;
      final AppColors c = AppColors.of(context);
      return AlertDialog(
        icon: const _CluckingHen(size: 96),
        title: Text(l.homileticTooManySummariesTitle(count),
            textAlign: TextAlign.center),
        content: Text(l.homileticTooManySummariesMessage,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: c.muted)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.homileticTooManySummariesAddAnyway),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.homileticTooManySummariesCombine),
          ),
        ],
      );
    },
  );
  return addAnyway ?? false;
}

/// A round hen that bobs her head a few times when she appears (still when
/// the system asks for reduced motion). Decorative.
class _CluckingHen extends StatefulWidget {
  final double size;

  const _CluckingHen({required this.size});

  @override
  State<_CluckingHen> createState() => _CluckingHenState();
}

class _CluckingHenState extends State<_CluckingHen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bob.value = 0;
    } else if (!_bob.isAnimating && _bob.value == 0) {
      _bob.forward();
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _bob,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _HenPainter(
            // Three quick pecks that settle.
            peck: math.sin(_bob.value * math.pi * 6) * (1 - _bob.value),
            body: c.surface,
            outline: c.ink,
            comb: c.danger,
            beak: const Color(0xFFF5A623),
            wing: c.surfaceSunken,
          ),
        ),
      ),
    );
  }
}

class _HenPainter extends CustomPainter {
  /// -1..1: how far the head is tipped forward (pecking).
  final double peck;
  final Color body;
  final Color outline;
  final Color comb;
  final Color beak;
  final Color wing;

  _HenPainter({
    required this.peck,
    required this.body,
    required this.outline,
    required this.comb,
    required this.beak,
    required this.wing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double u = size.width / 100;
    canvas.scale(u);
    final Paint stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    Paint fill(Color color) => Paint()..color = color;

    // Legs.
    for (final double x in [42.0, 56.0]) {
      canvas.drawLine(Offset(x, 80), Offset(x, 92), stroke);
      canvas.drawLine(Offset(x, 92), Offset(x - 4, 95), stroke);
      canvas.drawLine(Offset(x, 92), Offset(x + 4, 95), stroke);
    }

    // Tail feathers, then the round body over them.
    final Path tail = Path()
      ..moveTo(24, 58)
      ..quadraticBezierTo(10, 40, 18, 30)
      ..quadraticBezierTo(24, 42, 30, 44)
      ..quadraticBezierTo(24, 30, 32, 24)
      ..quadraticBezierTo(34, 40, 40, 46)
      ..close();
    canvas.drawPath(tail, fill(body));
    canvas.drawPath(tail, stroke);
    const Rect bodyRect = Rect.fromLTRB(22, 40, 78, 84);
    canvas.drawOval(bodyRect, fill(body));
    canvas.drawOval(bodyRect, stroke);

    // Wing.
    final Path wingPath = Path()
      ..moveTo(36, 58)
      ..quadraticBezierTo(48, 52, 58, 60)
      ..quadraticBezierTo(52, 74, 38, 70)
      ..quadraticBezierTo(32, 64, 36, 58)
      ..close();
    canvas.drawPath(wingPath, fill(wing));
    canvas.drawPath(wingPath, stroke);

    // The head tips forward around the neck as she pecks.
    canvas.save();
    canvas.translate(66, 46);
    canvas.rotate(peck * 0.35);
    canvas.translate(-66, -46);

    // Comb: three bumps.
    final Path combPath = Path()
      ..moveTo(60, 24)
      ..quadraticBezierTo(60, 15, 66, 17)
      ..quadraticBezierTo(70, 11, 74, 17)
      ..quadraticBezierTo(81, 16, 78, 25)
      ..close();
    canvas.drawPath(combPath, fill(comb));
    canvas.drawPath(combPath, stroke);

    final Rect head = Rect.fromCircle(center: const Offset(70, 36), radius: 13);
    canvas.drawOval(head, fill(body));
    canvas.drawOval(head, stroke);

    // Beak and wattle.
    final Path beakPath = Path()
      ..moveTo(81, 33)
      ..lineTo(91, 37)
      ..lineTo(81, 41)
      ..close();
    canvas.drawPath(beakPath, fill(beak));
    canvas.drawPath(beakPath, stroke..strokeWidth = 2);
    canvas.drawOval(const Rect.fromLTRB(76, 41, 82, 49), fill(comb));

    // Eye, with a glint.
    canvas.drawCircle(const Offset(73, 33), 2.4, fill(outline));
    canvas.drawCircle(const Offset(73.8, 32.2), 0.8, fill(body));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HenPainter old) =>
      old.peck != peck ||
      old.body != body ||
      old.outline != outline ||
      old.comb != comb ||
      old.wing != wing;
}
