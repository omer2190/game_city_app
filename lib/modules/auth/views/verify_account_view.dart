import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/values/app_breakpoints.dart';
import '../controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class VerifyAccountView extends StatefulWidget {
  final String email;

  const VerifyAccountView({super.key, required this.email});

  @override
  State<VerifyAccountView> createState() => _VerifyAccountViewState();
}

class _VerifyAccountViewState extends State<VerifyAccountView> {
  final AuthController controller = Get.find<AuthController>();
  String _code = '';

  // Resend cooldown timer
  static const int _cooldownSeconds = 60;
  Timer? _resendTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    setState(() => _remainingSeconds = _cooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  void _resendCode() {
    if (_remainingSeconds > 0) return;
    controller.resendVerificationCode(widget.email);
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   title: Text(
      //     'تفعيل الحساب',
      //     style: TextStyle(color: colorScheme.primary),
      //   ),
      //   backgroundColor: theme.scaffoldBackgroundColor,
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: colorScheme.onSurface),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(children: [BackButton()]),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: isDesktop ? 420 : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isDesktop ? 100 : 150,
                        child: SvgPicture.asset('assets/images/asset34.svg'),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        'تم إرسال رمز التحقق إلى',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        widget.email,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      OtpField(
                        length: 6,
                        onChanged: (value) => _code = value,
                        onCompleted: (value) {
                          _code = value;
                          controller.verifyAccount(widget.email, value);
                        },
                      ),
                      const SizedBox(height: 30),
                      Obx(
                        () => CustomButton(
                          text: 'تفعيل الآن',
                          onPressed: () {
                            if (_code.length != 6) {
                              Get.snackbar(
                                'خطأ',
                                'يرجى إدخال رمز صحيح مكون من 6 أرقام',
                              );
                              return;
                            }
                            controller.verifyAccount(widget.email, _code);
                          },
                          isLoading: controller.isLoading.value,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _remainingSeconds > 0 ? null : _resendCode,
                        child: Text(
                          _remainingSeconds > 0
                              ? 'إعادة إرسال الرمز بعد $_remainingSeconds ثانية'
                              : 'لم يصلك الرمز؟ إعادة إرسال',
                          style: TextStyle(
                            color: _remainingSeconds > 0
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
