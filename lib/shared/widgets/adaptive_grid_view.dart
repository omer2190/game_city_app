/// A [GridView] that automatically calculates the number of columns
/// based on screen width, using [AppDimensions.gridCrossAxisCount].
///
/// Usage:
/// ```dart
/// AdaptiveGridView(
///   itemCount: games.length,
///   itemBuilder: (context, index) => GameCard(game: games[index]),
///   aspectRatio: 0.7,
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/values/app_dimensions.dart';

class AdaptiveGridView extends StatelessWidget {
  const AdaptiveGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.aspectRatio = 0.7,
    this.padding,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.mainAxisExtent,
    this.gridColumns,
  });

  /// Total number of items in the grid.
  final int itemCount;

  /// Builder function for each grid item.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Aspect ratio for each grid cell (default 0.7 for game cards).
  final double aspectRatio;

  /// Optional padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Horizontal spacing between columns. Defaults to [AppDimensions.cardSpacing].
  final double? crossAxisSpacing;

  /// Vertical spacing between rows. Defaults to [AppDimensions.cardSpacing].
  final double? mainAxisSpacing;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  /// Whether to shrink-wrap the grid (for nested scroll views).
  final bool shrinkWrap;

  /// Optional fixed main axis extent (item height).
  final double? mainAxisExtent;

  /// Optional override for the number of columns.
  /// If not provided, uses [AppDimensions.gridCrossAxisCount].
  final int? gridColumns;

  @override
  Widget build(BuildContext context) {
    final cols = gridColumns ?? AppDimensions.gridCrossAxisCount(context);
    final spacing = crossAxisSpacing ?? AppDimensions.cardSpacing(context);
    final mainSpacing = mainAxisSpacing ?? AppDimensions.cardSpacing(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          controller: controller,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding ?? const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: mainSpacing,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Extension: convert a regular list to an adaptive grid easily.
extension AdaptiveGridExtension on Widget {
  /// Wraps this widget (or each item of a list) in an adaptive grid.
  //  (Placeholder for future convenience methods — currently the
  //   AdaptiveGridView widget itself is the primary API.)
}
