import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
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

                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.games.length,
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
