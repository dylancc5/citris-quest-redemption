import 'package:flutter/material.dart';

/// Custom painter for pixelated corner brackets
/// Used to decorate buttons with retro-style L-shaped corners
///
/// Spec reference: lines 356-366
class CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  const CornerBracketsPainter({required this.color, this.pixelSize = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw all four corner brackets
    _drawTopLeftBracket(canvas, paint, size);
    _drawTopRightBracket(canvas, paint, size);
    _drawBottomLeftBracket(canvas, paint, size);
    _drawBottomRightBracket(canvas, paint, size);
  }

  /// Draws top-left L-shaped bracket
  /// Pattern (smaller, 2x2 pixels):
  /// ████
  /// ██░░
  void _drawTopLeftBracket(Canvas canvas, Paint paint, Size size) {
    // Horizontal bar (top)
    canvas.drawRect(Rect.fromLTWH(0, 0, pixelSize * 2, pixelSize), paint);

    // Vertical bar (left)
    canvas.drawRect(Rect.fromLTWH(0, 0, pixelSize, pixelSize * 2), paint);
  }

  /// Draws top-right L-shaped bracket (mirrored)
  void _drawTopRightBracket(Canvas canvas, Paint paint, Size size) {
    final right = size.width;

    // Horizontal bar (top)
    canvas.drawRect(
      Rect.fromLTWH(right - pixelSize * 2, 0, pixelSize * 2, pixelSize),
      paint,
    );

    // Vertical bar (right)
    canvas.drawRect(
      Rect.fromLTWH(right - pixelSize, 0, pixelSize, pixelSize * 2),
      paint,
    );
  }

  /// Draws bottom-left L-shaped bracket (flipped)
  void _drawBottomLeftBracket(Canvas canvas, Paint paint, Size size) {
    final bottom = size.height;

    // Horizontal bar (bottom)
    canvas.drawRect(
      Rect.fromLTWH(0, bottom - pixelSize, pixelSize * 2, pixelSize),
      paint,
    );

    // Vertical bar (left)
    canvas.drawRect(
      Rect.fromLTWH(0, bottom - pixelSize * 2, pixelSize, pixelSize * 2),
      paint,
    );
  }

  /// Draws bottom-right L-shaped bracket (mirrored & flipped)
  void _drawBottomRightBracket(Canvas canvas, Paint paint, Size size) {
    final right = size.width;
    final bottom = size.height;

    // Horizontal bar (bottom)
    canvas.drawRect(
      Rect.fromLTWH(
        right - pixelSize * 2,
        bottom - pixelSize,
        pixelSize * 2,
        pixelSize,
      ),
      paint,
    );

    // Vertical bar (right)
    canvas.drawRect(
      Rect.fromLTWH(
        right - pixelSize,
        bottom - pixelSize * 2,
        pixelSize,
        pixelSize * 2,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CornerBracketsPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pixelSize != pixelSize;
  }
}
