import 'dart:async';

import 'package:flutter/material.dart';

class ChipsWrap extends StatefulWidget {
  final List<String>? items;

  const ChipsWrap({super.key, this.items});

  @override
  State<ChipsWrap> createState() => _ChipsWrapState();
}

class _ChipsWrapState extends State<ChipsWrap>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animController;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(_scrollTick);
    // Start after layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    _resumeTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    // Only auto-scroll if there's overflow
    if (maxScroll <= 0) return;
    _animController.repeat();
  }

  void _scrollTick() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    // Scroll through the first copy only (half the total), then loop
    _scrollController.jumpTo(
      (_animController.value * maxScroll / 2) % (maxScroll / 2),
    );
  }

  void _onUserInteraction() {
    _animController.stop();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) _animController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items?.where((e) => e.isNotEmpty).toList() ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    Widget buildChip(String text) {
      return Container(
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final originalChips = items.map(buildChip).toList();
    // Duplicate for seamless looping
    final allChips = [...originalChips, ...originalChips];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          _onUserInteraction();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(mainAxisSize: MainAxisSize.min, children: allChips),
      ),
    );
  }
}
