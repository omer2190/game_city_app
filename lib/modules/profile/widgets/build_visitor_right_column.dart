import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_play_now_section.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

import '../views/desktop/desktop_section.dart';

Widget buildVisitorRightColumn(BuildContext context, UserModel user) {
  final cs = Theme.of(context).colorScheme;
  final hasPlayNow = user.playNow != null && user.playNow!.isNotEmpty;

  return Column(
    children: [
      if (hasPlayNow) ...[
        DesktopSection(
          title: 'يلعب الآن',
          child: buildVisitorPlayNowSection(context, user),
        ),
        const SizedBox(height: 16),
      ] else ...[
        CustomCard(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_esports_outlined,
                size: 40,
                color: cs.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد ألعاب حالياً',
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
