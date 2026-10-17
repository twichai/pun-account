import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Clean, scalable vector Google "G" logo rendered via CustomPainter.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = math.min(w, h) / 2;
    final double strokeWidth = radius * 0.42;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final Paint paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw Google 4 arc segments (angles in radians)
    // Red: Top arc (approx 190° to 310°)
    canvas.drawArc(rect, -math.pi * 0.95, math.pi * 0.65, false, paintRed);

    // Blue: Right bottom to middle arc
    canvas.drawArc(rect, -math.pi * 0.30, math.pi * 0.55, false, paintBlue);

    // Green: Bottom arc
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.45, false, paintGreen);

    // Yellow: Left bottom arc
    canvas.drawArc(rect, math.pi * 0.70, math.pi * 0.35, false, paintYellow);

    // Center Blue horizontal bar
    final Paint paintBar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      center.dx - strokeWidth * 0.15,
      center.dy - strokeWidth / 2,
      radius + strokeWidth * 0.15,
      strokeWidth,
    );
    canvas.drawRect(barRect, paintBar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
