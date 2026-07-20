import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/game_model.dart';
import 'package:game_city_app/modules/games/views/game_details_view.dart';

import 'badge.dart';

class GameHero extends StatelessWidget {
  final Game game;

  const GameHero({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (game.image != null)
                CachedNetworkImage(
                  imageUrl: game.image!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                )
              else
                Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.games, size: 80),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (game.title != null)
                      Text(
                        game.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (game.status == 'coming_soon')
                          MyBadge(
                            text: 'قريباً',
                            color: Colors.orange,
                            icon: Icons.timer,
                          )
                        else
                          MyBadge(
                            text: 'متاحة الآن',
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                        if (game.isFree == true)
                          const MyBadge(
                            text: 'مجانية',
                            color: Colors.green,
                            icon: Icons.card_giftcard,
                          ),
                        if (game.store != null)
                          MyBadge(
                            text: game.store!,
                            color: colorScheme.primary,
                            textColor: colorScheme.onPrimary,
                            icon: Icons.store,
                          ),
                        ...?game.sourceTypes
                            ?.where((s) => s.isNotEmpty)
                            .map(
                              (s) => MyBadge(
                                text: sourceName(s),
                                color: colorScheme.surface,
                                icon: Icons.label,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
