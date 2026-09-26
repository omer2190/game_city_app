import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../settings/controllers/settings_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  final controller = Get.put<SettingsController>(SettingsController());

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _fade = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _anim.repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(scale: _scale.value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'assets/images/asset.png',
                    width: Get.width * 0.4,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Game City', style: Get.textTheme.labelSmall),
                  Obx(() {
                    return Text(
                      "version ${controller.appVersion.value.isEmpty ? 'جاري التحميل...' : controller.appVersion.value}",
                      style: Get.textTheme.labelSmall,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
