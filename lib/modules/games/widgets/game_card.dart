import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class GameCard extends StatefulWidget {
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
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();

    final game = widget.game;
    final displayTitle = game?.title ?? widget.title ?? 'No Title';
    final displayImage = game?.image ?? widget.image;
    final displayPlatforms = game?.platforms ?? widget.platforms;
    final displayId = game?.id ?? widget.id;
    final displayWorth = game?.worth ?? widget.worth;
    final displayGenre = game?.genre;
    final displayRating = game?.rating ?? game?.internalRating;

    // Pricing logic
    final bool isDiscounted = game?.hasDiscount ?? false;
    final bool isFree = game?.isFreeGame ?? false;
    final bool isFreeLimited = game?.isFreeLimited ?? false;
    final String? discountPct = isDiscounted
        ? '-${game!.discountPercent}%'
        : null;
    final String? currentPrice = game?.displayPrice ?? widget.price;
    final String? originalPrice = game?.displayOriginalPrice ?? displayWorth;

    final isDesktop = MediaQuery.of(context).size.width > 600;

    return MouseRegion(
      onEnter: isDesktop ? (_) => setState(() => _isHovered = true) : null,
      onExit: isDesktop ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.18 : 0.08),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Image section ──────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        if (displayImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
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
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),

                        // ── Gradient overlay (bottom → top) ──────────
                        // Positioned(
                        //   bottom: 0,
                        //   left: 0,
                        //   right: 0,
                        //   height: 48,
                        //   child: DecoratedBox(
                        //     decoration: BoxDecoration(
                        //       gradient: LinearGradient(
                        //         begin: Alignment.bottomCenter,
                        //         end: Alignment.topCenter,
                        //         colors: [
                        //           Colors.black.withOpacity(0.7),
                        //           Colors.transparent,
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        // ── Top-left badge ────────────────────────────
                        if (isDiscounted && discountPct != null)
                          _buildDiscountBadge(discountPct)
                        else if (isFree)
                          _buildFreeBadge(isFreeLimited)
                        else if (currentPrice != null)
                          _buildPriceBadge(currentPrice),

                        // ── Wishlist button ────────────────────────────
                        if (displayId != null)
                          Obx(() {
                            final inList = wishlistController.isInWishlist(
                              displayId,
                            );
                            return Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => wishlistController.toggleWishlist(
                                  displayId,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    inList
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: inList ? Colors.red : Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                // ── Info section ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Genre tag ────────────────────────────────
                      if (displayGenre != null) _buildGenreTag(displayGenre),

                      // ── Title ────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(
                          top: displayGenre != null ? 2 : 0,
                        ),
                        child: Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ── Star rating ──────────────────────────────
                      if (displayRating != null && displayRating > 0)
                        _buildStarRating(displayRating),

                      // ── Platforms ────────────────────────────────
                      if (displayPlatforms != null &&
                          displayPlatforms.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: displayPlatforms.map((platform) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    platform,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                      // ── Price row ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: _buildPriceWidget(
                          isDiscounted,
                          isFree,
                          isFreeLimited,
                          originalPrice,
                          currentPrice,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Genre tag ─────────────────────────────────────────────────────────

  Widget _buildGenreTag(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        genre,
        style: TextStyle(
          fontSize: 9,
          color: Get.theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Star rating ───────────────────────────────────────────────────────

  Widget _buildStarRating(double rating) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;
    const starSize = 10.0;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(fullStars, (_) {
            return const Icon(Icons.star, size: starSize, color: Colors.amber);
          }),
          if (hasHalf)
            const Icon(Icons.star_half, size: starSize, color: Colors.amber),
          ...List.generate(
            5 - fullStars - (hasHalf ? 1 : 0),
            (_) =>
                Icon(Icons.star, size: starSize, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge builders ────────────────────────────────────────────────────

  Widget _buildDiscountBadge(String pct) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          pct,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeBadge(bool limited) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: limited
                ? [Colors.orange.shade400, Colors.deepOrange.shade400]
                : [Colors.green.shade500, Colors.green.shade400],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              limited ? Icons.timer_outlined : Icons.check_circle_outline,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              limited ? 'محدود' : 'مجاني',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBadge(String priceText) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          priceText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Price display builder ────────────────────────────────────────────

  Widget _buildPriceWidget(
    bool isDiscounted,
    bool isFree,
    bool isFreeLimited,
    String? original,
    String? current,
  ) {
    if (isDiscounted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (original != null)
            Text(
              original,
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          const SizedBox(width: 4),
          if (current != null)
            Text(
              current,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      );
    }

    if (isFree) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFreeLimited ? Icons.timer_outlined : Icons.check_circle_outline,
            size: 12,
            color: isFreeLimited ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              isFreeLimited ? 'مجاني محدود' : 'مجاني',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isFreeLimited ? Colors.orange : Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    if (current != null) {
      return Text(
        current,
        style: Get.textTheme.labelSmall?.copyWith(
          color: Colors.grey,
          fontSize: 11,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
