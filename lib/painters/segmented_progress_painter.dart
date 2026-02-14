import 'package:flutter/material.dart';

/// Custom painter for pixel-style segmented progress bar
/// Draws rectangular segments that fill left-to-right based on progress
class SegmentedProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color filledColor;
  final Color emptyColor;
  final int segmentCount;

  SegmentedProgressPainter({
    required this.progress,
    required this.filledColor,
    required this.emptyColor,
    required this.segmentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final segmentWidth = size.width / segmentCount;
    final filledSegments = (progress * segmentCount).floor();

    for (int i = 0; i < segmentCount; i++) {
      final isFilled = i < filledSegments;
      final paint = Paint()
        ..color = isFilled ? filledColor : emptyColor
        ..style = PaintingStyle.fill;

      // Draw segment with 1px gap between segments
      final left = i * segmentWidth + 1;
      final right = (i + 1) * segmentWidth - 1;
      final rect = Rect.fromLTRB(left, 0, right, size.height);

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(SegmentedProgressPainter oldDelegate) {
    final oldFilledSegments = (oldDelegate.progress * segmentCount).floor();
    final newFilledSegments = (progress * segmentCount).floor();
    return oldFilledSegments != newFilledSegments;
  }
}
