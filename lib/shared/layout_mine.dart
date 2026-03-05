import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/my_app_bar.dart';

class LayoutMine extends StatelessWidget {
  const LayoutMine({super.key, this.body});
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: myAppBar(context),

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: body ?? const SizedBox.shrink(),
      ),
    );
  }
}
