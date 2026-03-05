import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../global_games/views/global_games_view.dart';

class ProfilePlayNowSection extends StatelessWidget {
  final AuthController authController;

  const ProfilePlayNowSection({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ألعب الآن', style: theme.textTheme.headlineSmall),
              // const SizedBox(width: 10),
              IconButton(
                onPressed: () => Get.to(() => GlobalGamesView()),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Obx(() {
            final rawList = authController.userModel.value?.playNow;
            if (rawList == null || rawList.isEmpty) {
              return CustomCard(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'لم تضف أي ألعاب بعد',
                  style: TextStyle(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final games = (rawList).map((item) {
              if (item is Map<String, dynamic>) {
                return Game.fromJson(item);
              }
              return Game(id: item.toString(), title: 'تحميل...');
            }).toList();

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 14),
                    child: CustomCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: game.image ?? '',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Center(
                                    child: Icon(
                                      Icons.videogame_asset,
                                      size: 40,
                                    ),
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  game.title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
            );
          }),
        ],
      ),
    );
  }
}
