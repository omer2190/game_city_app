import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/game_model.dart';
import 'package:game_city_app/modules/games/views/game_details_view.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

import 'stat_chip.dart';

class QuickStats extends StatelessWidget {
  final Game game;

  const QuickStats({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[];

    if (game.rating != null) {
      stats.add(
        StatChip(
          icon: Icons.star,
          label: 'التقييم',
          value: game.rating!.toStringAsFixed(2),
        ),
      );
    }

    if (game.metacritic != null) {
      stats.add(
        StatChip(
          icon: Icons.score,
          label: 'Metacritic',
          value: '${game.metacritic}',
        ),
      );
    }

    if (game.released != null && tryParseDate(game.released!) != null) {
      stats.add(
        StatChip(
          icon: Icons.calendar_today,
          label: 'تاريخ الإصدار',
          value: formatDate(game.released!),
        ),
      );
    }

    if (game.developer != null && game.developer!.isNotEmpty) {
      stats.add(
        StatChip(icon: Icons.code, label: 'المطور', value: game.developer!),
      );
    }

    if (game.publisher != null && game.publisher!.isNotEmpty) {
      stats.add(
        StatChip(icon: Icons.business, label: 'الناشر', value: game.publisher!),
      );
    }

    if (game.rawgEsrb != null && game.rawgEsrb!['name'] != null) {
      stats.add(
        StatChip(
          icon: Icons.warning_amber,
          label: 'التصنيف العمري',
          value: game.rawgEsrb!['name'].toString(),
        ),
      );
    }

    if (game.rawgPlaytime != null && game.rawgPlaytime! > 0) {
      stats.add(
        StatChip(
          icon: Icons.schedule,
          label: 'مدة اللعب المتوقعة',
          value: '${game.rawgPlaytime} ساعة',
        ),
      );
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      width: double.infinity,
      child: Wrap(spacing: 10, runSpacing: 10, children: stats),
    );
  }
}
