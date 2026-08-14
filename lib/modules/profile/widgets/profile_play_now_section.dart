import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../../global_games/views/global_games_view.dart';
import '../../installed_games/views/installed_games_view.dart';

class ProfilePlayNowSection extends StatelessWidget {
  final List<dynamic> playNow;

  const ProfilePlayNowSection({super.key, required this.playNow});

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
              IconButton(
                onPressed: () => Get.to(() => GlobalGamesView()),
                tooltip: 'إضافة لعبة من المكتبة',
                icon: Icon(
                  Icons.add_circle_outline,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => Get.to(() => InstalledGamesView()),
                tooltip: 'استيراد الألعاب المثبتة على جهازك',
                icon: Icon(
                  Icons.download_for_offline_outlined,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildPlayNowContent(),
        ],
      ),
    );
  }

  Widget _buildPlayNowContent() {
    if (playNow.isEmpty) {
      return CustomCard(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Text(
          'لم تضف أي ألعاب بعد',
          style: TextStyle(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final games = playNow.map((item) {
      if (item is Map<String, dynamic>) {
        return Game.fromJson(item);
      }
      return Game(id: item.toString(), title: 'تحميل...');
    }).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 130,
            margin: const EdgeInsetsDirectional.only(start: 14),
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
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.videogame_asset, size: 40),
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
  }
}
