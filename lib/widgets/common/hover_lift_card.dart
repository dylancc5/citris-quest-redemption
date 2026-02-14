import 'package:flutter/material.dart';

/// Wrapper widget that adds a lift effect on hover (desktop only)
/// Card translates up slightly and glow increases on mouse hover
class HoverLiftCard extends StatefulWidget {
  final Widget child;
  final double liftDistance;
  final Duration duration;

  const HoverLiftCard({
    super.key,
    required this.child,
    this.liftDistance = 8.0,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<HoverLiftCard> {
  bool _isHovered = false;

  void _setHovered(bool value) {
    if (mounted && _isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: _isHovered ? Curves.easeOut : Curves.easeInOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -widget.liftDistance : 0,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}
