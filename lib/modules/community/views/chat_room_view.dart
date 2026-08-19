import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:get/get.dart';
import '../../../core/values/app_breakpoints.dart';
import '../controllers/chat_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/notification_service.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'user_profile_view.dart';

class ChatRoomView extends StatefulWidget {
  final String roomId;
  final String roomName;

  /// When true, renders without its own Scaffold — usable in split panels.
  final bool embedded;

  /// Callback to close/dismiss the embedded chat (back to list).
  final VoidCallback? embeddedOnClose;

  const ChatRoomView({
    super.key,
    required this.roomId,
    required this.roomName,
    this.embedded = false,
    this.embeddedOnClose,
  });

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  late final ChatController controller;
  late final AuthController authController;
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Rx<String?> editingMessageId = Rx<String?>(null);
  int _previousMsgCount = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatController(roomId: widget.roomId));
    authController = Get.find<AuthController>();
    // Track this room as active for notification filtering
    NotificationService.activeRoomIds.add(widget.roomId);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scroll.dispose();
    // Remove this room from active tracking
    NotificationService.activeRoomIds.remove(widget.roomId);
    Get.delete<ChatController>();
    super.dispose();
  }

  void _send() async {
    final txt = _textCtrl.text.trim();
    if (txt.isEmpty) return;
    try {
      await controller.sendMessage(txt);
      _textCtrl.clear();
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل ارسال الرسالة',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final body = Column(
      children: [
        // Embedded header
        if (widget.embedded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.onSurface.withOpacity(0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.roomName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.embeddedOnClose != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: widget.embeddedOnClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        Expanded(
          child: Obx(() {
            final msgs = controller.messages;
            if (msgs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد رسائل بعد.\nابدأ المحادثة الآن!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.3),
                        height: 1.5,
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
            final isNewMessage = msgs.length > previousMsgCount;
            final isInitialLoad = previousMsgCount == 0;
            _previousMsgCount = msgs.length;

            if (isNewMessage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) {
                  final pos = _scroll.position;
                  final isNearBottom = pos.pixels >= pos.maxScrollExtent - 200;
                  if (isInitialLoad || isNearBottom) {
                    _scroll.animateTo(
                      pos.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                }
              });
            }

            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: msgs.length,
              itemBuilder: (ctx, i) {
                final m = msgs[i];
                final content = m['text'] ?? '';
                final name = m['name'] ?? 'مجهول';
                final userImage = m['userImage'] ?? '';
                // final createdAt = m['createdAt'];
                final senderId = m['senderId'];
                final isMe = senderId == authController.userModel.value?.id;

                // if (createdAt != null) {
                //   final date = DateTime.fromMillisecondsSinceEpoch(
                //     int.tryParse(createdAt.toString()) ?? 0,
                //   );
                // }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onLongPress: () =>
                        _showMessageOptions(context, m['id'], content, isMe),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          _buildAvatar(userImage, name, senderId, colorScheme),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 4,
                                    left: 4,
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? colorScheme.primary
                                      : theme.cardColor,
                                  borderRadius: BorderRadiusDirectional.only(
                                    topStart: const Radius.circular(16),
                                    topEnd: const Radius.circular(16),
                                    bottomStart: Radius.circular(isMe ? 0 : 16),
                                    bottomEnd: Radius.circular(isMe ? 16 : 0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: SelectableText(
                                  content,
                                  style: TextStyle(
                                    color: isMe
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: isMe
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    height: 1.3,
                                  ),
                                  onTap: () {
                                    // Standard tap
                                  },
                                  contextMenuBuilder: (context, editableTextState) {
                                    return AdaptiveTextSelectionToolbar.buttonItems(
                                      anchors:
                                          editableTextState.contextMenuAnchors,
                                      buttonItems: [
                                        ...editableTextState
                                            .contextMenuButtonItems,
                                        if (isMe && m['id'] != null) ...[
                                          ContextMenuButtonItem(
                                            label: 'تعديل',
                                            onPressed: () {
                                              editingMessageId.value = m['id'];
                                              _textCtrl.text = content;
                                              editableTextState.hideToolbar();
                                            },
                                          ),
                                          ContextMenuButtonItem(
                                            label: 'حذف',
                                            onPressed: () {
                                              _showDeleteConfirmation(m['id']);
                                              editableTextState.hideToolbar();
                                            },
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                              if (m['isEdited'] == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'معدلة',
                                  style: TextStyle(
                                    color:
                                        (isMe
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface)
                                            .withOpacity(0.4),
                                    fontSize: 8,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isMe) const SizedBox(width: 4),
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
    );

    // ── Embedded mode: return body directly ─────────────────────
    if (widget.embedded) {
      return Theme(
        data: theme.copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: colorScheme.primary.withOpacity(0.4),
            selectionHandleColor: colorScheme.primary,
            cursorColor: colorScheme.primary,
          ),
        ),
        child: body,
      );
    }

    // ── Full-screen mode: wrap in Scaffold ──────────────────────
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
          title: Text(widget.roomName),
          backgroundColor: theme.cardColor.withOpacity(0.5),
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: body,
      ),
    );
  }

  void _showMessageOptions(
    BuildContext context,
    String? messageId,
    String content,
    bool isMe,
  ) {
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
              if (isMe && messageId != null) ...[
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                  title: const Text('تعديل الرسالة'),
                  onTap: () {
                    Navigator.pop(context);
                    editingMessageId.value = messageId;
                    _textCtrl.text = content;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('حذف الرسالة'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(messageId);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.green),
                title: const Text('نسخ النص'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: content));
                  Get.snackbar(
                    'تم النسخ',
                    'تم نسخ نص الرسالة إلى الحافظة',
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

  void _showDeleteConfirmation(String messageId) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الرسالة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteMessage(messageId);
                Get.back();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل حذف الرسالة');
              }
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

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(color: colorScheme.onSurface.withOpacity(0.05)),
          ),
        ),
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
                              'تعديل رسالة الغرفة...',
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
                              _textCtrl.clear();
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
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    style: TextStyle(color: colorScheme.onSurface),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => IconButton(
                    onPressed: () async {
                      if (editingMessageId.value != null) {
                        final txt = _textCtrl.text.trim();
                        if (txt.isNotEmpty) {
                          try {
                            await controller.updateMessage(
                              editingMessageId.value!,
                              txt,
                            );
                            editingMessageId.value = null;
                            _textCtrl.clear();
                          } catch (e) {
                            Get.snackbar('خطأ', 'فشل تعديل الرسالة');
                          }
                        }
                      } else {
                        _send();
                      }
                    },
                    icon: Icon(
                      editingMessageId.value != null
                          ? Icons.check_rounded
                          : Icons.send_rounded,
                      color: colorScheme.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildAvatar(
    String imageUrl,
    String name,
    String? senderId,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        if (Get.width > AppBreakpoints.mobileBreakpoint) {
          Get.dialog(
            UserProfileView(
              userId: senderId ?? '',
              heroTag: 'avatar_${senderId}',
            ),
          );
        } else {
          Get.to(() => UserProfileView(userId: senderId!));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: SafeCachedAvatar(
          user: UserModel.fromJson(senderId != null ? {'id': senderId} : {}),
          radius: 17.5,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
        ),
      ),
    );
  }
}
