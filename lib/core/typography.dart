import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography constants following Apple Human Interface Guidelines
/// All sizes are in pt (points), with responsive scaling
///
/// Font Scaling Policy:
/// - Default body text: 17pt (Apple standard)
/// - Minimum allowed: 13pt (enforced globally for improved readability)
/// - Responsive scaling based on screen width while maintaining minimums
/// - Dynamic Type support disabled (for consistent game UI)
///
/// Apple HIG Reference:
/// https://developer.apple.com/design/human-interface-guidelines/typography
///
/// Typography System - Dual Font Support
///
/// This app uses TWO fonts:
/// 1. Tiny 5 - Finer, more readable (DEFAULT for all screens)
/// 2. Silkscreen - Bold, chunky, retro (splash screen only via silk___ methods)
///
/// Default methods use Micro 5:
/// - largeTitle(), body(), headline(), etc.
///
/// Silk methods use Silkscreen:
/// - silkLargeTitle(), silkBody(), silkHeadline(), etc.
///
/// To add a new font:
/// 1. Create a new _fontStyle helper (e.g., _newFontStyle)
/// 2. Duplicate all methods with new prefix (e.g., newTitle1)
/// 3. Update screens to use the new methods
class AppTypography {
  // Font families
  static const String fontFamily = 'Tiny5'; // Default (custom font family)
  static const String silkFontFamily = 'Silkscreen'; // Splash screen

