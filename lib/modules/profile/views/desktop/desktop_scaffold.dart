import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopScaffold extends StatelessWidget {
  final Widget child;
  const DesktopScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.88;
    const maxWidth = 780.0;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: () => Get.back(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
