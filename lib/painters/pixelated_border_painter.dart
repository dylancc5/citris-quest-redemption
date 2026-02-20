import 'package:flutter/material.dart';

/// Custom painter for pixelated/stepped card borders
/// Creates retro-style stepped edges instead of smooth curves
class PixelatedBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double pixelSize;
  final bool showCornerDecorations;

  const PixelatedBorderPainter({
    required this.borderColor,
    required this.glowColor,
    this.borderWidth = 2.0,
    this.pixelSize = 4.0,
    this.showCornerDecorations = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw outer glow border (soft blur)
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    // Draw pixelated border by snapping to pixel grid
    final snappedWidth = (size.width / pixelSize).floor() * pixelSize;
    final snappedHeight = (size.height / pixelSize).floor() * pixelSize;

    // Draw outer glow first
    _drawPixelatedRect(
      canvas,
      glowPaint,
      Rect.fromLTWH(0, 0, snappedWidth, snappedHeight),
    );

    // Draw inner border
    paint.color = borderColor;
    _drawPixelatedRect(
      canvas,
      paint,
      Rect.fromLTWH(0, 0, snappedWidth, snappedHeight),
    );

    // Draw corner decorations (pixel "bolts")
    if (showCornerDecorations) {
      _drawCornerDecorations(canvas, size);
    }
  }

  /// Draws a pixelated rectangle by drawing individual pixel segments
  void _drawPixelatedRect(Canvas canvas, Paint paint, Rect rect) {
    final halfPixel = pixelSize / 2;

    // Top edge
    for (double x = 0; x < rect.width; x += pixelSize) {
      final endX = (x + pixelSize).clamp(0.0, rect.width);
      canvas.drawLine(
        Offset(x + halfPixel, 0),
        Offset(endX - halfPixel, 0),
        paint,
      );
    }

    // Right edge
    for (double y = 0; y < rect.height; y += pixelSize) {
      final endY = (y + pixelSize).clamp(0.0, rect.height);
      canvas.drawLine(
        Offset(rect.width, y + halfPixel),
        Offset(rect.width, endY - halfPixel),
        paint,
      );
    }

    // Bottom edge
    for (double x = 0; x < rect.width; x += pixelSize) {
      final endX = (x + pixelSize).clamp(0.0, rect.width);
      canvas.drawLine(
        Offset(x + halfPixel, rect.height),
        Offset(endX - halfPixel, rect.height),
        paint,
      );
    }

    // Left edge
    for (double y = 0; y < rect.height; y += pixelSize) {
      final endY = (y + pixelSize).clamp(0.0, rect.height);
      canvas.drawLine(
        Offset(0, y + halfPixel),
        Offset(0, endY - halfPixel),
        paint,
      );
    }
  }

  /// Draws small pixel "bolts" at corners for decoration
  void _drawCornerDecorations(Canvas canvas, Size size) {
    final decorationPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final boltSize = pixelSize * 1.5;

    // Top-left corner bolt
    canvas.drawRect(Rect.fromLTWH(0, 0, boltSize, pixelSize), decorationPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, pixelSize, boltSize), decorationPaint);

    // Top-right corner bolt
    canvas.drawRect(
      Rect.fromLTWH(size.width - boltSize, 0, boltSize, pixelSize),
      decorationPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - pixelSize, 0, pixelSize, boltSize),
      decorationPaint,
    );

    // Bottom-left corner bolt
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - pixelSize, boltSize, pixelSize),
      decorationPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - boltSize, pixelSize, boltSize),
      decorationPaint,
    );

    // Bottom-right corner bolt
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - boltSize,
        size.height - pixelSize,
        boltSize,
        pixelSize,
      ),
      decorationPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - pixelSize,
        size.height - boltSize,
        pixelSize,
        boltSize,
      ),
      decorationPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PixelatedBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.pixelSize != pixelSize ||
        oldDelegate.showCornerDecorations != showCornerDecorations;
  }
}
