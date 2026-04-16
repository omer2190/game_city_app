import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/models/game_model.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/game_coming_soon_controller.dart';

class ComingSoonCard extends StatelessWidget {
  final Game game;
  final GameComingSoonController controller = Get.find();
  final WishlistController wishlistController = Get.find();

  ComingSoonCard({super.key, required this.game});

  Widget _buildTimeBox(
    String value,
    String label,
    Color color,
    Color textColor,
  ) {
    return Container(
      width: 45,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _getPlatformIcon(String p) {
  //   p = p.toLowerCase();
  //   if (p.contains('pc') || p.contains('windows')) {
  //     return const Icon(Icons.computer, size: 20, color: Colors.white);
  //   }
  //   if (p.contains('ps') || p.contains('playstation')) {
  //     return const Icon(Icons.games, size: 20, color: Colors.white);
  //   }
  //   if (p.contains('xbox')) {
  //     return const Icon(Icons.videogame_asset, size: 20, color: Colors.white);
  //   }
  //   if (p.contains('switch')) {
  //     return const Icon(Icons.switch_left, size: 20, color: Colors.white);
  //   }
  //   return const Icon(Icons.gamepad, size: 20, color: Colors.white);
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final countdown = game.countdown;

    // Fallback countdown from deal expiry if released is null
    Map<String, int> activeCountdown = countdown;
    if (game.released == null && game.deal?.expiry != null) {
      try {
        final expiryDate = DateTime.parse(game.deal!.expiry!);
        final now = DateTime.now();
        if (expiryDate.isAfter(now)) {
          final difference = expiryDate.difference(now);
          activeCountdown = {
            'days': difference.inDays,
            'hours': difference.inHours % 24,
            'minutes': difference.inMinutes % 60,
          };
        }
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game Image
          AspectRatio(
            aspectRatio: 1, // Make image container square for consistency
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: game.image != null
                        ? CachedNetworkImage(
                            imageUrl: game.image!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.black26,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black26,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                            ),
                          ),
                  ),
                ),
                // Wishlist heart
                Obx(() {
                  final isInWishlist = wishlistController.isInWishlist(
                    game.id ?? '',
                  );
                  return Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        if (game.id != null) {
                          wishlistController.toggleWishlist(game.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Countdown section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeBox(
                  activeCountdown['minutes'].toString().padLeft(2, '0'),
                  'دقائق',
                  primaryColor,
                  theme.colorScheme.onPrimary,
                ),
                _buildTimeBox(
                  activeCountdown['hours'].toString().padLeft(2, '0'),
                  'ساعات',
                  primaryColor,
                  theme.colorScheme.onPrimary,
                ),
                _buildTimeBox(
                  activeCountdown['days'].toString().padLeft(2, '0'),
                  'يوماً',
                  primaryColor,
                  theme.colorScheme.onPrimary,
                ),
              ],
            ),
          ),

          // Game Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  (game.title ?? '').toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),

          // Release Date
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              game.released != null
                  ? 'تصدر بتاريخ ${DateFormat('yyyy/MM/dd', 'ar').format(DateTime.tryParse(game.released!) ?? DateTime.now())}'
                  : (game.deal?.expiry != null
                        ? 'تصدر بتاريخ ${DateFormat('yyyy/MM/dd', 'ar').format(DateTime.tryParse(game.deal!.expiry!) ?? DateTime.now())}'
                        : 'يحدد لاحقاً'),
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ),

          // Platform Icons
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: SizedBox(
              height: 24, // Fix height for platforms area
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: (game.platforms ?? [])
                    .take(3) // Limit to 3 for better fit in grid
                    .map(
                      (p) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
