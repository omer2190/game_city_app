import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/game_model.dart';
import 'package:game_city_app/modules/games/views/game_details_view.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

class DealCard extends StatelessWidget {
  final Game game;

  const DealCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deal = game.deal;

    return CustomCard(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'العرض الحالي',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (deal != null && deal.price != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (deal.regularPrice != null &&
                    deal.regularPrice != deal.price) ...[
                  Text(
                    '\$${formatPrice(deal.regularPrice!)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  '\$${formatPrice(deal.price!)}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (deal.cut != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${deal.cut}%',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.storefront,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  deal.shopName ?? game.store ?? 'متجر غير معروف',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                if (deal.expiry != null)
                  Text(
                    'ينتهي ${formatDate(deal.expiry!)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  game.freeType == 'permanent'
                      ? 'مجاني دائمًا'
                      : 'مجاني لفترة محدودة',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
