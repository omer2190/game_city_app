import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class RegisterView extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('إنشاء حساب', style: TextStyle(color: colorScheme.primary)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset('assets/images/asset.png'),
              ),
              const SizedBox(height: 30),

              // Username Field
              CustomTextField(
                controller: usernameController,
                label: 'اسم المستخدم',
                hint: 'أدخل اسم المستخدم',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // First Name Field
              CustomTextField(
                controller: firstNameController,
                label: 'الاسم الأول',
                hint: 'أدخل الاسم الأول',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),

              // Last Name Field
              CustomTextField(
                controller: lastNameController,
                label: 'الاسم الأخير',
                hint: 'أدخل الاسم الأخير',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),

              // Email Field
              CustomTextField(
                controller: emailController,
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              CustomTextField(
                controller: passwordController,
                label: 'كلمة المرور',
                hint: 'أدخل كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              CustomTextField(
                controller: confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: 'أعد إدخال كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Register Button
              Obx(
                () => CustomButton(
                  text: 'إنشاء حساب',
                  onPressed: () {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      Get.snackbar(
                        'خطأ',
                        'كلمات المرور غير متطابقة',
                        backgroundColor: colorScheme.error,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    controller.register(
                      usernameController.text,
                      emailController.text,
                      passwordController.text,
                      firstNameController.text,
                      lastNameController.text,
                    );
                  },
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 20),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'هل لديك حساب بالفعل؟',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'تسجيل دخول',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // privacy policy link
              TextButton(
                onPressed: () async {
                  const url = 'https://gmaingcity.com/privacy-policy';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    Get.snackbar('خطأ', 'تعذر فتح رابط سياسة الخصوصية');
                  }
                },
                child: Text(
                  'سياسة الخصوصية وشروط الاستخدام',
                  style: TextStyle(color: colorScheme.primary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
