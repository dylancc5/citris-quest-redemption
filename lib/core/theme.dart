import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== SPEC COLORS (from citris-quest-visual-spec.md) =====

  // Background colors
  static const Color backgroundPrimary = Color(
    0xFF0A0E27,
  ); // Very dark navy, almost black
  static const Color backgroundSecondary = Color(
    0xFF1A1F3A,
  ); // Slightly lighter navy for containers
  static const Color backgroundTertiary = Color(
    0xFF2A2F4A,
  ); // Card/modal backgrounds

  // Accent colors (Neon Rainbow Spectrum)
  static const Color bluePrimary = Color(
    0xFF1295D8,
  ); // CITRIS blue - main UI color
  static const Color cyanAccent = Color(0xFF00E5FF); // Lighter blue highlights
  static const Color magentaPrimary = Color(
    0xFFFF00B8,
  ); // Hot pink/magenta - secondary accent
  static const Color greenPrimary = Color(
    0xFF00FF88,
  ); // Success states, completed items
  static const Color yellowPrimary = Color(
    0xFFFFD700,
  ); // Highlights, warnings, rank #1
  static const Color orangePrimary = Color(
    0xFFFF6B00,
  ); // Special actions, alerts
  static const Color redPrimary = Color(0xFFFF0055); // Errors, critical states

  // Text colors
  static const Color textPrimary = Color(
    0xFFFFFFFF,
  ); // Pure white for main text
  static const Color textSecondary = Color(
    0xFF1295D8,
  ); // CITRIS blue for secondary text
  static const Color textAccent = Color(
    0xFF00E5FF,
  ); // Cyan for additional accents
  static const Color textTertiary = Color(0xFF7A8BA8); // Muted blue-gray
  static const Color textDisabled = Color(
    0xFF3A3F5A,
  ); // Very dim for disabled states

  // State colors
  static const Color success = Color(0xFF00FF88); // Neon green
  static const Color warning = Color(0xFFFFD700); // Neon yellow
  static const Color error = Color(0xFFFF0055); // Neon red
  static const Color disabled = Color(0xFF3A3F5A); // Inactive/disabled

  // Glow colors (40% opacity for blur effects)
  static final Color blueGlow = bluePrimary.withValues(alpha: 0.4);
  static final Color cyanGlow = cyanAccent.withValues(alpha: 0.4);
  static final Color magentaGlow = magentaPrimary.withValues(alpha: 0.4);
  static final Color greenGlow = greenPrimary.withValues(alpha: 0.4);
  static final Color yellowGlow = yellowPrimary.withValues(alpha: 0.4);
  static final Color orangeGlow = orangePrimary.withValues(alpha: 0.4);
  static final Color redGlow = redPrimary.withValues(alpha: 0.4);

  // ===== CARD COLORS (Data Chip Style) =====

  // Card background colors
  static const Color cardBackgroundBase = Color(0xFF16213e); // Dark navy base
  static const Color cardBackgroundTop = Color(
    0xFF0f1a2e,
  ); // Darker top for gradient
  static const Color cardBackgroundBottom = Color(
    0xFF1a2542,
  ); // Lighter bottom for gradient

  // Card gradient
  static const LinearGradient cardBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cardBackgroundTop, cardBackgroundBase, cardBackgroundBottom],
  );

  // Card border colors by state
  static const Color cardBorderCompleted =
      yellowPrimary; // Gold/amber for completed
  static const Color cardBorderInProgress = cyanAccent; // Cyan for in-progress
  static const Color cardBorderLocked =
      magentaPrimary; // Purple for locked/rare
  static const Color cardBorderDefault = bluePrimary; // Default blue

  // Card glow colors by state
  static final Color cardGlowCompleted = greenPrimary.withValues(
    alpha: 0.5,
  ); // Green glow for completed
  static final Color cardGlowInProgress = cyanAccent.withValues(
    alpha: 0.5,
  ); // Cyan glow for in-progress
  static final Color cardGlowLocked = magentaPrimary.withValues(
    alpha: 0.5,
  ); // Magenta glow for rare
  static final Color cardGlowDefault = bluePrimary.withValues(
    alpha: 0.5,
  ); // Default blue glow

  // Helper method to get card border color based on state
  static Color getCardBorderColor({
    bool isCompleted = false,
    bool isRare = false,
    bool isLocked = false,
  }) {
    if (isCompleted) return cardBorderCompleted;
    if (isRare || isLocked) return cardBorderLocked;
    return cardBorderInProgress;
  }

  // Helper method to get card glow color based on state
  static Color getCardGlowColor({
    bool isCompleted = false,
    bool isRare = false,
    bool isLocked = false,
  }) {
    if (isCompleted) return cardGlowCompleted;
    if (isRare || isLocked) return cardGlowLocked;
    return cardGlowInProgress;
  }

  // ===== LEGACY COLORS (backwards compatibility) =====
  @Deprecated('Use backgroundPrimary instead')
  static const Color primaryBackground = Color(0xFF1a1a2e);
  @Deprecated('Use backgroundSecondary instead')
  static const Color secondaryBackground = Color(0xFF16213e);
  @Deprecated('Use backgroundTertiary instead')
  static const Color accentBackground = Color(0xFF0f3460);
  @Deprecated('Use bluePrimary instead')
  static const Color primaryAccent = Colors.blue;
  @Deprecated('Use cyanAccent instead')
  static const Color secondaryAccent = Colors.cyan;

  // Gradient backgrounds (legacy - prefer solid backgrounds with starfield)
  @Deprecated('Use solid backgroundPrimary with AnimatedStarfield instead')
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
  );

  // Theme data
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.blue,
      // Use Micro 5 font globally (default for all screens except splash)
      textTheme: GoogleFonts.micro5TextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: backgroundPrimary,
    );
  }
}
