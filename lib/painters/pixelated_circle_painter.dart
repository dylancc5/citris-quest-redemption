import 'package:flutter/material.dart';

class PixelatedCirclePainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  PixelatedCirclePainter({required this.color, this.pixelSize = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create pixelated circle effect
    for (double x = 0; x < size.width; x += pixelSize) {
      for (double y = 0; y < size.height; y += pixelSize) {
        final pixelCenter = Offset(x + pixelSize / 2, y + pixelSize / 2);
        final distance = (pixelCenter - center).distance;

        if (distance <= radius && distance >= radius - pixelSize * 3) {
          canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
