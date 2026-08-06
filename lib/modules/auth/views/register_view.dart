import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/values/app_breakpoints.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final AuthController controller = Get.put(AuthController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();

  // Invitation validation state
  bool _isValidating = false;
  bool _isCodeValid = false;
  String _inviterName = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _validateInviteCode(String code) async {
    if (code.trim().isEmpty) {
      setState(() {
        _isValidating = false;
        _isCodeValid = false;
        _inviterName = '';
      });
      return;
    }

    setState(() => _isValidating = true);

    if (code.trim().length < 3) {
      setState(() {
        _isValidating = false;
        _isCodeValid = false;
      });
      return;
    }

    final result = await controller.validateInviteCode(code.trim());
    if (!mounted) return;

    setState(() {
      _isValidating = false;
      _isCodeValid = result.valid;
      if (result.valid && result.user != null) {
        _inviterName =
            '${result.user!.firstName ?? ''} ${result.user!.lastName ?? ''}'
                .trim();
      } else {
        _inviterName = '';
      }
    });
  }

  void _onInviteCodeChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _validateInviteCode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = context.isDesktop;

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
          child: SizedBox(
            width: isDesktop ? 420 : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo
                SizedBox(
                  width: isDesktop ? 100 : 150,
                  height: isDesktop ? 100 : 150,
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
                const SizedBox(height: 16),

                // ── Invite Code Field (Optional) ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: inviteCodeController,
                      label: 'كود الدعوة (اختياري)',
                      hint: 'أدخل كود الدعوة',
                      prefixIcon: Icons.card_giftcard_outlined,
                      onChanged: _onInviteCodeChanged,
                    ),
                    // Validation feedback
                    if (_isValidating)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'جاري التحقق من الكود...',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!_isValidating &&
                        _isCodeValid &&
                        _inviterName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '✓ تم التحقق — ستنضم إلى فريق $_inviterName',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!_isValidating &&
                        !_isCodeValid &&
                        inviteCodeController.text.trim().isNotEmpty &&
                        inviteCodeController.text.trim().length >= 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'كود الدعوة غير صالح',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

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
                      final inviteCode = inviteCodeController.text.trim();
                      controller.register(
                        usernameController.text,
                        emailController.text,
                        passwordController.text,
                        firstNameController.text,
                        lastNameController.text,
                        inviteCode: inviteCode.isNotEmpty ? inviteCode : null,
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
      ),
    );
  }
}
