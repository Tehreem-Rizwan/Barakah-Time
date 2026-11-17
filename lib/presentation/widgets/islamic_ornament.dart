import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Repeating eight-pointed-star (khatam) pattern, as in mosque tilework.
/// Drawn with thin brass lines at low opacity so it stays decorative.
class IslamicPatternPainter extends CustomPainter {
  const IslamicPatternPainter({
    this.color = AppColors.brass,
    this.opacity = 0.22,
    this.cell = 44,
  });

  final Color color;
  final double opacity;

  /// Size of one tile in logical pixels.
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final star = _star(cell);
    for (var y = 0.0; y < size.height + cell; y += cell) {
      for (var x = 0.0; x < size.width + cell; x += cell) {
        // Offset every other row for a woven look.
        final dx = ((y / cell).round().isOdd) ? cell / 2 : 0.0;
        canvas.save();
        canvas.translate(x + dx, y);
        canvas.drawPath(star, paint);
        canvas.drawCircle(Offset(cell / 2, cell / 2), cell * 0.11, paint);
        canvas.restore();
      }
    }
  }

  /// Eight-pointed star made of two overlapping squares, centred in a cell.
  static Path _star(double cell) {
    final c = cell / 2;
    final r = cell * 0.4;
    final path = Path();
    for (final start in [0.0, math.pi / 4]) {
      for (var i = 0; i < 4; i++) {
        final a = start + i * math.pi / 2;
        final p = Offset(c + r * math.cos(a), c + r * math.sin(a));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(IslamicPatternPainter old) =>
      old.color != color || old.opacity != opacity || old.cell != cell;
}

/// Turquoise band with the star pattern, used behind the top of Home.
class IslamicHeaderBand extends StatelessWidget {
  const IslamicHeaderBand({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.emeraldDeep, AppColors.primaryEmerald],
            ),
          ),
          child: const ClipRect(
            child: CustomPaint(painter: IslamicPatternPainter()),
          ),
        ),
      ),
    );
  }
}

/// Mihrab (arch) outline: a tall rounded top, gently rounded bottom.
/// [archHeight] is how far the curve reaches down from the top.
BorderRadius archRadius({
  required double width,
  required double archHeight,
  double bottom = 18,
}) => BorderRadius.vertical(
  top: Radius.elliptical(width / 2, archHeight),
  bottom: Radius.circular(bottom),
);
