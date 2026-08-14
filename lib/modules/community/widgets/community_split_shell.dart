/// Split-panel layout for community screens on desktop/tablet.
///
/// On **desktop** (> 1024px): Left panel shows friends list, right panel shows
/// the chat with the selected friend. Tapping a friend opens their chat in the
/// right panel instead of pushing a new route.
///
/// On **mobile**: Falls back to the standard full-screen navigation — tapping a
/// friend navigates to [ChatView] normally.
///
/// Usage (in CommunityView):
/// ```dart
/// CommunitySplitShell(
///   friends: friendsList,
///   suggestions: suggestedList,
///   onUserTap: (user) => Get.to(() => ChatView(recipient: user)),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../auth/controllers/auth_controller.dart';
import '../../chat/views/chat_view.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/friends_controller.dart';
import '../controllers/rooms_controller.dart';
import '../views/user_profile_view.dart';
import '../views/chat_room_view.dart';

class CommunitySplitShell extends StatefulWidget {
  const CommunitySplitShell({
    super.key,
    required this.friends,
    required this.suggestions,
    required this.rooms,
    this.onUserTapMobile,
  });

  /// List of the user's friends.
  final List<UserModel> friends;

  /// Suggested users from the server.
  final List<UserModel> suggestions;

  /// List of public chat rooms.
  final List<dynamic> rooms;

  /// Callback when a user is tapped on **mobile** (full-screen navigation).
  /// On desktop the callback is ignored — the chat opens in the right panel.
  final void Function(UserModel user)? onUserTapMobile;

  @override
  State<CommunitySplitShell> createState() => _CommunitySplitShellState();
}

class _CommunitySplitShellState extends State<CommunitySplitShell> {
  /// The currently selected friend for the right panel chat.
  final Rx<UserModel?> _selectedUser = Rx<UserModel?>(null);

  /// The currently selected room for the right panel group chat.
  final Rxn<Map<String, dynamic>> _selectedRoom = Rxn<Map<String, dynamic>>();

  /// Select a room (desktop mode): joins first, then shows the chat.
  Future<void> _selectRoom(Map<String, dynamic> room) async {
    final RoomsController rc = Get.find<RoomsController>();
    final roomId = (room['_id'] ?? room['id'])?.toString() ?? '';
    if (roomId.isEmpty) return;
    final ok = await rc.joinRoom(roomId);
    if (ok) {
      _selectedUser.value = null;
      _selectedRoom.value = room;
    }
  }

  /// Search query for filtering the friends/suggestions list.
  final RxString _searchQuery = RxString('');
  final TextEditingController _searchController = TextEditingController();

