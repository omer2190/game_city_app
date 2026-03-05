import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';

class NewsCategories extends StatelessWidget {
  final NewsController controller;

  const NewsCategories({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child:
            controller.showCategories.value && controller.newsTypes.isNotEmpty
            ? Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.newsTypes.length + 1,
                  itemBuilder: (context, index) {
                    final bool isAll = index == 0;
                    final type = isAll ? null : controller.newsTypes[index - 1];
                    final String title = isAll ? 'الكل' : type!.title ?? '';
                    final String id = isAll ? '' : type!.id!;

                    return _buildCategoryItem(context, title, id);
                  },
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, String id) {
    return Obx(() {
      final isSelected = controller.selectedTypeId.value == id;
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: GestureDetector(
          onTap: () => controller.setCategory(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
