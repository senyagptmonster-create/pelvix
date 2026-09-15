import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/pelvix_theme.dart';

class PlankPosturePainter extends CustomPainter {
  final double progress;
  final bool isActive;

  PlankPosturePainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.44;

    // Background track
    final trackPaint = Paint()
      ..color = PelvixTheme.edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: const [PelvixTheme.accent, PelvixTheme.accentLight],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Biomechanical figure in plank inside circle
    final figurePaint = Paint()
      ..color = isActive ? PelvixTheme.accentLight : PelvixTheme.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final groundY = center.dy + 38;
    // Ground line
    canvas.drawLine(
      Offset(center.dx - 65, groundY),
      Offset(center.dx + 65, groundY),
      Paint()..color = PelvixTheme.edge..strokeWidth = 2,
    );

    // Head (circle)
    final headOffset = Offset(center.dx + 44, center.dy - 6);
    canvas.drawCircle(headOffset, 6, figurePaint);

    // Torso / spine straight line
    final shoulderOffset = Offset(center.dx + 36, center.dy + 4);
    final hipsOffset = Offset(center.dx - 14, center.dy + 4);
    final feetOffset = Offset(center.dx - 54, groundY - 2);

    canvas.drawLine(shoulderOffset, hipsOffset, figurePaint);
    canvas.drawLine(hipsOffset, feetOffset, figurePaint);

    // Arms down to ground
    final elbowOffset = Offset(center.dx + 36, groundY - 2);
    canvas.drawLine(shoulderOffset, elbowOffset, figurePaint);
    canvas.drawLine(elbowOffset, Offset(center.dx + 48, groundY - 2), figurePaint);

    // Glowing core tension beacon at hips
    if (isActive) {
      final glowPaint = Paint()
        ..color = PelvixTheme.accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hipsOffset, 12, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PlankPosturePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
