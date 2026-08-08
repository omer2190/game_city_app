import 'package:flutter/material.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/game_model.dart';
import 'game_card.dart';

/// A responsive section with title and game cards.
/// On mobile/tablet: horizontal scroll.
/// On desktop: multi-column grid.
class GameSectionRow extends StatelessWidget {
  const GameSectionRow({
    super.key,
    required this.title,
    required this.games,
    this.onGameTap,
    this.onSeeAll,
  });

  final String title;
  final List<Game> games;
  final void Function(Game game)? onGameTap;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();
    final isDesktop = context.isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Content: grid on desktop, horizontal list on mobile/tablet
        if (isDesktop) _buildGrid(context) else _buildHorizontalList(context),
      ],
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 140,
              child: GameCard(game: game, onTap: () => onGameTap?.call(game)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cols = context.isWide ? 6 : 4;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: games.length.clamp(0, cols * 2),
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(game: game, onTap: () => onGameTap?.call(game));
      },
    );
  }
}
