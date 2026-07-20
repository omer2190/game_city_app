import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/game_model.dart';

/// A compact horizontal card used in home page sections.
class GameHorizontalCard extends StatelessWidget {
  const GameHorizontalCard({
    super.key,
    required this.game,
    this.onTap,
    this.width = 140,
    this.height = 200,
  });

  final Game game;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: game.image != null
                        ? CachedNetworkImage(
                            imageUrl: game.image!,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[850],
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[850],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[850],
                            child: const Icon(
                              Icons.videogame_asset,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Price / Free badge
                  Positioned(top: 4, left: 4, child: _buildBadge(context)),
                  // Discount percentage
                  if (_discountPercent != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildDiscountBadge(context),
                    ),
                ],
              ),
            ),
            // Title
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const Spacer(),
                    // Rating or genre
                    if (game.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            game.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else if (game.genre != null)
                      Text(
                        game.genre!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
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

  int? get _discountPercent {
    final cut = game.deal?.cut ?? game.priceInfo?.cut;
    if (cut != null && cut > 0) return cut;
    return null;
  }

  Widget _buildBadge(BuildContext context) {
    if (game.isFree == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'مجاني',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (game.deal?.price != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '\$${game.deal!.price!.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (game.status == 'coming_soon') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'قريباً',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDiscountBadge(BuildContext context) {
    final cut = _discountPercent;
    if (cut == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '-$cut%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
