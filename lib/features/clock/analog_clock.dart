import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnalogClock extends StatelessWidget {
  const AnalogClock({
    required this.time,
    super.key,
  });

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _AnalogClockPainter(time),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  const _AnalogClockPainter(this.time);

  final DateTime time;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2;
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius - 4,
      stroke..strokeWidth = 4,
    );

    for (int i = 0; i < 60; i += 1) {
      final bool isHour = i % 5 == 0;
      final double angle = (i * 6 - 90) * math.pi / 180;
      final double outer = radius - 14;
      final double inner = radius - (isHour ? 34 : 24);
      final Offset p1 = center + Offset(math.cos(angle), math.sin(angle)) * outer;
      final Offset p2 = center + Offset(math.cos(angle), math.sin(angle)) * inner;
      canvas.drawLine(
        p1,
        p2,
        stroke
          ..strokeWidth = isHour ? 4 : 2,
      );
    }

    final double minuteAngle = (time.minute * 6 - 90) * math.pi / 180;
    final double hourAngle =
        (((time.hour % 12) + time.minute / 60) * 30 - 90) * math.pi / 180;

    canvas.drawLine(
      center,
      center + Offset(math.cos(hourAngle), math.sin(hourAngle)) * (radius * 0.48),
      stroke..strokeWidth = 10,
    );
    canvas.drawLine(
      center,
      center + Offset(math.cos(minuteAngle), math.sin(minuteAngle)) * (radius * 0.72),
      stroke..strokeWidth = 6,
    );

    canvas.drawCircle(center, 8, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.time.hour != time.hour || oldDelegate.time.minute != time.minute;
  }
}
