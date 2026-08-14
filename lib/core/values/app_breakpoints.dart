/// Responsive breakpoint system for Game City App.
///
/// Defines screen size breakpoints and provides convenient
/// extensions on [BuildContext] for checking device type.
///
/// Usage:
/// ```dart
/// if (context.isMobile) { ... }
/// switch (context.screenType) { ... }
/// ```
library;

import 'package:flutter/material.dart';

/// Screen size breakpoints (in logical pixels).
class AppBreakpoints {
  AppBreakpoints._();

  /// Width at which we switch from mobile to tablet layout.
  static const double mobileBreakpoint = 600;

  /// Width at which we switch from tablet to desktop layout.
  static const double tabletBreakpoint = 1024;

  /// Width at which we consider the screen "wide" for extra columns.
  static const double wideBreakpoint = 1400;
}

/// The type of screen based on current width.
enum ScreenType {
  /// Phone-sized devices (< 600px wide).
  mobile,

  /// Tablet-sized devices (600px – 1024px wide).
  tablet,

  /// Desktop / large screens (> 1024px wide).
  desktop,
}

/// Responsive helpers available on any [BuildContext].
extension ResponsiveContext on BuildContext {
  // ── Dimensions ─────────────────────────────────────────────────────────

  /// Current screen width in logical pixels.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Current screen height in logical pixels.
  double get screenHeight => MediaQuery.of(this).size.height;

  // ── Type checks ────────────────────────────────────────────────────────

  /// Whether the current screen is mobile-sized (< 600px).
  bool get isMobile =>
      MediaQuery.of(this).size.width < AppBreakpoints.mobileBreakpoint;

  /// Whether the current screen is tablet-sized (600px – 1024px).
  bool get isTablet =>
      MediaQuery.of(this).size.width >= AppBreakpoints.mobileBreakpoint &&
      MediaQuery.of(this).size.width < AppBreakpoints.tabletBreakpoint;

  /// Whether the current screen is desktop-sized (> 1024px).
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= AppBreakpoints.tabletBreakpoint;

  /// Whether the screen is tablet-sized or larger.
  bool get isDesktopOrTablet => isTablet || isDesktop;

  /// Whether the screen is wide enough for extra columns (> 1400px).
  bool get isWide =>
      MediaQuery.of(this).size.width >= AppBreakpoints.wideBreakpoint;

  // ── Categorization ─────────────────────────────────────────────────────

  /// Returns the current [ScreenType].
  ScreenType get screenType {
    final w = MediaQuery.of(this).size.width;
    if (w >= AppBreakpoints.tabletBreakpoint) return ScreenType.desktop;
    if (w >= AppBreakpoints.mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }
}
