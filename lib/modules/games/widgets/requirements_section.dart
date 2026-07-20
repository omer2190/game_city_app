import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

class RequirementsSection extends StatelessWidget {
  final List<dynamic> requirements;

  const RequirementsSection({super.key, required this.requirements});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final cards = requirements
        .whereType<Map<String, dynamic>>()
        .map((req) {
          final platform = req['platform']?.toString() ?? 'PC';
          final minimum = req['minimum']?.toString();
          final recommended = req['recommended']?.toString();

          if ((minimum == null || minimum.isEmpty) &&
              (recommended == null || recommended.isEmpty)) {
            return null;
          }

          return SizedBox(
            width: 280,
            height: 340,
            child: CustomCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsetsDirectional.only(end: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.desktop_windows,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          platform,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (minimum != null && minimum.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'الحد الأدنى',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              minimum,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                          if (recommended != null &&
                              recommended.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'الموصى به',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommended,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        })
        .whereType<Widget>()
        .toList();

    if (cards.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (_, i) => cards[i],
      ),
    );
  }
}
