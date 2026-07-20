import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

class StoresList extends StatelessWidget {
  final List<dynamic> stores;
  final ValueSetter<String?> onTap;

  const StoresList({required this.stores, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = stores
        .whereType<Map<String, dynamic>>()
        .where((s) => s['store'] != null)
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((s) {
        final store = s['store'] as Map<String, dynamic>?;
        final name = store?['name']?.toString() ?? 'متجر';
        final url = s['url']?.toString() ?? '';

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: url.isNotEmpty ? () => onTap(url) : null,
          child: Row(
            children: [
              Icon(Icons.shopping_cart, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
