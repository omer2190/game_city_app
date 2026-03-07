import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_city_app/modules/community/views/user_profile_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import '../controllers/chat_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/message_model.dart';
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
  final Rx<String?> editingMessageId = Rx<String?>(null);

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

    return Theme(
      data: theme.copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: colorScheme.primary.withOpacity(0.4),
          selectionHandleColor: colorScheme.primary,
          cursorColor: colorScheme.primary,
        ),
      ),
      child: Scaffold(
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
                  widget.recipient.userName ?? 'مجهول',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 18,
                  ),
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
                  return const LoadingWidget(message: 'جاري التحميل...');
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
                          'لا توجد رسائل بعد.\nابدأ المحادثة الآن!',
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
                      child: GestureDetector(
                        onLongPress: () =>
                            _showMessageOptions(context, message),
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
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 4 : 16),
                              bottomRight: Radius.circular(isMe ? 16 : 4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                message.content,
                                style: TextStyle(
                                  color: isMe
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                                contextMenuBuilder: (context, editableTextState) {
                                  return AdaptiveTextSelectionToolbar.buttonItems(
                                    anchors:
                                        editableTextState.contextMenuAnchors,
                                    buttonItems: [
                                      ...editableTextState
                                          .contextMenuButtonItems,
                                      if (isMe) ...[
                                        ContextMenuButtonItem(
                                          label: 'تعديل',
                                          onPressed: () {
                                            editingMessageId.value = message.id;
                                            messageController.text =
                                                message.content;
                                            editableTextState.hideToolbar();
                                          },
                                        ),
                                        ContextMenuButtonItem(
                                          label: 'حذف',
                                          onPressed: () {
                                            _showDeleteConfirmation(message.id);
                                            editableTextState.hideToolbar();
                                          },
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (message.isEdited) ...[
                                    Text(
                                      '(تم تعديله)',
                                      style: TextStyle(
                                        color:
                                            (isMe
                                                    ? colorScheme.onPrimary
                                                    : colorScheme.onSurface)
                                                .withOpacity(0.4),
                                        fontSize: 9,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
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
                                      message.read
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: 14,
                                      color: message.read
                                          ? Colors.greenAccent
                                          : colorScheme.onPrimary.withOpacity(
                                              0.5,
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
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
      ),
    );
  }

  void _showMessageOptions(BuildContext context, MessageModel message) {
    final isMe = message.senderId == authController.userModel.value?.id;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (isMe) ...[
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                  title: const Text('تعديل الرسالة'),
                  onTap: () {
                    Navigator.pop(context);
                    editingMessageId.value = message.id;
                    messageController.text = message.content;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('حذف الرسالة'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(message.id);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.green),
                title: const Text('نسخ الرسالة'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message.content));
                  Get.snackbar(
                    'تم النسخ',
                    'تم نسخ الرسالة إلى الحافظة',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSocialMediaLinks(BuildContext context) {
    final socialMedia = authController.userModel.value?.socialMedia ?? [];

    if (socialMedia.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لم تقم بإضافة أي حسابات تواصل اجتماعي بعد.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.white,
      );
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'أرسل حسابك للتواصل الاجتماعي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: socialMedia.length,
                  itemBuilder: (context, index) {
                    final service = socialMedia[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          service.name != null && service.name!.isNotEmpty
                              ? service.name![0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(service.name ?? 'حساب'),
                      subtitle: Text(
                        service.value ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.recipient.id != null) {
                          final message =
                              'حسابي على ${service.name}:\n${service.value}';
                          controller.sendChatMessage(
                            widget.recipient.id!,
                            message,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String messageId) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الرسالة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              if (widget.recipient.chatRoomId != null) {
                controller.deleteMessage(
                  widget.recipient.chatRoomId!,
                  messageId,
                );
              }
              Get.back();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Obx(
              () => editingMessageId.value != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'تعديل الرسالة...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              editingMessageId.value = null;
                              messageController.clear();
                            },
                            icon: const Icon(Icons.close_rounded, size: 16),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _showSocialMediaLinks(context),
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.blue,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 8),
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
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
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
                Obx(
                  () => IconButton(
                    onPressed: () {
                      final text = messageController.text.trim();
                      if (text.isEmpty) return;

                      if (editingMessageId.value != null) {
                        if (widget.recipient.chatRoomId != null) {
                          controller.updateMessage(
                            widget.recipient.chatRoomId!,
                            editingMessageId.value!,
                            text,
                          );
                        }
                        editingMessageId.value = null;
                        messageController.clear();
                      } else if (widget.recipient.id != null) {
                        controller.sendChatMessage(widget.recipient.id!, text);
                        messageController.clear();
                      }
                    },
                    icon: Icon(
                      editingMessageId.value != null
                          ? Icons.check_rounded
                          : Icons.send_rounded,
                      color: colorScheme.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
