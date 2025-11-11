import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/orientation_service.dart';

class CompassIndicator extends StatelessWidget {
  final CameraOrientation orientation;
  final bool showDegrees;
  final double size;

  const CompassIndicator({
    super.key,
    required this.orientation,
    this.showDegrees = true,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    final bearing = orientation.bearing;
    final cardinal = orientation.cardinalDirection;
    final angleRad =
        (bearing - 90) * 3.1415926535 / 180; // Rotar para que 0° apunte arriba

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo circular
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.blueGrey.withOpacity(0.6),
                width: 1,
              ),
            ),
          ),
          // Marcas cardinales
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: CustomPaint(painter: _CompassPainter(bearing: bearing)),
            ),
          ),
          // Aguja
          Transform.rotate(
            angle: angleRad,
            child: Container(
              width: size * 0.7,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Centro
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 6),
              ],
            ),
          ),
          // Texto
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cardinal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showDegrees)
                Text(
                  '${bearing.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double bearing;
  _CompassPainter({required this.bearing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint =
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;

    // Dibujar anillo
    canvas.drawCircle(center, radius - 2, paint);

    final textPainter = (String text, double angle, {bool bold = false}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: text == 'N' ? Colors.redAccent : Colors.white54,
            fontSize: 9,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = center.dx + (radius - 12) * cosDeg(angle) - tp.width / 2;
      final y = center.dy + (radius - 12) * sinDeg(angle) - tp.height / 2;
      tp.paint(canvas, Offset(x, y));
    };

    // Cardinales principales
    textPainter('N', 0, bold: true);
    textPainter('E', 90);
    textPainter('S', 180);
    textPainter('W', 270);

    // Intermedios
    textPainter('NE', 45);
    textPainter('SE', 135);
    textPainter('SW', 225);
    textPainter('NW', 315);
  }

  double cosDeg(double deg) => MathHelper.cosDeg(deg);
  double sinDeg(double deg) => MathHelper.sinDeg(deg);

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.bearing != bearing;
}

class MathHelper {
  static double cosDeg(double deg) => math.cos(_toRadians(deg));
  static double sinDeg(double deg) => math.sin(_toRadians(deg));
  static double _toRadians(double deg) => deg * 3.1415926535 / 180;
}
