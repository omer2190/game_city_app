import 'package:flutter/material.dart';
import 'package:game_city_app/modules/community/views/user_profile_view.dart'
    show UserProfileView;
import 'package:get/get.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'التعليقات',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
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
                child: Text(
                  'كن أول من يعلق!',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                          onTap: () => Get.to(
                            () => UserProfileView(userId: comment.userId!.id!),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.secondary,
                            child: comment.userId!.userImage!.isEmpty
                                ? Text(
                                    (comment.userId?.firstName ?? 'U')[0]
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(
                                      comment.userId!.userImage!.first,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${comment.userId?.firstName ?? 'مستخدم'} ${comment.userId?.lastName ?? ''}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (controller.isMyComment(
                                    comment.userId?.id,
                                  ))
                                    Row(
                                      children: [
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => _confirmDelete(
                                            context,
                                            comment.id!,
                                          ),
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
            ),
          );
        }),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SizedBox(height: 40),
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
