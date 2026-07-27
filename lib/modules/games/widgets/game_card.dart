import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    this.onTap,
    this.title,
    this.image,
    this.platforms,
    this.worth,
    this.price,
    this.id,
    this.game,
  });

  final VoidCallback? onTap;
  final String? title;
  final String? image;
  final List<String>? platforms;
  final String? worth;
  final String? price;
  final String? id;
  final Game? game;

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();

    // Use game object if provided, otherwise fall back to individual fields
    final displayTitle = game?.title ?? title ?? 'No Title';
    final displayImage = game?.image ?? image;
    final displayPlatforms = game?.platforms ?? platforms;
    final displayId = game?.id ?? id;
    final displayWorth = game?.worth ?? worth;

    // Pricing logic
    final bool isDiscounted = game?.hasDiscount ?? false;
    final bool isFree = game?.isFreeGame ?? false;
    final bool isFreeLimited = game?.isFreeLimited ?? false;
    final String? discountPct = isDiscounted
        ? '-${game!.discountPercent}%'
        : null;
    final String? currentPrice = game?.displayPrice ?? price;
    final String? originalPrice = game?.displayOriginalPrice ?? displayWorth;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Image section ──────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  if (displayImage != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: displayImage,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // ── Top-left badge ──────────────────────────────────
                  if (isDiscounted && discountPct != null)
                    _buildDiscountBadge(context, discountPct)
                  else if (isFree)
                    _buildFreeBadge(context, isFreeLimited)
                  else if (currentPrice != null)
                    _buildPriceBadge(context, currentPrice),

                  // ── Wishlist button ──────────────────────────────────
                  if (displayId != null)
                    Obx(() {
                      final isInWishlist = wishlistController.isInWishlist(
                        displayId,
                      );
                      return Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            wishlistController.toggleWishlist(displayId);
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
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            // ── Info section ──────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Platforms
                    if (displayPlatforms != null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: displayPlatforms.map((platform) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                platform,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const Spacer(),

                    // ── Price row ──────────────────────────────────────
                    if (isDiscounted)
                      _buildDiscountedPriceRow(originalPrice, currentPrice)
                    else if (isFree)
                      _buildFreeLabel(isFreeLimited)
                    else if (currentPrice != null)
                      Text(
                        currentPrice,
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badge builders ────────────────────────────────────────────────────

  Widget _buildDiscountBadge(BuildContext context, String pct) {
    return Positioned(
      top: 5,
      left: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          pct,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeBadge(BuildContext context, bool limited) {
    return Positioned(
      top: 5,
      left: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: limited
                ? [Colors.orange, Colors.deepOrange]
                : [Colors.green.shade600, Colors.green.shade400],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              limited ? Icons.timer_outlined : Icons.check_circle_outline,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 3),
            Text(
              limited ? 'محدود' : 'مجاني',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBadge(BuildContext context, String priceText) {
    return Positioned(
      top: 5,
      left: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          priceText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Price display builders ────────────────────────────────────────────

  Widget _buildDiscountedPriceRow(String? original, String? current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (original != null)
          Text(
            original,
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        const SizedBox(width: 6),
        if (current != null)
          Text(
            current,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildFreeLabel(bool limited) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          limited ? Icons.timer_outlined : Icons.check_circle_outline,
          size: 14,
          color: limited ? Colors.orange : Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          limited ? 'مجاني لفترة محدودة' : 'مجاني',
          style: TextStyle(
            color: limited ? Colors.orange : Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
