import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/modules/community/views/user_profile_view.dart';
import 'package:game_city_app/modules/community/widgets/community_split_shell.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/suggested_friends_controller.dart';
import '../controllers/friends_controller.dart';
import '../controllers/rooms_controller.dart';
import '../../chat/views/chat_view.dart';
import '../../../data/models/user_model.dart';
import 'user_search_view.dart';
import 'friend_requests_view.dart';
import 'chat_rooms_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SuggestedFriendsController suggestedController = Get.put(
    SuggestedFriendsController(),
  );
  final FriendsController friendsController = Get.put(FriendsController());
  final RoomsController roomsController = Get.put(RoomsController());
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Column(
        children: [
          Header(
            title: 'المجتمع',
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            trailing: Row(
              children: [
                // Hide search icon on desktop – the split-panel search bar
                // handles searching all users via the backend.
                if (!context.isDesktop)
                  IconButton(
                    icon: Icon(Icons.search, color: colorScheme.onSurface),
                    onPressed: () => Get.to(() => UserSearchView()),
                  ),
                Obx(() {
                  final count = friendsController.pendingRequests.length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.person_add_rounded,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: () =>
                            Get.to(() => const FriendRequestsView()),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          // ── Desktop/Tablet: unified split-panel (friends + groups) ─
          if (context.isDesktop)
            Expanded(
              child: Obx(() {
                if (!authController.isLoggedIn.value) {
                  return const GuestView(
                    message:
                        'سجل دخولك الآن لتتمكن من إضافة أصدقاء والانضمام لمجموعات الدردشة',
                  );
                }
                return _buildDesktopSplit(context);
              }),
            )
          else ...[
            // ── Mobile: tabs ─────────────────────────────────────────
            TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withAlpha(127),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              isScrollable: true,
              tabs: const [
                Tab(text: 'أصدقائي'),
                Tab(text: 'المجموعات'),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (!authController.isLoggedIn.value) {
                  return const GuestView(
                    message:
                        'سجل دخولك الآن لتتمكن من إضافة أصدقاء والانضمام لمجموعات الدردشة',
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [_buildFriendsTab(context), ChatRoomsView()],
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendsTab(BuildContext context) {
    return Obx(() {
      if (friendsController.isFriendsLoading.value) {
        return const LoadingWidget(message: 'جاري تحميل قائمة الأصدقاء...');
      }

      final friends = friendsController.friendsList;
      final showSuggestions = friends.length < 5;

      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            friendsController.fetchFriends(),
            friendsController.fetchPendingRequests(),
            suggestedController.fetchSuggestions(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (friends.isEmpty)
              _buildEmptyFriends(context)
            else
              ...friends.map(
                (friend) => _buildUserTile(friend, context, isFriend: true),
              ),

            if (showSuggestions) ...[
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
              Obx(() {
                if (suggestedController.isLoading.value) {
                  return const Center(child: LoadingWidget());
                }
                return Column(
                  children: suggestedController.suggestions
                      .map((s) => _buildUserTile(s, context, isFriend: false))
                      .toList(),
                );
              }),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildEmptyFriends(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.person_off_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
        const SizedBox(height: 16),
        Text(
          'قائمة أصدقائك فارغة حالياً',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(
    UserModel user,
    BuildContext context, {
    required bool isFriend,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: EdgeInsets.zero,
        onTap: () => Get.to(() => ChatView(recipient: user)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (Get.width > AppBreakpoints.mobileBreakpoint) {
                    Get.dialog(
                      UserProfileView(
                        userId: user.id ?? '',
                        heroTag: 'avatar_${user.id}',
                      ),
                    );
                  } else {
                    Get.to(() => UserProfileView(userId: user.id!));
                  }
                },
                child: Hero(
                  tag: 'avatar_${isFriend ? "friend" : "suggested"}_${user.id}',
                  child: SafeCachedAvatar(
                    user: user,
                    radius: 24,
                    borderColor: colorScheme.primary.withOpacity(0.2),
                    borderWidth: 2,
                    backgroundColor: colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName ?? 'مستخدم',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() {
                      final lastMsg =
                          friendsController.lastMessages[user.chatRoomId ?? ''];
                      if (lastMsg != null) {
                        final isMe =
                            lastMsg['senderId'] ==
                            authController.userModel.value?.id;
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
                                    if (isMe)
                                      TextSpan(
                                        text: 'أنت: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    TextSpan(
                                      text: lastMsg['text'] ?? '',
                                      style: TextStyle(
                                        color: isUnread
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 12,
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
                      if (user.userProfile?.bio != null) {
                        return Text(
                          user.userProfile!.bio!,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 11,
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
              Obx(() {
                final lastMsg =
                    friendsController.lastMessages[user.chatRoomId ?? ''];
                if (lastMsg != null) {
                  final timestamp = lastMsg['timestamp'];
                  final date = timestamp is int
                      ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                      : null;
                  final timeStr = date != null
                      ? timeago.format(date, locale: 'en_short')
                      : '';
                  final isMe =
                      lastMsg['senderId'] == authController.userModel.value?.id;
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
                          fontSize: 10,
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
              if (!isFriend)
                IconButton(
                  onPressed: () =>
                      suggestedController.sendFriendRequest(user.id ?? ''),
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Desktop split: friends list (left) + embedded chat (right) ──────

  Widget _buildDesktopSplit(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          friendsController.fetchFriends(),
          friendsController.fetchPendingRequests(),
          suggestedController.fetchSuggestions(),
          roomsController.fetchRooms(),
        ]);
      },
      child: Obx(() {
        if (friendsController.isFriendsLoading.value) {
          return const LoadingWidget(message: 'جاري تحميل قائمة الأصدقاء...');
        }
        return CommunitySplitShell(
          friends: friendsController.friendsList,
          suggestions: suggestedController.suggestions,
          rooms: roomsController.rooms,
          onUserTapMobile: (user) => Get.to(() => ChatView(recipient: user)),
        );
      }),
    );
  }
}
