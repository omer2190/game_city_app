import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../../games/widgets/game_card.dart';
import '../../../routes/app_routes.dart';

class WishlistView extends StatelessWidget {
  WishlistView({super.key});
  final WishlistController controller = Get.put(WishlistController())
    ..fetchWishlist();

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(title: 'قائمة الأمنيات', leading: BackButton()),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchWishlist(),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.wishlist.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد ألعاب في قائمة أمنياتك حاليا',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 16,
                    right: 16,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.wishlist.length,
                  itemBuilder: (context, index) {
                    final entry = controller.wishlist[index];
                    final game = entry.game;
                    return GameCard(
                      id: game.id,
                      title: game.title,
                      image: game.image,
                      platforms: game.platforms,
                      worth: game.worth,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.gameDetails,
                          arguments: {'gameId': game.id},
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
