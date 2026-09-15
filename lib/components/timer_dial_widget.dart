import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/pelvix_theme.dart';

class TimerDialWidget extends StatelessWidget {
  final int remainingSeconds;
  final int targetSeconds;
  final bool isRunning;
  final bool isCompleted;

  const TimerDialWidget({
    super.key,
    required this.remainingSeconds,
    required this.targetSeconds,
    required this.isRunning,
    required this.isCompleted,
  });

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final progress = targetSeconds > 0
        ? ((targetSeconds - remainingSeconds) / targetSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Center(
      child: SizedBox(
        width: 270,
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dial Canvas
            CustomPaint(
              size: const Size(270, 270),
              painter: _TimerDialPainter(
                progress: progress,
                isRunning: isRunning,
                isCompleted: isCompleted,
              ),
            ),
            // Center Metrics
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCompleted ? 'COMPLETE' : (isRunning ? 'HOLDING' : 'READY'),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? PelvixTheme.neonGreen
                        : (isRunning ? PelvixTheme.neonLime : PelvixTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    color: PelvixTheme.textLight,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: PelvixTheme.cardNavyElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PelvixTheme.borderNavy),
                  ),
                  child: Text(
                    'Target: ${_formatTime(targetSeconds)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PelvixTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerDialPainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  final bool isCompleted;

  _TimerDialPainter({
    required this.progress,
    required this.isRunning,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;

    // Outer faint tick ring
    final tickPaint = Paint()
      ..color = PelvixTheme.borderNavy.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * math.pi / 180;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 8.0 : 4.0;
      final outerP = Offset(
        center.dx + (radius + 8) * math.cos(angle),
        center.dy + (radius + 8) * math.sin(angle),
      );
      final innerP = Offset(
        center.dx + (radius + 8 - tickLength) * math.cos(angle),
        center.dy + (radius + 8 - tickLength) * math.sin(angle),
      );
      canvas.drawLine(outerP, innerP, tickPaint);
    }

    // Background track
    final trackPaint = Paint()
      ..color = PelvixTheme.cardNavyElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      final activeColor = isCompleted
          ? PelvixTheme.neonGreen
          : (isRunning ? PelvixTheme.neonLime : PelvixTheme.accentCyan);

      final progressPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      // Glow shader
      if (isRunning || isCompleted) {
        final glowPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          sweepAngle,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isCompleted != isCompleted;
  }
}
