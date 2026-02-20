import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../painters/corner_brackets_painter.dart';

/// Primary CTA button with retro pixel-art styling and hover effects.
/// By default stretches to fill available width (capped at 400px).
/// Set [width] to override with a fixed width.
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 60.0,
    this.borderColor,
    this.textColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _glowBlur {
    if (_isPressed) return 50.0; // Increased from 35 for stronger press effect
    if (_isHovered) return 25.0;
    return 15.0;
  }

  double get _scale {
    if (_isPressed) return 0.95; // Scale down on press
    return 1.0;
  }

  void _setHovered(bool value) {
    if (mounted && _isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  void _setPressed(bool value) {
    if (mounted && _isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppTheme.cyanAccent;
    final textColor = widget.textColor ?? AppTheme.cyanAccent;
    final isEnabled = widget.onPressed != null;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.width ?? 400,
        ),
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: isEnabled ? widget.onPressed : null,
            child: AnimatedScale(
              scale: _scale,
              duration: Duration(milliseconds: _isPressed ? 100 : 200),
              curve: _isPressed ? Curves.easeOut : Curves.easeOutBack,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final effectiveWidth = widget.width ?? constraints.maxWidth;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: effectiveWidth,
                    height: widget.height,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isEnabled ? borderColor : AppTheme.textDisabled,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                color: borderColor.withValues(alpha: 0.4),
                                blurRadius: _glowBlur,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Corner brackets
                        if (isEnabled)
                          CustomPaint(
                            painter: CornerBracketsPainter(
                              color: borderColor,
                              pixelSize: 6,
                            ),
                            size: Size(effectiveWidth, widget.height!),
                          ),
                        // Button text
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                widget.text.toUpperCase(),
                                style: GoogleFonts.tiny5(
                                  fontSize: 20,
                                  color: isEnabled ? textColor : AppTheme.textDisabled,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
