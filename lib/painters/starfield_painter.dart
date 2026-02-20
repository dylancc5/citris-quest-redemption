import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents a single star in the starfield
class Star {
  final double x;
  final double y;
  final double size; // 1.0 or 2.0 pixels
  final int layer; // 0, 1, or 2 for 3-layer parallax

  const Star({
    required this.x,
    required this.y,
    required this.size,
    required this.layer,
  });
}

/// Represents a pixelized galaxy in the starfield
class Galaxy {
  final double x;
  final double y;
  final double size; // Base size in pixels
  final int layer; // 0, 1, or 2 for 3-layer parallax
  final Color color; // Galaxy color (subtle tint)

  const Galaxy({
    required this.x,
    required this.y,
    required this.size,
    required this.layer,
    required this.color,
  });
}

/// Represents a pixelized planet in the starfield
class Planet {
  final double x;
  final double y;
  final double size; // Planet size (side length for square) in pixels
  final int layer; // 0, 1, or 2 for 3-layer parallax
  final Color color; // Planet color
  final bool beveled; // If true, corners are removed (beveled square)

  const Planet({
    required this.x,
    required this.y,
    required this.size,
    required this.layer,
    required this.color,
    this.beveled = false,
  });
}

/// Custom painter for rendering a parallax starfield background
///
/// Features:
/// - 200-300 white stars at 30% opacity
/// - 3 depth layers with different parallax speeds
/// - Pixelated square stars (1-2px in size) for retro aesthetic
/// - Pixelized galaxies and planets for visual interest
/// - Time-based continuous animation (no loop jumps)
/// - Direct star rendering for smooth updates
class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final List<Galaxy> galaxies;
  final List<Planet> planets;
  final ValueNotifier<double> timeNotifier;

  // Const paint object - created once, reused for all stars
  static final _paint = Paint()
    ..color =
        const Color(0x4DFFFFFF) // White at 30% opacity (0x4D = ~0.3 * 255)
    ..style = PaintingStyle.fill;

  // Parallax multipliers for 3 layers (spec lines 1402-1405)
  // Layer 0 (back): slowest movement (0.02x scroll speed)
  // Layer 1 (mid): medium movement (0.05x scroll speed)
  // Layer 2 (front): fastest movement (0.08x scroll speed)
  static const _layerMultipliers = [0.02, 0.05, 0.08];

  // Animation speed: pixels per second
  static const double _scrollSpeedX = 75.0;
  static const double _scrollSpeedY = 60.0; // 600 pixels over 10 seconds

  StarfieldPainter({
    required this.stars,
    required this.timeNotifier,
    this.galaxies = const [],
    this.planets = const [],
  }) : super(repaint: timeNotifier);

  double get parallaxOffsetX => timeNotifier.value * _scrollSpeedX;
  double get parallaxOffsetY => timeNotifier.value * _scrollSpeedY;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Pre-calculate layer offsets to avoid repeated multiplication
    final layerOffsetX = [
      parallaxOffsetX * _layerMultipliers[0],
      parallaxOffsetX * _layerMultipliers[1],
      parallaxOffsetX * _layerMultipliers[2],
    ];
    final layerOffsetY = [
      parallaxOffsetY * _layerMultipliers[0],
      parallaxOffsetY * _layerMultipliers[1],
      parallaxOffsetY * _layerMultipliers[2],
    ];

    // Render galaxies first (background layer)
    for (final galaxy in galaxies) {
      final layer = galaxy.layer;

      // Apply parallax offset based on galaxy's layer
      var x = galaxy.x + layerOffsetX[layer];
      var y = galaxy.y + layerOffsetY[layer];

      // Wrap around screen edges for seamless scrolling (same as stars)
      x = x % width;
      if (x < 0) x += width;
      y = y % height;
      if (y < 0) y += height;

      // Smooth wrapping: render on both sides when crossing edges
      _drawGalaxyWithWrapping(
        canvas,
        x,
        y,
        galaxy.size,
        galaxy.color,
        width,
        height,
      );
    }

    // Render planets
    for (final planet in planets) {
      final layer = planet.layer;

      // Apply parallax offset based on planet's layer
      var x = planet.x + layerOffsetX[layer];
      var y = planet.y + layerOffsetY[layer];

      // Wrap around screen edges for seamless scrolling (same as stars)
      x = x % width;
      if (x < 0) x += width;
      y = y % height;
      if (y < 0) y += height;

      // Smooth wrapping: render on both sides when crossing edges
      _drawPlanetWithWrapping(
        canvas,
        x,
        y,
        planet.size,
        planet.color,
        planet.beveled,
        width,
        height,
      );
    }

    // Render all stars in a single pass
    for (final star in stars) {
      final layer = star.layer;

      // Apply parallax offset based on star's layer
      var x = star.x + layerOffsetX[layer];
      var y = star.y + layerOffsetY[layer];

      // Wrap around screen edges for seamless scrolling (optimized modulo)
      // Handle negative values correctly
      x = x % width;
      if (x < 0) x += width;
      y = y % height;
      if (y < 0) y += height;

      // Use sub-pixel positioning for smooth movement
      // The pixelated look comes from the small size, not integer snapping
      final pixelX = x;
      final pixelY = y;
      final pixelSize = star.size;

      // Draw star as a pixelated square (1-2px) for retro aesthetic
      canvas.drawRect(
        Rect.fromLTWH(pixelX, pixelY, pixelSize, pixelSize),
        _paint,
      );
    }
  }

  /// Draws a pixelized double spiral galaxy pattern
  void _drawPixelizedGalaxy(
    Canvas canvas,
    double centerX,
    double centerY,
    double size,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
          .withValues(alpha: 0.12.clamp(0.0, 1.0)) // Very subtle
      ..style = PaintingStyle.fill;

    final pixelSize = 2.0; // Pixel size for galaxy
    final radius = size;

    // Draw double spiral pattern (two arms)
    // First spiral arm
    for (double angle = 0; angle < 4 * pi; angle += 0.25) {
      final r = (angle / (4 * pi)) * radius;
      final x = centerX + cos(angle) * r;
      final y = centerY + sin(angle) * r;

      // Only draw if within reasonable bounds
      if (r < radius) {
        // Use sub-pixel positioning for smooth movement (no floorToDouble)
        canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), paint);
      }
    }

    // Second spiral arm (offset by 180 degrees)
    for (double angle = pi; angle < 4 * pi + pi; angle += 0.25) {
      final r = ((angle - pi) / (4 * pi)) * radius;
      final x = centerX + cos(angle) * r;
      final y = centerY + sin(angle) * r;

      // Only draw if within reasonable bounds
      if (r < radius) {
        // Use sub-pixel positioning for smooth movement
        canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), paint);
      }
    }

    // Add a few scattered pixels around the center for density
    final centerPaint = Paint()
      ..color = color.withValues(alpha: 0.15.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      final r = radius * 0.25;
      final x = centerX + cos(angle) * r;
      final y = centerY + sin(angle) * r;
      // Use sub-pixel positioning for smooth movement
      canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), centerPaint);
    }
  }

  /// Draws a planet with smooth wrapping across screen edges
  void _drawPlanetWithWrapping(
    Canvas canvas,
    double centerX,
    double centerY,
    double size,
    Color color,
    bool beveled,
    double width,
    double height,
  ) {
    // Calculate bounding box (for square, use size/2 as radius)
    final halfSize = size / 2;
    final left = centerX - halfSize;
    final right = centerX + halfSize;
    final top = centerY - halfSize;
    final bottom = centerY + halfSize;

    // Draw at primary position
    _drawPixelizedPlanet(canvas, centerX, centerY, size, color, beveled);

    // Draw wrapped versions if crossing edges
    // Wrap horizontally
    if (left < 0) {
      // Crossing left edge, draw on right side
      _drawPixelizedPlanet(
        canvas,
        centerX + width,
        centerY,
        size,
        color,
        beveled,
      );
    } else if (right > width) {
      // Crossing right edge, draw on left side
      _drawPixelizedPlanet(
        canvas,
        centerX - width,
        centerY,
        size,
        color,
        beveled,
      );
    }

    // Wrap vertically
    if (top < 0) {
      // Crossing top edge, draw on bottom side
      _drawPixelizedPlanet(
        canvas,
        centerX,
        centerY + height,
        size,
        color,
        beveled,
      );
    } else if (bottom > height) {
      // Crossing bottom edge, draw on top side
      _drawPixelizedPlanet(
        canvas,
        centerX,
        centerY - height,
        size,
        color,
        beveled,
      );
    }

    // Wrap corners (if crossing both edges)
    if (left < 0 && top < 0) {
      _drawPixelizedPlanet(
        canvas,
        centerX + width,
        centerY + height,
        size,
        color,
        beveled,
      );
    } else if (left < 0 && bottom > height) {
      _drawPixelizedPlanet(
        canvas,
        centerX + width,
        centerY - height,
        size,
        color,
        beveled,
      );
    } else if (right > width && top < 0) {
      _drawPixelizedPlanet(
        canvas,
        centerX - width,
        centerY + height,
        size,
        color,
        beveled,
      );
    } else if (right > width && bottom > height) {
      _drawPixelizedPlanet(
        canvas,
        centerX - width,
        centerY - height,
        size,
        color,
        beveled,
      );
    }
  }

  /// Draws a galaxy with smooth wrapping across screen edges
  void _drawGalaxyWithWrapping(
    Canvas canvas,
    double centerX,
    double centerY,
    double size,
    Color color,
    double width,
    double height,
  ) {
    // Calculate bounding box (galaxy extends to size radius)
    final radius = size;
    final left = centerX - radius;
    final right = centerX + radius;
    final top = centerY - radius;
    final bottom = centerY + radius;

    // Draw at primary position
    _drawPixelizedGalaxy(canvas, centerX, centerY, size, color);

    // Draw wrapped versions if crossing edges
    // Wrap horizontally
    if (left < 0) {
      // Crossing left edge, draw on right side
      _drawPixelizedGalaxy(canvas, centerX + width, centerY, size, color);
    } else if (right > width) {
      // Crossing right edge, draw on left side
      _drawPixelizedGalaxy(canvas, centerX - width, centerY, size, color);
    }

    // Wrap vertically
    if (top < 0) {
      // Crossing top edge, draw on bottom side
      _drawPixelizedGalaxy(canvas, centerX, centerY + height, size, color);
    } else if (bottom > height) {
      // Crossing bottom edge, draw on top side
      _drawPixelizedGalaxy(canvas, centerX, centerY - height, size, color);
    }

    // Wrap corners (if crossing both edges)
    if (left < 0 && top < 0) {
      _drawPixelizedGalaxy(
        canvas,
        centerX + width,
        centerY + height,
        size,
        color,
      );
    } else if (left < 0 && bottom > height) {
      _drawPixelizedGalaxy(
        canvas,
        centerX + width,
        centerY - height,
        size,
        color,
      );
    } else if (right > width && top < 0) {
      _drawPixelizedGalaxy(
        canvas,
        centerX - width,
        centerY + height,
        size,
        color,
      );
    } else if (right > width && bottom > height) {
      _drawPixelizedGalaxy(
        canvas,
        centerX - width,
        centerY - height,
        size,
        color,
      );
    }
  }

  /// Draws a pixelized square planet (complete square or beveled with corners removed)
  void _drawPixelizedPlanet(
    Canvas canvas,
    double centerX,
    double centerY,
    double size,
    Color color,
    bool beveled,
  ) {
    final pixelSize = 2.0;
    final halfSize = size / 2;

    // Calculate corner removal size for beveled squares (subtle - remove just 1 pixel from each corner)
    final cornerSize = beveled ? pixelSize * 0.5 : 0.0;

    // Draw a pixelated square
    for (double dx = -halfSize; dx < halfSize; dx += pixelSize) {
      for (double dy = -halfSize; dy < halfSize; dy += pixelSize) {
        // Check if this pixel should be drawn
        bool shouldDraw = true;

        if (beveled) {
          // For beveled squares, remove corners (small squares from each corner)
          // Check if we're in a corner region that should be removed
          // Top-left corner
          if (dx < -halfSize + cornerSize && dy < -halfSize + cornerSize) {
            shouldDraw = false;
          }
          // Top-right corner
          else if (dx >= halfSize - cornerSize && dy < -halfSize + cornerSize) {
            shouldDraw = false;
          }
          // Bottom-left corner
          else if (dx < -halfSize + cornerSize && dy >= halfSize - cornerSize) {
            shouldDraw = false;
          }
          // Bottom-right corner
          else if (dx >= halfSize - cornerSize && dy >= halfSize - cornerSize) {
            shouldDraw = false;
          }
        }

        if (shouldDraw) {
          // Add some variation for a more interesting planet surface
          final variation = (sin(dx * 0.5) * cos(dy * 0.5) * 0.1 + 1.0);
          // More subtle opacity for planets - ensure it's clamped to valid range
          final alphaValue = (0.12 * variation)
              .clamp(0.06, 0.15)
              .clamp(0.0, 1.0);
          final pixelPaint = Paint()
            ..color = color.withValues(alpha: alphaValue)
            ..style = PaintingStyle.fill;

          // Use sub-pixel positioning for smooth movement (no floorToDouble)
          canvas.drawRect(
            Rect.fromLTWH(centerX + dx, centerY + dy, pixelSize, pixelSize),
            pixelPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) {
    // Time value changes trigger repaint automatically via repaint parameter
    return oldDelegate.timeNotifier.value != timeNotifier.value;
  }
}

/// Custom painter for rendering a single parallax layer of stars
/// Used for caching individual layers with PictureRecorder
class StarfieldLayerPainter extends CustomPainter {
  final List<Star> stars;
  final int layer;

  const StarfieldLayerPainter({required this.stars, required this.layer});

  @override
  void paint(Canvas canvas, Size size) {
    // White stars at 30% opacity (spec requirement)
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    // Only render stars for this specific layer
    for (final star in stars) {
      if (star.layer != layer) continue;

      // Snap to integer pixel coordinates for crisp pixelated look
      final pixelX = star.x.floorToDouble();
      final pixelY = star.y.floorToDouble();
      final pixelSize = star.size;

      // Draw star as a pixelated square (1-2px) for retro aesthetic
      canvas.drawRect(
        Rect.fromLTWH(pixelX, pixelY, pixelSize, pixelSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldLayerPainter oldDelegate) {
    // Never repaint - layers are cached as Pictures
    return false;
  }
}

/// Helper class to generate cached Picture objects for starfield layers
class StarfieldPictureCache {
  /// Generates a cached Picture for a specific layer with tiling support
  ///
  /// Parameters:
  /// - stars: List of all stars (for single screen)
  /// - layer: Layer index (0, 1, or 2)
  /// - width: Canvas width (for single screen)
  /// - height: Canvas height (for single screen)
  /// - tileCount: Number of tiles in each direction (default 2 for 2x2 = 4 tiles total)
  static ui.Picture generateLayerPicture({
    required List<Star> stars,
    required int layer,
    required double width,
    required double height,
    int tileCount = 2,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final tileWidth = width * tileCount;
    final tileHeight = height * tileCount;
    final size = Size(tileWidth, tileHeight);

    // Create tiled stars by replicating stars across the tile grid
    // This ensures seamless wrapping when we apply parallax offsets
    final tiledStars = <Star>[];
    for (int tx = 0; tx < tileCount; tx++) {
      for (int ty = 0; ty < tileCount; ty++) {
        for (final star in stars) {
          if (star.layer != layer) continue;
          tiledStars.add(
            Star(
              x: star.x + (tx * width),
              y: star.y + (ty * height),
              size: star.size,
              layer: star.layer,
            ),
          );
        }
      }
    }

    // Render the tiled layer using the layer painter
    final painter = StarfieldLayerPainter(stars: tiledStars, layer: layer);
    painter.paint(canvas, size);

    return recorder.endRecording();
  }
}

/// Optimized painter that uses cached Picture objects for each layer
/// This reduces draw calls from 250 (one per star) to 3 (one per layer)
/// The cached pictures are 2x2 tiles to support seamless wrapping
class CachedStarfieldPainter extends CustomPainter {
  final ui.Picture layer0Picture;
  final ui.Picture layer1Picture;
  final ui.Picture layer2Picture;
  final Animation<double> animation;
  final double width;
  final double height;

  // Parallax multipliers for 3 layers
  static const _layerMultipliers = [0.02, 0.05, 0.08];

  CachedStarfieldPainter({
    required this.layer0Picture,
    required this.layer1Picture,
    required this.layer2Picture,
    required this.animation,
    required this.width,
    required this.height,
  }) : super(repaint: animation);

  double get parallaxOffsetX => animation.value * 100;
  double get parallaxOffsetY => animation.value * 150;

  @override
  void paint(Canvas canvas, Size size) {
    // Clip to screen bounds to ensure we only draw within visible area
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));

    // Pre-calculate layer offsets
    final layerOffsetX = [
      parallaxOffsetX * _layerMultipliers[0],
      parallaxOffsetX * _layerMultipliers[1],
      parallaxOffsetX * _layerMultipliers[2],
    ];
    final layerOffsetY = [
      parallaxOffsetY * _layerMultipliers[0],
      parallaxOffsetY * _layerMultipliers[1],
      parallaxOffsetY * _layerMultipliers[2],
    ];

    // Draw each cached layer with parallax offset
    // The cached pictures are 2x2 tiles (2*width x 2*height) for seamless wrapping
    final layers = [layer0Picture, layer1Picture, layer2Picture];

    for (int layer = 0; layer < 3; layer++) {
      final offsetX = layerOffsetX[layer];
      final offsetY = layerOffsetY[layer];

      // Translate canvas to show stars at parallax offset position
      // Stars in cached picture are at base positions (x, y)
      // We translate by (-offsetX, -offsetY) so they appear at (x + offsetX, y + offsetY)
      // The 2x2 tile ensures stars are available for seamless wrapping
      canvas.save();
      canvas.translate(-offsetX, -offsetY);
      canvas.drawPicture(layers[layer]);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CachedStarfieldPainter oldDelegate) {
    // Animation value changes trigger repaint automatically via repaint parameter
    return false;
  }
}

/// Helper class to generate random stars, galaxies, and planets for the starfield
class StarfieldGenerator {
  /// Generates a list of [count] random stars distributed across the canvas
  ///
  /// Parameters:
  /// - count: Number of stars to generate (spec recommends 200-300)
  /// - width: Canvas width for star positioning
  /// - height: Canvas height for star positioning
  /// - seed: Optional random seed for reproducible star fields
  static List<Star> generate({
    required int count,
    required double width,
    required double height,
    int? seed,
  }) {
    final random = seed != null ? Random(seed) : Random();

    return List.generate(count, (i) {
      return Star(
        // Distribute stars evenly across the canvas area
        x: random.nextDouble() * width,
        y: random.nextDouble() * height,
        // 50/50 chance of 1px or 2px pixelated square star
        size: random.nextBool() ? 1.0 : 2.0,
        // Evenly distribute across 3 layers
        layer: random.nextInt(3),
      );
    });
  }

  /// Generates a list of random galaxies distributed across the canvas
  ///
  /// Parameters:
  /// - count: Number of galaxies to generate (default: 3-5)
  /// - width: Canvas width for galaxy positioning
  /// - height: Canvas height for galaxy positioning
  /// - seed: Optional random seed for reproducible generation
  static List<Galaxy> generateGalaxies({
    int count = 4,
    required double width,
    required double height,
    int? seed,
  }) {
    final random = seed != null ? Random(seed) : Random();
    final colors = [
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFFF00B8), // Magenta
      const Color(0xFF00FF88), // Green
      const Color(0xFF1295D8), // Blue
    ];

    return List.generate(count, (i) {
      // Start galaxies off-screen (1.5x width to the left and below)
      // This prevents them from spawning visibly on screen
      final maxSize = 50.0; // Max galaxy size
      return Galaxy(
        x: -maxSize - random.nextDouble() * (width * 0.5),
        y: height + maxSize + random.nextDouble() * (height * 0.5),
        size: 20 + random.nextDouble() * 30, // 20-50 pixels
        layer: random.nextInt(3),
        color: colors[random.nextInt(colors.length)],
      );
    });
  }

  /// Generates a list of random planets distributed across the canvas
  ///
  /// Parameters:
  /// - count: Number of planets to generate (default: 18 for more but subtle)
  /// - width: Canvas width for planet positioning
  /// - height: Canvas height for planet positioning
  /// - seed: Optional random seed for reproducible generation
  static List<Planet> generatePlanets({
    int count = 18,
    required double width,
    required double height,
    int? seed,
  }) {
    final random = seed != null ? Random(seed) : Random();
    final colors = [
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFFF6B00), // Orange
      const Color(0xFF00FF88), // Green
      const Color(0xFFFFD700), // Yellow
      const Color(0xFF1295D8), // Blue
    ];

    return List.generate(count, (i) {
      // Start planets off-screen (scattered in the off-screen region)
      // Some to the left, some below, some at corners
      final maxSize = 12.0; // Max planet size
      final spawnRegion = random.nextInt(3);

      double x, y;
      if (spawnRegion == 0) {
        // Spawn to the left
        x = -maxSize - random.nextDouble() * (width * 0.3);
        y = random.nextDouble() * height;
      } else if (spawnRegion == 1) {
        // Spawn below
        x = random.nextDouble() * width;
        y = height + maxSize + random.nextDouble() * (height * 0.3);
      } else {
        // Spawn at bottom-left corner
        x = -maxSize - random.nextDouble() * (width * 0.2);
        y = height + maxSize + random.nextDouble() * (height * 0.2);
      }

      return Planet(
        x: x,
        y: y,
        size:
            5.0 +
            random.nextDouble() *
                7.0, // 5-12 pixels side length (only a few times bigger than stars)
        layer: random.nextInt(3),
        color: colors[random.nextInt(colors.length)],
        beveled: random
            .nextBool(), // Randomly choose between complete square or beveled
      );
    });
  }
}
