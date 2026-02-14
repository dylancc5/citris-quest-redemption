import 'dart:math';
import 'package:flutter/material.dart';
import '../../painters/starfield_painter.dart';
import '../../core/theme.dart';

/// Full-page animated starfield background for landing page
/// Optimizes particle count based on screen size for performance
class AnimatedStarfield extends StatefulWidget {
  final Widget child;
  final double particleDensity; // 1.0 = full density (desktop), 0.5 = reduced (mobile)

  const AnimatedStarfield({
    super.key,
    required this.child,
    this.particleDensity = 1.0,
  });

  @override
  State<AnimatedStarfield> createState() => _AnimatedStarfieldState();
}

class _AnimatedStarfieldState extends State<AnimatedStarfield>
    with SingleTickerProviderStateMixin {
  late List<Star> _stars;
  late List<Galaxy> _galaxies;
  late List<Planet> _planets;
  late ValueNotifier<double> _timeNotifier;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier(0.0);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // Very long duration to avoid resets during session
    )..forward();

    _controller.addListener(() {
      // Continuously increment time without resetting
      // Animation runs for 24 hours (86400 seconds) before completing
      _timeNotifier.value = _controller.value * 86400;
    });

    // Initialize stars, galaxies, and planets
    _initializeObjects();
  }

  void _initializeObjects() {
    // Will be populated in didChangeDependencies when we have screen size
    _stars = [];
    _galaxies = [];
    _planets = [];
  }

  void _generateObjectsForScreenSize(Size screenSize) {
    final random = Random(42); // Fixed seed for consistent starfield
    final width = screenSize.width;
    final height = screenSize.height;

    // Calculate particle counts based on density
    // Base counts: 400 stars, 8 galaxies, 30 planets (total: 438)
    // Mobile (0.5 density): 200 stars, 4 galaxies, 15 planets (total: 219)
    final starCount = (400 * widget.particleDensity).round();
    final galaxyCount = (8 * widget.particleDensity).round();
    final planetCount = (30 * widget.particleDensity).round();

    // Generate stars with actual pixel coordinates
    _stars = List.generate(starCount, (i) {
      return Star(
        x: random.nextDouble() * width,
        y: random.nextDouble() * height,
        size: random.nextBool() ? 2.0 : 3.0, // Increased from 1-2 to 2-3
        layer: random.nextInt(3),
      );
    });

    // Generate galaxies
    _galaxies = List.generate(galaxyCount, (i) {
      return Galaxy(
        x: random.nextDouble() * width,
        y: random.nextDouble() * height,
        size: 40.0 + random.nextDouble() * 60.0, // Increased from 8-12 to 40-100
        layer: random.nextInt(3),
        color: AppTheme.cyanAccent.withValues(alpha: 0.15),
      );
    });

    // Generate planets
    _planets = List.generate(planetCount, (i) {
      final colors = [
        AppTheme.cyanAccent,
        AppTheme.magentaPrimary,
        AppTheme.greenPrimary,
        AppTheme.yellowPrimary,
        AppTheme.orangePrimary,
      ];

      return Planet(
        x: random.nextDouble() * width,
        y: random.nextDouble() * height,
        size: 12.0 + random.nextDouble() * 20.0, // Increased from 3-6 to 12-32
        layer: random.nextInt(3),
        color: colors[random.nextInt(colors.length)],
        beveled: random.nextBool(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Generate objects when we have screen size
    // Regenerate if density or screen size changes
    final screenSize = MediaQuery.of(context).size;
    if (_stars.isEmpty || _shouldRegenerateForScreenSize(screenSize)) {
      _generateObjectsForScreenSize(screenSize);
    }
  }

  bool _shouldRegenerateForScreenSize(Size newSize) {
    // Simple check: regenerate if screen width changed significantly
    if (_stars.isEmpty) return true;

    // Check if first star is way outside new bounds (screen size changed)
    if (_stars.first.x > newSize.width || _stars.first.y > newSize.height) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated starfield background
        Positioned.fill(
          child: CustomPaint(
            painter: StarfieldPainter(
              stars: _stars,
              galaxies: _galaxies,
              planets: _planets,
              timeNotifier: _timeNotifier,
            ),
          ),
        ),
        // Content overlay
        widget.child,
      ],
    );
  }
}
