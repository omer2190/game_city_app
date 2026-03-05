import 'package:flutter/material.dart';
import 'package:game_city_app/modules/games/widgets/free_game_details_description.dart';
import 'package:game_city_app/modules/games/widgets/free_game_details_image.dart';
import 'package:game_city_app/modules/games/widgets/free_game_details_info.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/game_model.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class GameDetailsView extends StatelessWidget {
  final Game game;

  GameDetailsView({super.key, required this.game});

  final WishlistController wishlistController = Get.find();

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header(
              title: game.title ?? 'تفاصيل اللعبة',
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              trailing: Obx(() {
                final isInWishlist = wishlistController.isInWishlist(
                  game.id ?? '',
                );
                return IconButton(
                  onPressed: () {
                    if (game.id != null) {
                      wishlistController.toggleWishlist(game.id!);
                    }
                  },
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : null,
                  ),
                );
              }),
            ),
            Column(
              children: [
                FreeGameDetailsImage(imageUrl: game.image),
                FreeGameDetailsInfo(game: game),
                FreeGameDetailsDescription(game: game),
                const SizedBox(height: 20),
                if (game.url != null || game.deal?.url != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _launchUrl(game.deal?.url ?? game.url!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'احصل على اللعبة الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
