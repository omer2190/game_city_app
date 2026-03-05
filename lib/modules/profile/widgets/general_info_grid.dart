import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class GeneralInfoGrid extends StatelessWidget {
  final AuthController authController;
  final List<dynamic> infoList;

  const GeneralInfoGrid({
    super.key,
    required this.authController,
    required this.infoList,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final List<Map<String, dynamic>> allTypes =
          authController.generalInfoTypes;

      // Map user's existing info by their typeId for matching
      final Map<String, dynamic> userFilled = {
        for (var info in infoList) info['typeId']?.toString() ?? '': info,
      };

      // Create a list of all items (filled and available)
      final List<dynamic> allItems = [];

      // Step 1: Add existing user info items
      for (var item in infoList) {
        allItems.add({'isFilled': true, 'data': item});
      }

      // Step 2: Add types that are NOT yet filled
      final filledTypeIds = userFilled.keys.toSet();
      for (var type in allTypes) {
        if (!filledTypeIds.contains(type['_id']?.toString())) {
          allItems.add({'isFilled': false, 'data': type});
        }
      }

      if (allItems.isEmpty) {
        return Text(
          'لا توجد معلومات عامة متاحة حالياً.',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: allItems.map((itemObj) {
            final bool isFilled = itemObj['isFilled'];
            final data = itemObj['data'];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data['title'] ?? data['name'] ?? '',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data['text'] ?? 'لا توجد معلومات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 12,
                    child: isFilled
                        ? IconButton(
                            onPressed: () => _confirmDelete(context, data),
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: colorScheme.error.withOpacity(0.5),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : IconButton(
                            onPressed: () => _showAddDialog(context, data),
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, dynamic data) {
    final colorScheme = Theme.of(context).colorScheme;
    if (data['id'] != null) {
      Get.dialog(
        AlertDialog(
          title: const Text('حذف المعلومة'),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذه المعلومة؟'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                Get.back();
                authController.deleteUserInfo(data['id']);
              },
              child: Text('حذف', style: TextStyle(color: colorScheme.error)),
            ),
          ],
        ),
      );
    }
  }

  void _showAddDialog(BuildContext context, Map<String, dynamic> type) {
    final TextEditingController valueController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إضافة ${type['name']}',
          style: TextStyle(color: colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل ${type['name']}',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: valueController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'اكتب هنا...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.35),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (valueController.text.isNotEmpty) {
                final text = valueController.text;
                // Get.back();
                try {
                  await authController.addUserInfo(
                    type['_id'].toString(),
                    text,
                  );
                } catch (_) {
                  Get.snackbar(
                    'خطأ',
                    'فشل إضافة المعلومة',
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.white,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
