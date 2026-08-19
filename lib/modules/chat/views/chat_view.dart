import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_city_app/modules/community/views/user_profile_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/values/app_breakpoints.dart';
import '../controllers/chat_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/message_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class ChatView extends StatefulWidget {
  final UserModel recipient;

  /// When true, chat renders without its own Scaffold — usable in split panels.
  final bool embedded;

  /// Callback to close/dismiss the embedded chat (back to list).
  final VoidCallback? embeddedOnClose;

  const ChatView({
    super.key,
    required this.recipient,
    this.embedded = false,
    this.embeddedOnClose,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final String _instanceTag;
  late final ChatController controller;
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Rx<String?> editingMessageId = Rx<String?>(null);
  int _previousMsgCount = 0;

  @override
  void initState() {
    super.initState();
    // Tag each controller per recipient so switching friends creates a fresh instance.
    _instanceTag = 'chat_${widget.recipient.id ?? 'new'}';
    if (Get.isRegistered<ChatController>(tag: _instanceTag)) {
      Get.delete<ChatController>(tag: _instanceTag, force: true);
    }
    controller = Get.put(ChatController(), tag: _instanceTag);
    _initChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    // Clean up this chat's controller when the view is removed
    if (Get.isRegistered<ChatController>(tag: _instanceTag)) {
      Get.delete<ChatController>(tag: _instanceTag, force: true);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipient.id != widget.recipient.id) {
      _previousMsgCount = 0; // reset for new conversation
      _initChat();
    }
  }

  void _initChat() {
    if (widget.recipient.chatRoomId != null) {
      controller.listenToMessages(widget.recipient.chatRoomId!);
    }
    debugPrint(
      'ChatView initialized for: ${widget.recipient.userName} (ID: ${widget.recipient.id})',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Embedded mode: compact header + body, no Scaffold
    if (widget.embedded) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor.withAlpha(127),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.onSurface.withAlpha(25),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'إغلاق المحادثة',
                  onPressed: widget.embeddedOnClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                SafeCachedAvatar(
                  user: widget.recipient,
                  radius: 16,
                  backgroundColor: colorScheme.primary.withAlpha(25),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.recipient.userName ?? 'مجهول',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBodyContent(context, theme, colorScheme)),
        ],
      );
    }

    // Full-screen mode
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
              if (Get.width > AppBreakpoints.mobileBreakpoint) {
                Get.dialog(
                  UserProfileView(
                    userId: widget.recipient.id ?? '',
                    heroTag: 'avatar_${widget.recipient.id}',
                  ),
                );
              } else {
                Get.to(() => UserProfileView(userId: widget.recipient.id!));
              }
            },
            child: Row(
              children: [
                Hero(
                  tag: 'chat_avatar_${widget.recipient.id}',
                  child: SafeCachedAvatar(
                    user: widget.recipient,
                    radius: 18,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.recipient.userName ?? 'مجهول',
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
                ),
              ],
            ),
          ),
          backgroundColor: theme.cardColor.withOpacity(0.5),
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
        ),
        body: _buildBodyContent(context, theme, colorScheme),
      ),
    );
  }

  /// Extracted body: messages list + input area — shared by both modes.
  Widget _buildBodyContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
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
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد رسائل بعد.\nابدأ المحادثة الآن!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Smart auto-scroll:
            // - On initial load (_previousMsgCount == 0), always scroll to bottom.
            // - On new message, only scroll if user is already near the bottom.
            final previousMsgCount = _previousMsgCount;
            final isNewMessage = controller.messages.length > previousMsgCount;
            final isInitialLoad = previousMsgCount == 0;
            _previousMsgCount = controller.messages.length;

            if (isNewMessage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  final pos = _scrollController.position;
                  final isNearBottom = pos.pixels >= pos.maxScrollExtent - 200;
                  if (isInitialLoad || isNearBottom) {
                    _scrollController.animateTo(
                      pos.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                }
              });
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    onLongPress: () => _showMessageOptions(context, message),
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
                                anchors: editableTextState.contextMenuAnchors,
                                buttonItems: [
                                  ...editableTextState.contextMenuButtonItems,
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
                  ),
                );
              },
            );
          }),
        ),
        _buildInputArea(context),
      ],
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
                            chatRoomId: widget.recipient.chatRoomId,
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
                        controller.sendChatMessage(
                          widget.recipient.id!,
                          text,
                          chatRoomId: widget.recipient.chatRoomId,
                        );
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
