import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/notification_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cached_network_image/cached_network_image.dart';

class ChatRoomView extends StatefulWidget {
  final String roomId;
  final String roomName;
  const ChatRoomView({super.key, required this.roomId, required this.roomName});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  late final ChatController controller;
  late final AuthController authController;
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatController(roomId: widget.roomId));
    authController = Get.find<AuthController>();
    // Set active room for notification filtering
    NotificationService.activeRoomId = widget.roomId;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scroll.dispose();
    // Clear active room
    NotificationService.activeRoomId = null;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: theme.cardColor.withOpacity(0.5),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        titleTextStyle: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
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
                          color: colorScheme.onBackground.withOpacity(0.3),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Auto-scroll to bottom when messages load or a new one arrives
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) {
                  _scroll.jumpTo(_scroll.position.maxScrollExtent);
                }
              });

              return ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: msgs.length,
                itemBuilder: (ctx, i) {
                  final m = msgs[i];
                  final content = m['text'] ?? '';
                  final name = m['name'] ?? 'مجهول';
                  final userImage = m['userImage'] ?? '';
                  final createdAt = m['createdAt'];
                  final senderId = m['senderId'];
                  final isMe = senderId == authController.userModel.value?.id;

                  String time = '';
                  if (createdAt != null) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      int.tryParse(createdAt.toString()) ?? 0,
                    );
                    time = intl.DateFormat('HH:mm').format(date);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          _buildAvatar(userImage, name, colorScheme),
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
                                      color: colorScheme.onBackground
                                          .withOpacity(0.7),
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
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(4),
                                    topRight: const Radius.circular(4),
                                    bottomLeft: Radius.circular(isMe ? 0 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  content,
                                  style: TextStyle(
                                    color: isMe ? Colors.black : Colors.white,

                                    fontSize: 14,
                                    fontWeight: isMe
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isMe) const SizedBox(width: 4),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
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
                  IconButton(
                    onPressed: _send,
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
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String name, ColorScheme colorScheme) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) =>
                    _buildLetterAvatar(name, colorScheme),
              )
            : _buildLetterAvatar(name, colorScheme),
      ),
    );
  }

  Widget _buildLetterAvatar(String name, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