  /// Returns the TextStyle for Tiny 5 (default font)
  /// Used for all screens except splash screen
  static TextStyle _fontStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    // Uses the Tiny5 font family. Make sure this is defined in pubspec.yaml
    // under flutter: fonts: with family: Tiny5 for the custom font to load.
    return GoogleFonts.tiny5(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Returns the TextStyle for Silkscreen font
  /// Used for splash screen via silk___ methods
  static TextStyle _silkFontStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.silkscreen(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Base font sizes (pt)
  // These are close to Apple HIG defaults so the UI feels polished and readable
  static const double _baseLargeTitle = 34.0; // Major headings, splash screens
  static const double _baseTitle1 = 28.0; // Primary section titles
  static const double _baseTitle2 = 22.0; // Secondary section titles
  static const double _baseTitle3 = 20.0; // Tertiary section titles
  static const double _baseHeadline = 17.0; // Emphasized body text
  static const double _baseBody = 17.0; // Default body text
  static const double _baseCallout = 16.0; // Secondary content
  static const double _baseSubheadline = 15.0; // Secondary labels
  static const double _baseFootnote = 15.0; // Tertiary content
  static const double _baseCaption1 = 14.0; // Small text
  static const double _baseCaption2 = 13.0; // Minimum readable

  // Maximum font sizes (prevent scaling too large on wide screens)
  static const double _maxLargeTitle = 52.0;
  static const double _maxTitle1 = 42.0;
  static const double _maxTitle2 = 34.0;
  static const double _maxTitle3 = 30.0;
  static const double _maxHeadline = 26.0;
  static const double _maxBody = 24.0;
  static const double _maxCallout = 22.0;
  static const double _maxSubheadline = 20.0;
  static const double _maxFootnote = 20.0;
  static const double _maxCaption1 = 18.0;
  static const double _maxCaption2 = 17.0;

  // Responsive scaling factors (percentage of screen width)
  // Tuned to keep card/content text compact and comfortable
  static const double _largetitleFactor = 0.09;
  static const double _title1Factor = 0.07;
  static const double _title2Factor = 0.055;
  static const double _title3Factor = 0.05;
  static const double _headlineFactor = 0.045;
  static const double _bodyFactor = 0.045;
  static const double _calloutFactor = 0.04;
  static const double _subheadlineFactor = 0.035;
  static const double _footnoteFactor = 0.033;
  static const double _caption1Factor = 0.03;
  static const double _caption2Factor = 0.028;

  // Font scaling constraints
  static const double minFontSize = 13.0; // Minimum readable
  static const double defaultFontSize = 17.0; // Standard body
  static const double minScaleFactor = minFontSize / defaultFontSize;

  /// Clamps font size to minimum readable size (13pt)
  static double clampFontSize(double size) {
    return size < minFontSize ? minFontSize : size;
  }

  /// Gets responsive font size based on screen width and factor
  /// Ensures the result is never below 13pt minimum
  static double getResponsiveSize(
    BuildContext context,
    double factor, {
    double? minSize,
    double? maxSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedSize = screenWidth * factor;
    final minimum = minSize ?? minFontSize;
    final maximum = maxSize ?? _maxLargeTitle;
    return calculatedSize.clamp(minimum, maximum);
  }

  /// Creates responsive TextStyle with specified size factor
  /// Automatically enforces 13pt minimum
  static TextStyle responsive(
    BuildContext context,
    double factor, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    double? minSize,
  }) {
    return _fontStyle(
      fontSize: getResponsiveSize(context, factor, minSize: minSize),
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ===== RESPONSIVE TEXT STYLES =====
  // These methods provide Apple-compliant responsive sizing

  /// Large title style (34pt base, scales with screen)
  /// Used for: Major headings, splash screens
  /// Factor: 9% of screen width, minimum 34pt
  static TextStyle largeTitle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _largetitleFactor).clamp(_baseLargeTitle, _maxLargeTitle),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Title 1 style (28pt base, scales with screen)
  /// Used for: Primary section titles
  /// Factor: 7% of screen width, minimum 28pt
  static TextStyle title1(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _title1Factor).clamp(_baseTitle1, _maxTitle1),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      // Slightly lighter by default so card titles feel less shouty
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Title 2 style (22pt base, scales with screen)
  /// Used for: Secondary section titles
  /// Factor: 5.5% of screen width, minimum 22pt
  static TextStyle title2(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _title2Factor).clamp(_baseTitle2, _maxTitle2),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      // Slightly lighter by default so card titles feel less shouty
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Title 3 style (20pt base, scales with screen)
  /// Used for: Tertiary section titles
  /// Factor: 5% of screen width, minimum 20pt
  static TextStyle title3(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _title3Factor).clamp(_baseTitle3, _maxTitle3),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      // Slightly lighter by default so tertiary titles feel balanced on cards
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Headline style (17pt base, scales with screen)
  /// Used for: Emphasized body text, important labels
  /// Factor: 4.5% of screen width, minimum 17pt
  static TextStyle headline(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _headlineFactor).clamp(_baseHeadline, _maxHeadline),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Body style (17pt base, scales with screen)
  /// Used for: Default body text, primary content
  /// Factor: 4.5% of screen width, minimum 17pt
  /// This is the Apple standard for readable body text
  static TextStyle body(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _bodyFactor).clamp(_baseBody, _maxBody),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Callout style (16pt base, scales with screen)
  /// Used for: Secondary content, button labels
  /// Factor: 4% of screen width, minimum 16pt
  static TextStyle callout(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _calloutFactor).clamp(_baseCallout, _maxCallout),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Subheadline style (15pt base, scales with screen)
  /// Used for: Secondary labels, supporting text
  /// Factor: 3.5% of screen width, minimum 15pt
  static TextStyle subheadline(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _subheadlineFactor).clamp(
        _baseSubheadline,
        _maxSubheadline,
      ),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Footnote style (15pt base, scales with screen)
  /// Used for: Tertiary content, helper text
  /// Factor: 3.3% of screen width, minimum 15pt
  static TextStyle footnote(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _footnoteFactor).clamp(_baseFootnote, _maxFootnote),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Caption 1 style (14pt base, scales with screen)
  /// Used for: Small text, timestamps
  /// Factor: 3% of screen width, minimum 14pt
  static TextStyle caption1(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _caption1Factor).clamp(_baseCaption1, _maxCaption1),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Caption 2 style (13pt base, scales with screen)
  /// Used for: Minimum readable text, tiny labels
  /// Factor: 2.8% of screen width, minimum 13pt
  /// This is the absolute minimum size enforced globally
  static TextStyle caption2(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _caption2Factor).clamp(_baseCaption2, _maxCaption2),
    );
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ===== SPEC-COMPLIANT TEXT STYLES =====
  // These methods match the visual spec requirements (lines 150-187)

  /// Heading XL style - spec line 150
  /// 36px base (1.5x), 700 weight, 2px letter-spacing, uppercase
  /// Used for: "CITRIS QUEST" title
  static TextStyle headingXL(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 36px base size (1.5x from 24px), scaled proportionally
    final size = (screenWidth * 0.09).clamp(minFontSize, _maxLargeTitle);
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 2.0,
      height: height,
    );
  }

  /// Heading M style - spec line 162
  /// 24px base (1.5x), 700 weight, 1px letter-spacing
  /// Used for: "Hello!" text
  static TextStyle headingM(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 24px base size (1.5x from 16px), scaled proportionally
    final size = (screenWidth * 0.06).clamp(minFontSize, _maxTitle1);
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 1.0,
      height: height,
    );
  }

