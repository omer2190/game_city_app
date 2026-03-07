import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class ResetPasswordView extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final String email;

  ResetPasswordView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'إعادة تعيين كلمة السر',
          style: TextStyle(color: colorScheme.primary),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'تم إرسال الرمز لبريدك الإلكتروني، يرجى إدخاله مع كلمة المرور الجديدة',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: codeController,
              label: 'الرمز (6 أرقام)',
              hint: '123456',
              prefixIcon: Icons.security,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              label: 'كلمة المرور الجديدة',
              hint: 'أدخل كلمة المرور الجديدة',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              hint: 'أعد إدخال كلمة المرور',
              prefixIcon: Icons.lock_clock_outlined,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            Obx(
              () => CustomButton(
                text: 'تغيير كلمة السر',
                onPressed: () {
                  if (codeController.text.length != 6) {
                    Get.snackbar('خطأ', 'الرمز يجب أن يكون 6 أرقام');
                    return;
                  }
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    Get.snackbar('خطأ', 'كلمات المرور غير متطابقة');
                    return;
                  }
                  controller.resetPassword(
                    email,
                    codeController.text,
                    passwordController.text,
                  );
                },
                isLoading: controller.isLoading.value,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
