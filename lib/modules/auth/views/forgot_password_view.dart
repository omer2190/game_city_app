import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class ForgotPasswordView extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'نسيت كلمة السر',
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
            Icon(Icons.lock_reset, size: 100, color: colorScheme.primary),
            const SizedBox(height: 30),
            Text(
              'أدخل بريدك الإلكتروني لاستلام رمز إعادة التعيين',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: emailController,
              label: 'البريد الإلكتروني',
              hint: 'user@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            Obx(
              () => CustomButton(
                text: 'إرسال الرمز',
                onPressed: () {
                  if (!GetUtils.isEmail(emailController.text)) {
                    Get.snackbar('خطأ', 'يرجى إدخال بريد إلكتروني صحيح');
                    return;
                  }
                  controller.forgotPassword(emailController.text);
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
