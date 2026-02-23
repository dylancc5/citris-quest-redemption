import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget that renders a bundled SVG asset with dynamic color tinting.
///
/// Loads from `assets/icons/` by default. Falls back to a Material Icon
/// if the SVG fails to load (e.g. asset not found).
///
/// Usage:
/// ```dart
/// SvgIcon('space_invader', size: 33, color: AppTheme.cyanAccent)
/// ```
class SvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;
  final IconData? fallbackIcon;

  const SvgIcon(
    this.assetName, {
    super.key,
    this.size = 24,
    this.color,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color ?? Colors.white;
    final path = 'assets/icons/$assetName.svg';

    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      placeholderBuilder: (_) => Icon(
        fallbackIcon ?? Icons.image_not_supported_outlined,
        size: size,
        color: effectiveColor,
      ),
    );
  }
}
