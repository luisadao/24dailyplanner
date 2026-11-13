import 'dart:math';
import 'package:flutter/material.dart';
import '../models/time_event.dart';
import '../theme/app_colors.dart';

class RadialClockPainter extends CustomPainter {
  final List<TimeEvent> events;
  final TimeOfDay currentTime;
  final bool showCurrentTime;
  final String centerTitle;
  final String centerSubtitle;

  RadialClockPainter({
    required this.events,
    required this.currentTime,
    required this.showCurrentTime,
    required this.centerTitle,
    required this.centerSubtitle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    final paint = Paint()..style = PaintingStyle.stroke;

    // Background ring track
    paint.color = AppColors.track;
    paint.strokeWidth = 24.0;
    paint.strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);

    // Inner hour tick marks
    final tickPaint = Paint()
      ..color = AppColors.secondaryText.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    for (int hour = 0; hour < 24; hour++) {
      final angle = _minuteToRadians(hour * 60);
      final innerRadius = radius - 14;
      final outerRadius = radius - 4;
      canvas.drawLine(
        Offset(center.dx + innerRadius * cos(angle), center.dy + innerRadius * sin(angle)),
        Offset(center.dx + outerRadius * cos(angle), center.dy + outerRadius * sin(angle)),
        tickPaint,
      );
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Event arcs + labels
    for (final event in events) {
      final startAngle = _minuteToRadians(event.startMinute);
      final sweepAngle = _minuteToRadians(event.durationMinutes);
      final color = Color(event.colorValue);

      paint.color = color;
      paint.strokeWidth = 24.0;
      paint.strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Outer callout label
      final midAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius + 32;
      final labelOffset = Offset(
        center.dx + labelRadius * cos(midAngle),
        center.dy + labelRadius * sin(midAngle),
      );
      final labelText = event.recurrenceType != RecurrenceType.none
          ? '${event.title} ↺'
          : event.title;
      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      // Icon inside arc
      if (event.iconCodePoint != null) {
        final iconOffset = Offset(
          center.dx + radius * 0.85 * cos(midAngle),
          center.dy + radius * 0.85 * sin(midAngle),
        );
        textPainter.text = TextSpan(
          text: String.fromCharCode(event.iconCodePoint!),
          style: TextStyle(
            fontFamily: 'MaterialIcons',
            fontSize: 14,
            color: _contrastColor(color),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          iconOffset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    // Hour markers (00h, 06h, 12h, 18h)
    const markerHours = [0, 6, 12, 18];
    for (final hour in markerHours) {
      final markerAngle = _minuteToRadians(hour * 60);
      final markerOffset = Offset(
        center.dx + (radius + 14) * cos(markerAngle),
        center.dy + (radius + 14) * sin(markerAngle),
      );
      textPainter.text = TextSpan(
        text: '${hour.toString().padLeft(2, '0')}h',
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        markerOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Current time needle
    if (showCurrentTime) {
      final currentMinute = currentTime.hour * 60 + currentTime.minute;
      final angle = _minuteToRadians(currentMinute);
      final indicatorEnd = Offset(
        center.dx + (radius + 8) * cos(angle),
        center.dy + (radius + 8) * sin(angle),
      );
      final indicatorPaint = Paint()
        ..color = AppColors.coralRed
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, indicatorEnd, indicatorPaint);

      final dotPaint = Paint()
        ..color = AppColors.coralRed
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 4.0, dotPaint);
    }

    // Center hub readout
    textPainter.text = TextSpan(
      text: centerTitle,
      style: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - 24));

    textPainter.text = TextSpan(
      text: centerSubtitle,
      style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy + 8));
  }

  double _minuteToRadians(int minute) =>
      (minute / 1440) * (2 * pi) - pi / 2;

  Color _contrastColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
