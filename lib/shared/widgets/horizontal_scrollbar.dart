import 'package:flutter/material.dart';

/// Wraps a horizontal scrollable with an always-visible scrollbar.
///
/// On desktop the mouse wheel produces a vertical delta which horizontal
/// scrollables ignore, so instead of wheel scrolling this shows a visible
/// scrollbar that can be dragged to scroll.
///
/// Usage:
/// ```dart
/// HorizontalScrollbar(
///   builder: (context, controller) => ListView.builder(
///     controller: controller,
///     scrollDirection: Axis.horizontal,
///     itemCount: items.length,
///     itemBuilder: (context, index) => ...,
///   ),
/// )
/// ```
class HorizontalScrollbar extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  const HorizontalScrollbar({super.key, required this.builder});

  @override
  State<HorizontalScrollbar> createState() => _HorizontalScrollbarState();
}

class _HorizontalScrollbarState extends State<HorizontalScrollbar> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      trackVisibility: true,
      // The default predicate only matches vertical scrollables, so we
      // override it to also respond to horizontal scroll notifications.
      notificationPredicate: (notification) => notification.depth == 0,
      child: widget.builder(context, _controller),
    );
  }
}
