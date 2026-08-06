import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/adaptive_grid_view.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/game_coming_soon_controller.dart';
import '../widgets/coming_soon_card.dart';

class GameComingSoon extends StatelessWidget {
  GameComingSoon({super.key});
  final GameComingSoonController controller = Get.put(
    GameComingSoonController(),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(
            title: 'التقويم',
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => Get.toNamed(AppRoutes.wishlist),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchComingSoon(),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.games.isEmpty) {
                  return const Center(
                    child: Text('لا توجد ألعاب قادمة حالياً'),
                  );
                }

                return AdaptiveGridView(
                  padding: const EdgeInsets.only(bottom: 20),
                  aspectRatio: 0.52,
                  itemCount: controller.games.length,
                  gridColumns: 2,
                  itemBuilder: (context, index) {
                    return ComingSoonCard(game: controller.games[index]);
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
