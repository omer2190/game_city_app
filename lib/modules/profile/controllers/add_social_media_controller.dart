import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class AddSocialMediaController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var services = <SocialMediaService>[].obs;
  var selectedService = Rxn<SocialMediaService>();
  final TextEditingController usernameController = TextEditingController();

  AddSocialMediaController({SocialMediaService? initialService}) {
    if (initialService != null) {
      selectedService.value = initialService;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  void fetchServices() async {
    try {
      isLoading.value = true;
      final response = await authController.getSocialMediaServices();
      services.value = response
          .map((e) => SocialMediaService.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب الخدمات المتاحة: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void submit() async {
    if (selectedService.value == null || usernameController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يجب اختيار خدمة وإدخال الرابط');
      return;
    }

    try {
      isLoading.value = true;
      await authController.addSocialMediaLink(
        selectedService.value!.id,
        usernameController.text,
      );

      await authController.refreshProfile();
      Get.back();
      Get.snackbar('نجاح', 'تم إضافة الرابط بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة الرابط: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }
}
