import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';

class FreeGameDetailsInfo extends StatelessWidget {
  final Game game;

  const FreeGameDetailsInfo({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            game.title ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              bool isComingSoon = game.status == 'coming_soon';
              if (!isComingSoon && game.released != null) {
                try {
                  final releaseDate = DateTime.parse(game.released!);
                  isComingSoon = releaseDate.isAfter(DateTime.now());
                } catch (_) {}
              }

              return Column(
                children: [
                  if (isComingSoon)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'لعبة قادمة قريباً',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (game.genre != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.genre!,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (game.store != null || game.deal?.shopName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store, size: 16, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        game.deal?.shopName ?? game.store ?? 'متجر غير معروف',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (game.deal?.price != null ||
              game.deal?.worth != null ||
              game.worth != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (game.deal?.regularPrice != null &&
                      game.deal?.regularPrice != game.deal?.price)
                    Text(
                      '\$${game.deal!.regularPrice} ',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (game.freeType == 'temporary')
                    Text(
                      game.deal?.price != null
                          ? '\$${game.deal!.price}'
                          : (game.deal?.worth ?? game.worth ?? ''),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (game.freeType != 'temporary')
                    Text(
                      game.deal?.price != null
                          ? '\$${game.deal!.price}'
                          : (game.deal?.worth ?? game.worth ?? ''),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

          // add card name= free
          if (game.freeType == 'permanent') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'مجاني دائمًا',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else if (game.freeType == 'temporary') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'مجاني لفترة محدودة',
                style: TextStyle(
                  color: Get.theme.colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
