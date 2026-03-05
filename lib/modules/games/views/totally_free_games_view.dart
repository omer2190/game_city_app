import 'package:flutter/material.dart';
import 'package:game_city_app/modules/games/widgets/game_card.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/totally_free_games_controller.dart';
import '../../../shared/widgets/widgets.dart';

class TotallyFreeGamesView extends StatelessWidget {
  final TotallyFreeGamesController controller = Get.find();

  TotallyFreeGamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchGames(),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(
                  message: 'جاري تحميل الألعاب المجانية تماماً...',
                );
              }
              if (controller.games.isEmpty) {
                return const Center(
                  child: Text('لا توجد ألعاب متوفرة حالياً.'),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.games.length,
                itemBuilder: (context, index) {
                  final game = controller.games[index];
                  return GameCard(
                    id: game.id,
                    title: game.title,
                    image: game.image,
                    platforms: game.platforms,
                    worth: game.worth,
                    price: 'مجاني',
                    onTap: () =>
                        Get.toNamed(AppRoutes.gameDetails, arguments: game),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
