import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class LoginView extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final globalKey = GlobalKey<FormState>();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: globalKey,
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
                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  controller: emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'يرجى إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'نسيت كلمة السر؟',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                Obx(
                  () => CustomButton(
                    text: 'تسجيل الدخول',
                    onPressed: () {
                      if (globalKey.currentState!.validate()) {
                        controller.login(
                          emailController.text,
                          passwordController.text,
                        );
                      }
                    },
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 20),
                // تسجيل بواسطة جوجل
                Obx(
                  () => CustomButton(
                    icon: SvgPicture.asset(
                      'assets/images/google_icon.svg',
                      width: 20,
                      height: 20,
                    ),
                    text: 'تسجيل بواسطة جوجل',
                    onPressed: () => controller.loginWithGoogle(),
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'ليس لديك حساب؟',
                    //   style: TextStyle(
                    //     color: colorScheme.onSurface.withOpacity(0.7),
                    //   ),
                    // ),
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'إنشاء حساب جديد',
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
      ),
    );
  }
}
