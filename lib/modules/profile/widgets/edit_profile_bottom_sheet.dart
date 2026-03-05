import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final Map<String, dynamic> user;
  final AuthController authController;

  const EditProfileBottomSheet({
    super.key,
    required this.user,
    required this.authController,
  });

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  late final TextEditingController firstNameCtl;
  late final TextEditingController lastNameCtl;
  late final TextEditingController birthDateCtl;
  late final TextEditingController phoneCtl;
  late String selectedGender;

  @override
  void initState() {
    super.initState();
    firstNameCtl = TextEditingController(text: widget.user['firstName'] ?? '');
    lastNameCtl = TextEditingController(text: widget.user['lastName'] ?? '');
    birthDateCtl = TextEditingController(text: widget.user['birthDate'] ?? '');
    phoneCtl = TextEditingController(text: widget.user['phone'] ?? '');
    selectedGender = widget.user['gender'] ?? 'male';
  }

  @override
  void dispose() {
    firstNameCtl.dispose();
    lastNameCtl.dispose();
    birthDateCtl.dispose();
    phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تعديل الملف الشخصي',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: firstNameCtl,
              label: 'الاسم الأول',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: lastNameCtl,
              label: 'اسم العائلة',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: birthDateCtl.text.isNotEmpty
                      ? DateTime.tryParse(birthDateCtl.text) ?? DateTime(2000)
                      : DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: colorScheme.copyWith(
                          primary: colorScheme.primary,
                          surface: theme.cardColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    birthDateCtl.text = pickedDate.toString().split(' ')[0];
                  });
                }
              },
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: birthDateCtl,
                  label: 'تاريخ الميلاد',
                  prefixIcon: Icons.calendar_today_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'الجنس',
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //     color: colorScheme.onSurface.withOpacity(0.8),
                //   ),
                // ),
                // const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    // border: Border.all(
                    //   color: colorScheme.onSurface.withOpacity(0.1),
                    // ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'male',
                          groupValue: selectedGender,
                          title: Text(
                            'ذكر',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          activeColor: colorScheme.primary,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'female',
                          groupValue: selectedGender,
                          title: Text(
                            'أنثى',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          activeColor: colorScheme.primary,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: phoneCtl,
              label: 'رقم الهاتف',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'حفظ',
                    onPressed: () {
                      widget.authController.updateProfile({
                        'firstName': firstNameCtl.text,
                        'lastName': lastNameCtl.text,
                        'birthDate': birthDateCtl.text,
                        'phone': phoneCtl.text,
                        'gender': selectedGender,
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'إلغاء',
                    type: ButtonType.text,
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void showEditProfileBottomSheet(
  BuildContext context,
  Map<String, dynamic> user,
  AuthController authController,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        EditProfileBottomSheet(user: user, authController: authController),
  );
}
