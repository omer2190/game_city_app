import 'package:flutter/material.dart';
import 'package:game_city_app/modules/profile/widgets/section_title.dart';

class DesktopSection extends StatelessWidget {
  final String title;
  final Widget child;
  const DesktopSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: sectionTitle(title, context),
          ),
        child,
      ],
    );
  }
}
