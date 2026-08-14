/// A widget that renders different layouts based on screen width.
///
/// Wraps [LayoutBuilder] to provide a clean API for responsive design.
/// Pass `mobile`, `tablet`, and/or `desktop` widgets.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(),
///   desktop: DesktopWidget(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../core/values/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.builder,
  });

  /// Widget to show on mobile screens (< 600px).
  final Widget? mobile;

  /// Widget to show on tablet screens (600px – 1024px).
  /// Falls back to [mobile] if not provided.
  final Widget? tablet;

  /// Widget to show on desktop screens (> 1024px).
  /// Falls back to [tablet], then [mobile] if not provided.
  final Widget? desktop;

  /// Advanced builder with [ScreenType] parameter for custom logic.
  /// If provided, [mobile], [tablet], and [desktop] are ignored.
  final Widget Function(BuildContext context, ScreenType screenType)? builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = _screenType(constraints.maxWidth);

        // Use builder if provided
        if (builder != null) {
          return builder!(context, type);
        }

        // Select appropriate widget
        switch (type) {
          case ScreenType.desktop:
            return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
          case ScreenType.tablet:
            return tablet ?? mobile ?? const SizedBox.shrink();
          case ScreenType.mobile:
            return mobile ?? const SizedBox.shrink();
        }
      },
    );
  }

  ScreenType _screenType(double width) {
    if (width >= AppBreakpoints.tabletBreakpoint) return ScreenType.desktop;
    if (width >= AppBreakpoints.mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  // ── Static convenience ─────────────────────────────────────────────────

  /// Returns the current [ScreenType] for the given context.
  /// Uses [MediaQuery] for most accurate result.
  static ScreenType of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppBreakpoints.tabletBreakpoint) return ScreenType.desktop;
    if (width >= AppBreakpoints.mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }
}
