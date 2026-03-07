import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class ChangePasswordView extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تغيير كلمة المرور',
          style: TextStyle(color: colorScheme.primary),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                'يرجى إدخال كلمة المرور الحالية ثم الجديدة للتحديث',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CustomTextField(
                controller: oldPasswordController,
                label: 'كلمة المرور الحالية',
                hint: '********',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'يرجى إدخال كلمة المرور الحالية';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: newPasswordController,
                label: 'كلمة المرور الجديدة',
                hint: '********',
                prefixIcon: Icons.lock_reset,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'يرجى إدخال كلمة المرور الجديدة';
                  if (value.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'تأكيد كلمة المرور الجديدة',
                hint: '********',
                prefixIcon: Icons.lock_clock_outlined,
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text)
                    return 'كلمات المرور غير متطابقة';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Obx(
                () => CustomButton(
                  text: 'تحديث كلمة المرور',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.changePassword(
                        oldPassword: oldPasswordController.text,
                        newPassword: newPasswordController.text,
                      );
                    }
                  },
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
