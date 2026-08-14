/// Responsive dimension helpers for Game City App.
///
/// Provides context-aware padding, spacing, radius, grid count,
/// and typography multipliers that adapt to the current screen size.
///
/// Usage:
/// ```dart
/// final pad = AppDimensions.horizontalPadding(context); // 16 | 24 | 32
/// final cols = AppDimensions.gridCrossAxisCount(context); // 2 | 3 | 5
/// ```
library;

import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

class AppDimensions {
  AppDimensions._();

  // ── Horizontail Padding ───────────────────────────────────────────────

  /// Adaptive horizontal padding based on screen width.
  /// - Mobile: 16px
  /// - Tablet: 24px
  /// - Desktop: 32px
  static double horizontalPadding(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile => 16.0,
      ScreenType.tablet => 24.0,
      ScreenType.desktop => 32.0,
    };
  }

  // ── Card Border Radius ─────────────────────────────────────────────────

  /// Adaptive card border radius.
  /// - Mobile: 12px
  /// - Tablet: 14px
  /// - Desktop: 16px
  static double cardRadius(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile => 12.0,
      ScreenType.tablet => 14.0,
      ScreenType.desktop => 16.0,
    };
  }

  // ── Grid Columns ───────────────────────────────────────────────────────

  /// Number of columns in a grid based on screen width.
  ///
  /// Typical usage: `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: AppDimensions.gridCrossAxisCount(context))`
  ///
  /// - Mobile: 2 columns
  /// - Tablet: 3 columns
  /// - Desktop: 4 columns (5 for wide screens > 1400px)
  static int gridCrossAxisCount(BuildContext context) {
    if (context.isWide) return 5;
    return switch (context.screenType) {
      ScreenType.mobile => 2,
      ScreenType.tablet => 3,
      ScreenType.desktop => 4,
    };
  }

  /// Number of columns for game card grids (larger cards need fewer columns).
  ///
  /// - Mobile: 2 columns
  /// - Tablet: 3 columns
  /// - Desktop: 4 columns (5 for wide)
  static int gameGridCrossAxisCount(BuildContext context) {
    if (context.isWide) return 5;
    return switch (context.screenType) {
      ScreenType.mobile => 2,
      ScreenType.tablet => 3,
      ScreenType.desktop => 4,
    };
  }

  /// Number of columns for news / content grids.
  ///
  /// - Mobile: 1 column
  /// - Tablet: 2 columns
  /// - Desktop: 3 columns
  static int newsGridCrossAxisCount(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile => 1,
      ScreenType.tablet => 2,
      ScreenType.desktop => 3,
    };
  }

  // ── Player / Avatar Grid ───────────────────────────────────────────────

  /// Number of columns for player / user avatar grids.
  ///
  /// - Mobile: 3 columns
  /// - Tablet: 4 columns
  /// - Desktop: 5 columns (7 for wide)
  static int playerGridCrossAxisCount(BuildContext context) {
    if (context.isWide) return 7;
    return switch (context.screenType) {
      ScreenType.mobile => 3,
      ScreenType.tablet => 4,
      ScreenType.desktop => 5,
    };
  }

  // ── Sidebar Width ──────────────────────────────────────────────────────

  /// Width of the sidebar navigation rail / drawer.
  ///
  /// - Tablet: 72px (compact rail)
  /// - Desktop: 240px (expanded)
  static double sidebarWidth(BuildContext context) {
    return context.isDesktop ? 240.0 : 72.0;
  }

  // ── Content Max Width ──────────────────────────────────────────────────

  /// Soft max-width for content areas to maintain readability.
  /// Returns null on mobile (full width); returns a reasonable max on larger screens.
  static double? contentMaxWidth(BuildContext context) {
    // Per user preference: no max-width. Content fills available space.
    // Uncomment to enable readability caps:
    // return switch (context.screenType) {
    //   ScreenType.mobile => null,
    //   ScreenType.tablet => 900.0,
    //   ScreenType.desktop => 1200.0,
    // };
    return null;
  }

  // ── Spacing Between Cards ──────────────────────────────────────────────

  /// Adaptive spacing between grid / list items.
  static double cardSpacing(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile => 12.0,
      ScreenType.tablet => 16.0,
      ScreenType.desktop => 20.0,
    };
  }

  // ── Section Spacing ────────────────────────────────────────────────────

  /// Vertical spacing between major sections.
  static double sectionSpacing(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile => 24.0,
      ScreenType.tablet => 32.0,
      ScreenType.desktop => 40.0,
    };
  }

  // ── Typography Scale ───────────────────────────────────────────────────

  /// Returns a font size multiplier based on screen size.
  ///
  /// - Mobile: 1.0 (no change)
  /// - Tablet: 1.05 (slight bump)
  /// - Desktop: 1.1 (more readable on larger screens)
  static double fontSizeMultiplier(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.05,
      ScreenType.desktop => 1.1,
    };
  }

  /// Scales a base font size for the current screen.
  static double scaledFontSize(BuildContext context, double baseSize) {
    return baseSize * fontSizeMultiplier(context);
  }
}