  /// Body L style - spec line 167
  /// 31.5px base (2.25x), 400 weight, 0.5px letter-spacing
  /// Used for: "Welcome to" text
  /// Note: Reduced by 25% from original size
  static TextStyle bodyL(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Reduced by 25% - was 0.07875, now 0.0590625 (0.07875 * 0.75)
    final size = (screenWidth * 0.0590625).clamp(minFontSize, _maxTitle2);
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.5,
      height: height,
    );
  }

  /// Button text style - spec line 183
  /// 21px base (1.5x), 700 weight, 1px letter-spacing, uppercase
  /// Used for: Button labels
  static TextStyle buttonText(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 21px base size (1.5x from 14px), scaled proportionally
    final size = (screenWidth * 0.0525).clamp(minFontSize, _maxTitle3);
    return _fontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 1.0,
      height: height,
    );
  }

  // ===== LEGACY SUPPORT =====
  // Static getters for backwards compatibility

  /// Creates a TextStyle with the default body font size (17pt)
  /// Note: For responsive sizing, use body(context) instead
  static TextStyle get bodyStyle => _fontStyle(fontSize: _baseBody);

  /// Creates a TextStyle with the minimum font size (13pt)
  /// Note: For responsive sizing, use caption2(context) instead
  static TextStyle get minimumStyle => _fontStyle(fontSize: _baseCaption2);

  // ===== SILKSCREEN FONT METHODS =====
  // These methods use Silkscreen font for splash screen

  /// Silkscreen: Creates responsive TextStyle with specified size factor
  static TextStyle silkResponsive(
    BuildContext context,
    double factor, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    double? minSize,
  }) {
    return _silkFontStyle(
      fontSize: getResponsiveSize(context, factor, minSize: minSize),
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Large title style (34pt base, scales with screen)
  static TextStyle silkLargeTitle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _largetitleFactor).clamp(_baseLargeTitle, _maxLargeTitle),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Title 1 style (28pt base, scales with screen)
  static TextStyle silkTitle1(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _title1Factor).clamp(_baseTitle1, _maxTitle1),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Title 2 style (22pt base, scales with screen)
  static TextStyle silkTitle2(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _title2Factor).clamp(_baseTitle2, _maxTitle2),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Title 3 style (20pt base, scales with screen)
  static TextStyle silkTitle3(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _title3Factor).clamp(_baseTitle3, _maxTitle3),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Headline style (17pt base, scales with screen)
  static TextStyle silkHeadline(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _headlineFactor).clamp(_baseHeadline, _maxHeadline),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Body style (17pt base, scales with screen)
  static TextStyle silkBody(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _bodyFactor).clamp(_baseBody, _maxBody),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Callout style (16pt base, scales with screen)
  static TextStyle silkCallout(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _calloutFactor).clamp(_baseCallout, _maxCallout),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Subheadline style (15pt base, scales with screen)
  static TextStyle silkSubheadline(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _subheadlineFactor).clamp(
        _baseSubheadline,
        _maxSubheadline,
      ),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Footnote style (15pt base, scales with screen)
  static TextStyle silkFootnote(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _footnoteFactor).clamp(_baseFootnote, _maxFootnote),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Caption 1 style (14pt base, scales with screen)
  static TextStyle silkCaption1(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _caption1Factor).clamp(_baseCaption1, _maxCaption1),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Caption 2 style (13pt base, scales with screen)
  static TextStyle silkCaption2(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = clampFontSize(
      (screenWidth * _caption2Factor).clamp(_baseCaption2, _maxCaption2),
    );
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Silkscreen: Heading XL style - for "CITRIS QUEST" title
  static TextStyle silkHeadingXL(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.09).clamp(minFontSize, _maxLargeTitle);
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 2.0,
      height: height,
    );
  }

  /// Silkscreen: Heading M style - for "Play" button
  static TextStyle silkHeadingM(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.06).clamp(minFontSize, _maxTitle1);
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 1.0,
      height: height,
    );
  }

  /// Silkscreen: Body L style - for "Welcome to" text
  static TextStyle silkBodyL(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.0590625).clamp(minFontSize, _maxTitle2);
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.5,
      height: height,
    );
  }

  /// Silkscreen: Button text style
  static TextStyle silkButtonText(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.0525).clamp(minFontSize, _maxTitle3);
    return _silkFontStyle(
      fontSize: size,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 1.0,
      height: height,
    );
  }

  /// Silkscreen: Body style getter (legacy support)
  static TextStyle get silkBodyStyle => _silkFontStyle(fontSize: _baseBody);

  /// Silkscreen: Minimum style getter (legacy support, 13pt)
  static TextStyle get silkMinimumStyle =>
      _silkFontStyle(fontSize: _baseCaption2);
}
