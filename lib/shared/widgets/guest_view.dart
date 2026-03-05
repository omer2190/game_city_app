import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'widgets.dart';

class GuestView extends StatelessWidget {
  final String message;

  const GuestView({
    super.key,
    this.message = 'يرجى تسجيل الدخول أولاً لتتمكن من الوصول لجميع الميزات',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'login_logo',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(0.1),
                ),
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 100,
                  height: 100,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'مرحباً بك في مدينة الألعاب',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            CustomButton(
              text: 'إنشاء حساب جديد',
              onPressed: () => Get.toNamed('/register'),
              width: double.infinity,
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: 'تسجيل دخول',
              type: ButtonType.outline,
              onPressed: () => Get.toNamed('/login'),
              width: double.infinity,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
