import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';

Widget sectionTitle(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: context.isDesktopOrTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
