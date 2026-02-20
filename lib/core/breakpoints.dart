import 'package:flutter/material.dart';

/// Responsive breakpoints for landing page layout
class Breakpoints {
  // Breakpoint values
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1920;

  // Screen size checks
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  // Responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 48.0;
    return 120.0; // Desktop: wide margins
  }

  // Responsive section spacing (between major sections)
  static double sectionSpacing(BuildContext context) {
    if (isMobile(context)) return 80.0;
    if (isTablet(context)) return 120.0;
    return 160.0;
  }

  // Responsive card spacing (between cards within a section)
  static double cardSpacing(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  // Responsive max content width (prevents ultra-wide layouts on large screens)
  static double maxContentWidth(BuildContext context) {
    return 1400.0;
  }

  // Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}
