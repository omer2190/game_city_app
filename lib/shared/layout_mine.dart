import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/my_app_bar.dart';
import '../core/values/app_breakpoints.dart';
import '../core/values/app_dimensions.dart';

class LayoutMine extends StatelessWidget {
  const LayoutMine({super.key, this.body});
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final isDesktopOrTablet = context.isDesktopOrTablet;
    final hPadding = AppDimensions.horizontalPadding(context);
    final margin = isDesktopOrTablet ? 16.0 : 12.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: myAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 0),
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
        ),
        child: body ?? const SizedBox.shrink(),
      ),
    );
  }
}
