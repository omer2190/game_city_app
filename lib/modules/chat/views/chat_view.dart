import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/modules/community/views/user_profile_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import '../controllers/chat_controller.dart';
import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class ChatView extends StatefulWidget {
  final UserModel recipient;

  const ChatView({super.key, required this.recipient});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController controller = Get.put(ChatController());
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.recipient.chatRoomId != null) {
      controller.listenToMessages(widget.recipient.chatRoomId!);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Get.to(() => UserProfileView(userId: widget.recipient.id ?? ''));
          },
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${widget.recipient.id}',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      (widget.recipient.userImage != null &&
                          widget.recipient.userImage!.isNotEmpty)
                      ? CachedNetworkImageProvider(
                          widget.recipient.userImage![0],
                        )
                      : null,
                  child:
                      (widget.recipient.userImage == null ||
                          widget.recipient.userImage!.isEmpty)
                      ? Text(
                          (widget.recipient.userName ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.primary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.recipient.userName ?? 'محادثة',
                style: TextStyle(color: colorScheme.onBackground, fontSize: 18),
              ),
            ],
          ),
        ),
        backgroundColor: theme.cardColor.withOpacity(0.5),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const LoadingWidget(message: 'جاري تحميل الرسائل...');
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: colorScheme.onBackground.withOpacity(0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد رسائل بعد.\nابدأ المحادثة مع ${widget.recipient.userName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe =
                      message.senderId == authController.userModel.value?.id;

                  return Align(
                    alignment: isMe
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? colorScheme.primary : theme.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(4),
                          topRight: const Radius.circular(4),
                          bottomLeft: Radius.circular(isMe ? 0 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isMe
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                intl.DateFormat(
                                  'HH:mm',
                                ).format(message.dateTime),
                                style: TextStyle(
                                  color:
                                      (isMe
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface)
                                          .withOpacity(0.5),
                                  fontSize: 10,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.read ? Icons.done_all : Icons.done,
                                  size: 14,
                                  color: message.read
                                      ? Colors.greenAccent
                                      : colorScheme.onPrimary.withOpacity(0.5),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: messageController,
                style: TextStyle(color: colorScheme.onSurface),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                final text = messageController.text.trim();
                if (text.isNotEmpty && widget.recipient.id != null) {
                  controller.sendChatMessage(widget.recipient.id!, text);
                  messageController.clear();
                }
              },
              icon: Icon(Icons.send_rounded, color: colorScheme.primary),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
