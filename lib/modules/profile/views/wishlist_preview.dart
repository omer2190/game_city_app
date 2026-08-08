import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

class WishlistPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WishlistController wc = Get.find<WishlistController>();
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      if (wc.isLoading.value) {
        return const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      if (wc.wishlist.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'لا توجد ألعاب في قائمة الأمنيات',
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 12, start: 16),
        child: SizedBox(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الأمنيات المفضلة', style: Get.textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: wc.wishlist.length,
                  itemBuilder: (_, i) {
                    final entry = wc.wishlist[i];
                    final game = entry.game;
                    return Container(
                      width: 130,
                      margin: const EdgeInsetsDirectional.only(
                        end: 14,
                        bottom: 4,
                      ),
                      child: CustomCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            // fit: StackFit.expand,
                            children: [
                              game.image != null
                                  ? CachedNetworkImage(
                                      imageUrl: game.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: Colors.white10,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.white10,
                                        child: const Icon(
                                          Icons.videogame_asset,
                                          color: Colors.white30,
                                          size: 40,
                                        ),
                                      ),
                                      height: 150,
                                    )
                                  : Container(
                                      color: Colors.white10,
                                      child: const Icon(
                                        Icons.videogame_asset,
                                        color: Colors.white30,
                                        size: 40,
                                      ),
                                    ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.85),
                                    ],
                                    stops: const [0.45, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Text(
                                  game.title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
