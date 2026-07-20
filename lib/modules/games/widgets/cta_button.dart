import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/game_model.dart';
import 'package:game_city_app/modules/games/views/game_details_view.dart';

class CtaButton extends StatelessWidget {
  final Game game;
  final VoidCallback onPressed;

  const CtaButton({required this.game, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = game.deal?.url ?? game.url;

    if (url == null || url.isEmpty) return const SizedBox.shrink();

    String label;
    if (game.isFree == true) {
      label = game.freeType == 'permanent'
          ? 'احصل عليها مجاناً'
          : 'احصل عليها مجاناً (لفترة محدودة)';
    } else if (game.deal?.price != null) {
      label = 'شراء الآن بـ \$${formatPrice(game.deal!.price!)}';
    } else {
      label = 'احصل على اللعبة الآن';
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_new, color: Colors.black),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
