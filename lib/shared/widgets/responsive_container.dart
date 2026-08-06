/// A container that centers and optionally constrains its child width.
///
/// On mobile, the child fills the full width.
/// On tablet/desktop, the child is centered with optional max-width.
///
/// Usage:
/// ```dart
/// ResponsiveContainer(
///   child: YourContent(),
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/values/app_breakpoints.dart';
import '../../core/values/app_dimensions.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  /// The content to display.
  final Widget child;

  /// Optional custom padding. If null, uses [AppDimensions.horizontalPadding].
  final EdgeInsetsGeometry? padding;

  /// Optional custom margin. If null, uses zero margin on mobile, auto on larger.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: AppDimensions.horizontalPadding(context),
        );

    final maxWidth = AppDimensions.contentMaxWidth(context);

    Widget content = Padding(padding: effectivePadding, child: child);

    // Add max-width constraint on larger screens (disabled per user preference)
    if (maxWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
