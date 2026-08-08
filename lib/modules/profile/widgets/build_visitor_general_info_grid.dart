import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';

Widget buildVisitorGeneralInfoGrid(
  BuildContext context,
  List<GeneralInfoItem> infoList,
) {
  final cs = Theme.of(context).colorScheme;
  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: infoList
        .map(
          (item) => Container(
            constraints: BoxConstraints(
              minWidth: (MediaQuery.of(context).size.width - 64) / 2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.text,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}
