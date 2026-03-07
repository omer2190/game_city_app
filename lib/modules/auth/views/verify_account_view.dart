import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class VerifyAccountView extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController codeController = TextEditingController();
  final String email;

  VerifyAccountView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تفعيل الحساب',
          style: TextStyle(color: colorScheme.primary),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 100,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 30),
            Text('تم إرسال رمز التحقق إلى', style: theme.textTheme.titleMedium),
            Text(
              email,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: codeController,
              label: 'رمز التحقق',
              hint: 'أدخل الرمز المكون من 6 أرقام',
              prefixIcon: Icons.security,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            Obx(
              () => CustomButton(
                text: 'تفعيل الآن',
                onPressed: () {
                  if (codeController.text.length != 6) {
                    Get.snackbar('خطأ', 'يرجى إدخال رمز صحيح مكون من 6 أرقام');
                    return;
                  }
                  controller.verifyAccount(email, codeController.text);
                },
                isLoading: controller.isLoading.value,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Future: Implement resend code if API supports it
                Get.snackbar('تنبيه', 'سيتم إعادة إرسال الرمز قريباً');
              },
              child: const Text('لم يصلك الرمز؟ إعادة إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