  /// Filtered friends list based on search query.
  List<UserModel> get _filteredFriends {
    if (_searchQuery.value.isEmpty) return widget.friends;
    final q = _searchQuery.value.toLowerCase();
    return widget.friends.where((u) {
      final name = (u.userName ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
  }

  /// Filtered suggestions list based on search query.
  List<UserModel> get _filteredSuggestions {
    if (_searchQuery.value.isEmpty) return widget.suggestions;
    final q = _searchQuery.value.toLowerCase();
    return widget.suggestions.where((u) {
      final name = (u.userName ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
  }

  /// Filtered rooms list based on search query.
  List<dynamic> get _filteredRooms {
    if (_searchQuery.value.isEmpty) return widget.rooms;
    final q = _searchQuery.value.toLowerCase();
    return widget.rooms.where((r) {
      final name = (r['name'] ?? '').toString().toLowerCase();
      final desc = (r['description'] ?? '').toString().toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= AppBreakpoints.tabletBreakpoint;

        if (!isDesktop) {
          return _buildMobileList(context);
        }
        return _buildSplitLayout(context, constraints);
      },
    );
  }

  // ── Mobile / Left-panel list ──────────────────────────────────────
  //
  // Friends and public rooms are **merged** into one list sorted by
  // last-message timestamp (most recent first).  Items with no messages
  // appear last.  Suggestions are shown after the sorted list.

  Widget _buildMobileList(BuildContext context) {
    // Hide suggestions when user has 5+ friends or rooms combined
    final showSuggestions = widget.friends.length + widget.rooms.length < 5;
    final suggestions = showSuggestions ? _filteredSuggestions : <UserModel>[];

    return Obx(() {
      final FriendsController fc = Get.find<FriendsController>();
      final RoomsController rc = Get.find<RoomsController>();

      final friends = _filteredFriends;
      final rooms = _filteredRooms;

      // Build unified sorted list
      final List<_ChatItem> items = [];

      // Collect IDs of items already in the list (to avoid duplicates)
      final existingIds = <String>{};

      for (final f in friends) {
        final lastMsg = fc.lastMessages[f.chatRoomId ?? ''];
        final ts = (lastMsg != null && lastMsg['timestamp'] is int)
            ? lastMsg['timestamp'] as int
            : 0;
        items.add(_ChatItem(user: f, lastTs: ts));
        if (f.id != null) existingIds.add(f.id!);
      }

      for (final r in rooms) {
        final roomId = (r['_id'] ?? r['id'])?.toString() ?? '';
        final lastMsg = rc.lastMessages[roomId];
        final ts = (lastMsg != null && lastMsg['timestamp'] is int)
            ? lastMsg['timestamp'] as int
            : 0;
        items.add(_ChatItem(room: r as Map<String, dynamic>, lastTs: ts));
      }

      // Show backend search results (not already in the list)
      if (_searchQuery.value.isNotEmpty) {
        for (final u in fc.searchResults) {
          if (u.id != null && !existingIds.contains(u.id)) {
            items.add(_ChatItem(user: u, lastTs: 0, isFriend: false));
            existingIds.add(u.id!);
          }
        }
      }

      // Sort: items with messages (ts>0) come first, then by ts desc
      items.sort((a, b) {
        if (a.lastTs > 0 && b.lastTs == 0) return -1;
        if (a.lastTs == 0 && b.lastTs > 0) return 1;
        return b.lastTs.compareTo(a.lastTs);
      });

      final hasAny = items.isNotEmpty || suggestions.isNotEmpty;

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (!hasAny)
            _buildEmptySearch(context)
          else ...[
            if (items.isEmpty && _searchQuery.value.isEmpty)
              _buildEmptyFriends(context)
            else ...[
              for (final item in items)
                if (item.isRoom)
                  _buildRoomTile(item.room!, context)
                else
                  _buildUserTile(item.user!, context, isFriend: item.isFriend),
            ],
            if (suggestions.isNotEmpty && _searchQuery.value.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'اقتراحات',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...suggestions.map(
                (s) => _buildUserTile(s, context, isFriend: false),
              ),
            ],
          ],
        ],
      );
    });
  }

  // ── Desktop: split layout ───────────────────────────────────────────

  Widget _buildSplitLayout(BuildContext context, BoxConstraints constraints) {
    final leftWidth = (constraints.maxWidth * 0.35).clamp(280.0, 400.0);

    return Row(
      children: [
        // ── Left Panel: Friends & Rooms List ──────────────────────────
        SizedBox(
          width: leftWidth,
          child: Column(
            children: [
              // Search bar – searches all users via backend
              _buildDesktopSearchBar(context),
              // Friends list
              Expanded(child: _buildMobileList(context)),
            ],
          ),
        ),

        // ── Visual divider between panels ────────────────────────────
        Container(
          width: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Theme.of(context).dividerColor.withAlpha(40),
        ),

        // ── Right Panel: Chat ─────────────────────────────────────────
        Expanded(
          child: Obx(() {
            final user = _selectedUser.value;
            final room = _selectedRoom.value;

            // Room chat takes priority when both are set (user clears on room tap)
            if (room != null) {
              final roomId = (room['_id'] ?? room['id'])?.toString() ?? '';
              if (roomId.isEmpty) return _buildChatPlaceholder(context);
              return ChatRoomView(
                key: ValueKey('room_$roomId'),
                roomId: roomId,
                roomName: room['name'] ?? 'غرفة',
                embedded: true,
                embeddedOnClose: () => _selectedRoom.value = null,
              );
            }

            if (user != null) {
              return ChatView(
                key: ValueKey('chat_${user.id}'),
                recipient: user,
                embedded: true,
                embeddedOnClose: () => _selectedUser.value = null,
              );
            }

            return _buildChatPlaceholder(context);
          }),
        ),
      ],
    );
  }

  // ── User Tile ───────────────────────────────────────────────────────

  Widget _buildUserTile(
    UserModel user,
    BuildContext context, {
    required bool isFriend,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = context.isDesktop;

    // ── Controllers (read reactively inside Obx) ──────────────────────
    final FriendsController fc = Get.find<FriendsController>();
    final AuthController ac = Get.find<AuthController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: EdgeInsets.zero,
        onTap: () {
          if (isDesktop) {
            _selectedRoom.value = null; // clear room when selecting friend
            _selectedUser.value = user;
          } else {
            widget.onUserTapMobile?.call(user);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Avatar
              GestureDetector(
                // onTap: () => Get.to(
                //   () => UserProfileView(
                //     userId: user.id ?? '',
                //     heroTag:
                //         'avatar_${isFriend ? "friend" : "suggested"}_${user.id}',
                //   ),
                // ),
                onTap: () {
                  if (Get.width > AppBreakpoints.mobileBreakpoint) {
                    Get.dialog(
                      UserProfileView(
                        userId: user.id ?? '',
                        heroTag:
                            'avatar_${isFriend ? "friend" : "suggested"}_${user.id}',
                      ),
                    );
                  } else {
                    Get.to(() => UserProfileView(userId: user.id!));
                  }
                },
                child: Hero(
                  tag: 'avatar_${isFriend ? "friend" : "suggested"}_${user.id}',
                  child: SafeCachedAvatar(
                    imageUrl: user.userImage?.isNotEmpty == true
                        ? user.userImage!.first
                        : null,
                    fallbackName: user.userName,
                    radius: 22,
                    borderColor: colorScheme.primary.withAlpha(50),
                    borderWidth: 2,
                    backgroundColor: colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ── Info (name + last message preview) ──────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.userName ?? 'مستخدم',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // ── Reactive last-message preview ────────────────
                    Obx(() {
                      final lastMsg = fc.lastMessages[user.chatRoomId ?? ''];
                      if (lastMsg != null) {
                        final isMe =
                            lastMsg['senderId'] == ac.userModel.value?.id;
                        final isUnread = lastMsg['read'] == false && !isMe;

                        return Text.rich(
                          TextSpan(
                            children: [
                              if (isMe)
                                TextSpan(
                                  text: 'أنت: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              TextSpan(
                                text: lastMsg['text'] ?? '',
                                style: TextStyle(
                                  color: isUnread
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return Text(
                        isFriend ? 'لا توجد رسائل' : 'انقر لبدء المحادثة',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // ── Timestamp + unread dot ──────────────────────────────
              Obx(() {
                final lastMsg = fc.lastMessages[user.chatRoomId ?? ''];
                if (lastMsg != null && isFriend) {
                  final timestamp = lastMsg['timestamp'];
                  final date = timestamp is int
                      ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                      : null;
                  final timeStr = date != null
                      ? timeago.format(date, locale: 'en_short')
                      : '';
                  final isMe = lastMsg['senderId'] == ac.userModel.value?.id;
                  final isUnread = lastMsg['read'] == false && !isMe;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isUnread
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontSize: 9,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_left_rounded,
                color: colorScheme.onSurface.withAlpha(70),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Room Tile ─────────────────────────────────────────────────────
  //
  // Shows a group-chat room entry in the unified chat list.  Includes
  // live last-message preview and timestamp, just like friend tiles.

  Widget _buildRoomTile(Map<String, dynamic> room, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roomId = (room['_id'] ?? room['id'])?.toString() ?? '';
    final isDesktop = context.isDesktop;
    final RoomsController rc = Get.find<RoomsController>();
    final AuthController ac = Get.find<AuthController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: EdgeInsets.zero,
        onTap: () {
          if (isDesktop) {
            _selectRoom(room);
          } else {
            if (roomId.isNotEmpty) {
              rc.joinRoom(roomId).then((ok) {
                if (ok) {
                  Get.to(
                    () => ChatRoomView(
                      roomId: roomId,
                      roomName: room['name'] ?? 'غرفة',
                    ),
                  );
                }
              });
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      room['name'] ?? 'غرفة',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // ── Reactive last-message preview ──────────────
                    Obx(() {
                      final lastMsg = rc.lastMessages[roomId];
                      if (lastMsg != null) {
                        final senderId = lastMsg['senderId']?.toString();
                        final isMe = senderId == ac.userModel.value?.id;
                        final isUnread = lastMsg['read'] == false && !isMe;

                        return Row(
                          children: [
                            if (isMe) ...[
                              Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: (lastMsg['read'] == true)
                                    ? Colors.blue
                                    : colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: isMe
                                          ? 'أنت: '
                                          : '${lastMsg['senderName'] ?? lastMsg['name'] ?? 'مشارك'}: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                    TextSpan(
                                      text: lastMsg['text'] ?? '',
                                      style: TextStyle(
                                        color: isUnread
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                        fontWeight: isUnread
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }
                      return Text(
                        room['description']?.toString().isNotEmpty == true
                            ? room['description'].toString()
                            : 'انضم للدردشة',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // ── Timestamp ───────────────────────────────────────
              Obx(() {
                final lastMsg = rc.lastMessages[roomId];
                if (lastMsg != null) {
                  final timestamp = lastMsg['timestamp'];
                  final date = timestamp is int
                      ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                      : null;
                  final timeStr = date != null
                      ? timeago.format(date, locale: 'en_short')
                      : '';
                  final senderId = lastMsg['senderId']?.toString();
                  final isMe = senderId == ac.userModel.value?.id;
                  final isUnread = lastMsg['read'] == false && !isMe;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isUnread
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontSize: 9,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_left_rounded,
                color: colorScheme.onSurface.withAlpha(70),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty states ─────────────────────────────────────────────────

  Widget _buildEmptySearch(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
        const SizedBox(height: 16),
        Text(
          'لا توجد نتائج مطابقة',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(75),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFriends(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.person_off_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
        const SizedBox(height: 16),
        Text(
          'قائمة أصدقائك فارغة حالياً',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(75),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ── Desktop search bar ──────────────────────────────────────────────

  Widget _buildDesktopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _searchQuery.value = value;
          // Also trigger backend search for full user discovery
          if (value.isNotEmpty) {
            final fc = Get.find<FriendsController>();
            fc.search(value);
          } else {
            final fc = Get.find<FriendsController>();
            fc.searchResults.clear();
          }
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن صديق...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: Obx(() {
            if (_searchQuery.value.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _searchController.clear();
                _searchQuery.value = '';
                final fc = Get.find<FriendsController>();
                fc.searchResults.clear();
              },
            );
          }),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withAlpha(120),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  // ── Right panel placeholder ─────────────────────────────────────────

  Widget _buildChatPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_rounded,
            size: 80,
            color: colorScheme.onSurface.withAlpha(25),
          ),
          const SizedBox(height: 20),
          Text(
            'اختر صديقاً لبدء المحادثة',
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha(75),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على أي اسم من القائمة على اليسار',
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha(50),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ── Internal helper for unified sorted chat list ────────────────────
class _ChatItem {
  _ChatItem({this.user, this.room, this.lastTs = 0, this.isFriend = true});

  final UserModel? user;
  final Map<String, dynamic>? room;
  final int lastTs; // last-message timestamp in ms, 0 = no messages
  final bool isFriend;

  bool get isRoom => room != null;
}
