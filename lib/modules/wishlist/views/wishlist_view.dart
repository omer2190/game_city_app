import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/core/values/app_dimensions.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/adaptive_grid_view.dart';
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
    final cols = AppDimensions.gameGridCrossAxisCount(context);

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

                return AdaptiveGridView(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 16,
                    right: 16,
                  ),
                  aspectRatio: 0.65,
                  itemCount: controller.wishlist.length,
                  gridColumns: cols,
                  itemBuilder: (context, index) {
                    final entry = controller.wishlist[index];
                    final game = entry.game;
                    return GameCard(
                      game: game,
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
