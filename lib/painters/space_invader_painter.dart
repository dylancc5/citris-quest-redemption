import 'package:flutter/material.dart';

/// Custom painter for Space Invaders alien sprite
class SpaceInvaderPainter extends CustomPainter {
  final Color color;

  SpaceInvaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pixelWidth = size.width / 11; // Alien sprite width
    final pixelHeight = size.height / 8;  // Alien sprite height

    // Classic Space Invaders alien pattern (11x8 grid)
    // Using the middle alien design
    final pixels = [
      [0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0], // Row 0
      [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0], // Row 1
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // Row 2
      [0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0], // Row 3
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // Row 4
      [1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1], // Row 5
      [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1], // Row 6
      [0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0], // Row 7
    ];

    for (int row = 0; row < pixels.length; row++) {
      for (int col = 0; col < pixels[row].length; col++) {
        if (pixels[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * pixelWidth,
              row * pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
