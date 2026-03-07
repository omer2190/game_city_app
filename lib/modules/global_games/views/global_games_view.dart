import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../controllers/global_games_controller.dart';
import '../../profile/controllers/user_play_now_controller.dart';
import '../../../shared/widgets/widgets.dart';

class GlobalGamesView extends StatelessWidget {
  GlobalGamesView({super.key});

  final GlobalGamesController controller = Get.put(GlobalGamesController());
  final UserPlayNowController playNowController = Get.put(
    UserPlayNowController(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Column(
        children: [
          Header(title: 'جميع الألعاب', leading: BackButton()),
          CustomTextField(
            onChanged: (v) => controller.search(v),
            label: 'ابحث عن لعبة...',
            prefixIcon: Icons.search,
          ),
          SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'جاري البحث...');
              }

              if (controller.games.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.onBackground.withOpacity(0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لم نجد هذه اللعبة في مكتبتنا',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.3),
                          fontSize: 16,
                        ),
                      ),
                      if (controller.searchQuery.value.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        CustomButton(
                          onPressed: () => controller.requestGameAddition(),
                          text: 'طلب إضافة اللعبة',
                          icon: Icon(Icons.add_task),
                          type: ButtonType.outline,
                          width: 200,
                        ),
                      ],
                    ],
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!controller.isMoreLoading.value &&
                      controller.hasMore.value &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 100) {
                    controller.fetchGames(isLoadMore: true);
                  }
                  return false;
                },
                child: ListView.builder(
                  // padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      controller.games.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.games.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LoadingWidget(),
                      );
                    }

                    final Game game = Game.fromJson(controller.games[index]);
                    final gameId = game.id ?? '';

                    return Obx(() {
                      final isPlaying = playNowController.isPlaying(gameId);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: game.image ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.gamepad,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game.title ?? 'بدون عنوان',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (game.genres != null &&
                                        game.genres!.isNotEmpty)
                                      Text(
                                        game.genres!.join(', '),
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.4),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (isPlaying) {
                                    playNowController.removeGame(gameId);
                                  } else {
                                    playNowController.addGame(gameId);
                                  }
                                },
                                icon: Icon(
                                  isPlaying
                                      ? Icons.remove_circle_rounded
                                      : Icons.add_circle_rounded,
                                  color: isPlaying
                                      ? Colors.redAccent
                                      : colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
