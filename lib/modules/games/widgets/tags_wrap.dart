import 'package:flutter/material.dart';

class TagsWrap extends StatelessWidget {
  final List<dynamic> tags;

  const TagsWrap({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final names = tags
        .whereType<Map<String, dynamic>>()
        .map((t) => t['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    if (names.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: names
          .map(
            (name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
