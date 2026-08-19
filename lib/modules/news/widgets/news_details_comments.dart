import 'package:flutter/material.dart';
import 'package:game_city_app/modules/community/views/user_profile_view.dart'
    show UserProfileView;
import 'package:get/get.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/comments.dart';
import '../controllers/news_details_controller.dart';
import '../../../shared/widgets/widgets.dart';

class NewsDetailsComments extends StatelessWidget {
  final String newsId;
  final NewsDetailsController controller;
  final TextEditingController commentController;

  const NewsDetailsComments({
    super.key,
    required this.newsId,
    required this.controller,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;

    final commentsContent = Obx(() {
      if (controller.isLoadingComments.value) {
        return const Center(
          child: LoadingWidget(message: 'جاري تحميل التعليقات...'),
        );
      }
      if (controller.comments.isEmpty) {
        return CustomCard(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'كن أول من يعلق!',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 16),
        itemCount: controller.comments.length,
        itemBuilder: (context, index) {
          final Comments comment = controller.comments[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isDesktop) {
                        Get.dialog(
                          UserProfileView(
                            userId: comment.userId!.id ?? '',
                            heroTag: 'avatar_${comment.userId!.id}',
                          ),
                        );
                      } else {
                        Get.to(
                          () => UserProfileView(userId: comment.userId!.id!),
                        );
                      }
                    },
                    child: SafeCachedAvatar(
                      user: comment.userId!,
                      radius: 20,
                      backgroundColor: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "${comment.userId?.firstName ?? 'مستخدم'} ${comment.userId?.lastName ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (controller.isMyComment(comment.userId?.id))
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, comment.id!),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content ?? '',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) SizedBox(height: isDesktop ? 28 : 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 16),
          child: Text(
            'التعليقات',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // On desktop: Expanded makes the list scrollable within bounded height.
        // On mobile: flexible height inside the page scroll.
        if (isDesktop) Expanded(child: commentsContent) else commentsContent,
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 16),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: commentController,
                  label: 'أضف تعليقاً...',
                  prefixIcon: Icons.comment_outlined,
                  hintColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: colorScheme.primary),
                  onPressed: () {
                    final text = commentController.text.trim();
                    if (text.isNotEmpty) {
                      controller.addComment(newsId, text);
                      commentController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String commentId) {
    Get.defaultDialog(
      title: 'حذف التعليق',
      middleText: 'هل أنت متأكد من حذف هذا التعليق؟',
      textConfirm: 'نعم، احذف',
      textCancel: 'إلغاء',
      cancelTextColor: Colors.white,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteComment(newsId, commentId);
        Get.back();
      },
    );
  }
}
