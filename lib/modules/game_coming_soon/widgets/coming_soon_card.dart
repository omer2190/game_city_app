import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../data/models/game_model.dart';
import '../../../routes/app_routes.dart';
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
    Color textColor, {
    required bool isDesktop,
  }) {
    final valSize = isDesktop ? 15.0 : 13.0;
    final lblSize = isDesktop ? 9.0 : 8.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: valSize,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: lblSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDesktop = context.isDesktop;
    final titleFontSize = AppDimensions.scaledFontSize(context, 12);
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

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.gameDetails, arguments: {'gameId': game.id}),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Image — fills remaining space
            Expanded(
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
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.white,
                            size: isDesktop ? 22 : 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildTimeBox(
                        activeCountdown['minutes'].toString().padLeft(2, '0'),
                        'دقائق',
                        primaryColor,
                        theme.colorScheme.onPrimary,
                        isDesktop: isDesktop,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildTimeBox(
                        activeCountdown['hours'].toString().padLeft(2, '0'),
                        'ساعات',
                        primaryColor,
                        theme.colorScheme.onPrimary,
                        isDesktop: isDesktop,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildTimeBox(
                        activeCountdown['days'].toString().padLeft(2, '0'),
                        'يوماً',
                        primaryColor,
                        theme.colorScheme.onPrimary,
                        isDesktop: isDesktop,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Game Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: SizedBox(
                height: isDesktop ? 34 : 30,
                child: Center(
                  child: Text(
                    (game.title ?? '').toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),

            // Release Date
            Padding(
              padding: EdgeInsets.zero,
              child: Text(
                game.released != null
                    ? 'تصدر بتاريخ ${DateFormat('yyyy/MM/dd', 'ar').format(DateTime.tryParse(game.released!) ?? DateTime.now())}'
                    : (game.deal?.expiry != null
                          ? 'تصدر بتاريخ ${DateFormat('yyyy/MM/dd', 'ar').format(DateTime.tryParse(game.deal!.expiry!) ?? DateTime.now())}'
                          : 'يحدد لاحقاً'),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isDesktop ? 10 : 9,
                ),
              ),
            ),

            // Platform Icons
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: SizedBox(
                height: 24,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: (game.platforms ?? [])
                      .take(isDesktop ? 5 : 3)
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
      ),
    );
  }
}
