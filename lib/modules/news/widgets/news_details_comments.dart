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
      final threads = controller.commentThreads;
      if (threads.isEmpty) {
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
        itemCount: threads.length,
        itemBuilder: (context, index) {
          return _CommentNodeWidget(
            newsId: newsId,
            controller: controller,
            node: threads[index],
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
        // Reply banner shown while replying to a comment.
        Obx(() {
          if (controller.replyingTo.value == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الرد على ${controller.replyingToName.value ?? ''}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: controller.clearReplyingTo,
                  ),
                ],
              ),
            ),
          );
        }),
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
}

class _CommentNodeWidget extends StatelessWidget {
  final String newsId;
  final NewsDetailsController controller;
  final CommentNode node;
  final bool isReply;

  const _CommentNodeWidget({
    required this.newsId,
    required this.controller,
    required this.node,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentItem(
          newsId: newsId,
          controller: controller,
          comment: node.comment,
          isReply: isReply,
        ),
        if (node.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: node.replies
                  .map(
                    (reply) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CommentNodeWidget(
                        newsId: newsId,
                        controller: controller,
                        node: reply,
                        isReply: true,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final String newsId;
  final NewsDetailsController controller;
  final Comments comment;
  final bool isReply;

  const _CommentItem({
    required this.newsId,
    required this.controller,
    required this.comment,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomCard(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(isReply ? 10 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (context.isDesktop) {
                Get.dialog(
                  UserProfileView(
                    userId: comment.userId!.id ?? '',
                    heroTag: 'avatar_${comment.userId!.id}',
                  ),
                );
              } else {
                Get.to(() => UserProfileView(userId: comment.userId!.id!));
              }
            },
            child: SafeCachedAvatar(
              user: comment.userId!,
              radius: isReply ? 16 : 20,
              backgroundColor: colorScheme.secondary,
              borderColor: colorScheme.secondary,
              borderWidth: isReply ? 3 : 2,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => controller.setReplyingTo(comment),
                          icon: const Icon(Icons.reply_rounded, size: 14),
                          label: const Text(
                            'رد',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        if (controller.isMyComment(comment.userId?.id))
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
