import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();

  Timer? _debounceTimer;

  // Terms agreement state
  bool _isAgreedToTerms = false;

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

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://gmaingcity.com/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('خطأ', 'تعذر فتح رابط سياسة الخصوصية');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = context.isDesktop;

    return Scaffold(
      // appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: isDesktop ? 420 : null,
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(),
                // Logo
                Center(
                  child: SizedBox(
                    width: isDesktop ? 100 : 150,
                    child: SvgPicture.asset('assets/images/asset34.svg'),
                  ),
                ),
                const SizedBox(height: 30),

                Text("انشاء حساب", style: Get.textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  "انشاء حسابك و ابداء رحلتك في عالم الألعاب!  وخلك دائمًا أول من يعرف آخر الأخبار، أقوى العروض، وأفضل التخفيضات.",
                  style: Get.textTheme.labelSmall,
                ),
                const SizedBox(height: 20),

                // First Name Field
                CustomTextField(
                  controller: firstNameController,
                  label: 'الاسم الأول',
                  hint: 'أدخل الاسم الأول',
                  prefixIcon: Icons.badge_outlined,
                  // maxLength: 30,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال الاسم الأول';
                    }
                    if (value.trim().length > 30) {
                      return 'الاسم الأول يجب ألا يتجاوز 30 حرفاً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name Field
                CustomTextField(
                  controller: lastNameController,
                  label: 'الاسم الأخير',
                  hint: 'أدخل الاسم الأخير',
                  prefixIcon: Icons.badge_outlined,
                  // maxLength: 30,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال الاسم الأخير';
                    }
                    if (value.trim().length > 30) {
                      return 'الاسم الأخير يجب ألا يتجاوز 30 حرفاً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username Field
                CustomTextField(
                  controller: usernameController,
                  label: 'اسم المستخدم',
                  hint: 'أدخل اسم المستخدم',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  controller: emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
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
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  controller: confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (value != passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // // ── Invite Code Field (Optional) ──
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     CustomTextField(
                //       controller: inviteCodeController,
                //       label: 'كود الدعوة (اختياري)',
                //       hint: 'أدخل كود الدعوة',
                //       prefixIcon: Icons.card_giftcard_outlined,
                //       onChanged: _onInviteCodeChanged,
                //     ),
                //     // Validation feedback
                //     if (_isValidating)
                //       Padding(
                //         padding: const EdgeInsets.only(top: 8, right: 12),
                //         child: Row(
                //           children: [
                //             SizedBox(
                //               width: 14,
                //               height: 14,
                //               child: CircularProgressIndicator(
                //                 strokeWidth: 2,
                //                 valueColor: AlwaysStoppedAnimation<Color>(
                //                   colorScheme.primary,
                //                 ),
                //               ),
                //             ),
                //             const SizedBox(width: 8),
                //             Text(
                //               'جاري التحقق من الكود...',
                //               style: TextStyle(
                //                 color: colorScheme.onSurfaceVariant,
                //                 fontSize: 12,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     if (!_isValidating &&
                //         _isCodeValid &&
                //         _inviterName.isNotEmpty)
                //       Padding(
                //         padding: const EdgeInsets.only(top: 8, right: 12),
                //         child: Row(
                //           children: [
                //             Icon(
                //               Icons.check_circle,
                //               color: Colors.green,
                //               size: 18,
                //             ),
                //             const SizedBox(width: 6),
                //             Expanded(
                //               child: Text(
                //                 '✓ تم التحقق — ستنضم إلى فريق $_inviterName',
                //                 style: TextStyle(
                //                   color: Colors.green,
                //                   fontSize: 13,
                //                   fontWeight: FontWeight.w500,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     if (!_isValidating &&
                //         !_isCodeValid &&
                //         inviteCodeController.text.trim().isNotEmpty &&
                //         inviteCodeController.text.trim().length >= 3)
                //       Padding(
                //         padding: const EdgeInsets.only(top: 8, right: 12),
                //         child: Row(
                //           children: [
                //             Icon(
                //               Icons.error_outline,
                //               color: colorScheme.error,
                //               size: 18,
                //             ),
                //             const SizedBox(width: 6),
                //             Text(
                //               'كود الدعوة غير صالح',
                //               style: TextStyle(
                //                 color: colorScheme.error,
                //                 fontSize: 13,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //   ],
                // ),
                // const SizedBox(height: 24),

                // Terms & Privacy agreement checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isAgreedToTerms,
                      onChanged: (value) {
                        setState(() => _isAgreedToTerms = value ?? false);
                      },
                      activeColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text.rich(
                          TextSpan(
                            text: 'أوافق على ',
                            children: [
                              TextSpan(
                                text: 'شروط الاستخدام',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openPrivacyPolicy,
                              ),
                              const TextSpan(text: ' و '),
                              TextSpan(
                                text: 'سياسة الخصوصية',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openPrivacyPolicy,
                              ),
                            ],
                          ),
                          style: Get.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Register Button
                Obx(
                  () => CustomButton(
                    text: 'إنشاء حساب',
                    onPressed: () {
                      if (!_isAgreedToTerms) {
                        Get.snackbar(
                          'تنبيه',
                          'يجب الموافقة على شروط الاستخدام وسياسة الخصوصية أولاً',
                          backgroundColor: colorScheme.error,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      if (!_formKey.currentState!.validate()) {
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
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'اذا كان لديك حساب, ',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
