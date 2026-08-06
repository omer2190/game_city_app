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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../chat/views/chat_view.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../views/user_profile_view.dart';

class CommunitySplitShell extends StatefulWidget {
  const CommunitySplitShell({
    super.key,
    required this.friends,
    required this.suggestions,
    this.onUserTapMobile,
  });

  /// List of the user's friends.
  final List<UserModel> friends;

  /// Suggested users from the server.
  final List<UserModel> suggestions;

  /// Callback when a user is tapped on **mobile** (full-screen navigation).
  /// On desktop the callback is ignored — the chat opens in the right panel.
  final void Function(UserModel user)? onUserTapMobile;

  @override
  State<CommunitySplitShell> createState() => _CommunitySplitShellState();
}

class _CommunitySplitShellState extends State<CommunitySplitShell> {
  /// The currently selected friend for the right panel chat.
  final Rx<UserModel?> _selectedUser = Rx<UserModel?>(null);

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

  // ── Mobile: standard list → navigate to ChatView ────────────────────

  Widget _buildMobileList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (widget.friends.isEmpty)
          _buildEmptyFriends(context)
        else
          ...widget.friends.map(
            (friend) => _buildUserTile(friend, context, isFriend: true),
          ),
        if (widget.suggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'اقتراحات',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...widget.suggestions.map(
            (s) => _buildUserTile(s, context, isFriend: false),
          ),
        ],
      ],
    );
  }

  // ── Desktop: split layout ───────────────────────────────────────────

  Widget _buildSplitLayout(BuildContext context, BoxConstraints constraints) {
    final leftWidth = (constraints.maxWidth * 0.35).clamp(280.0, 400.0);

    return Row(
      children: [
        // ── Left Panel: Friends List ──────────────────────────────────
        SizedBox(
          width: leftWidth,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(40),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                _buildDesktopSearchBar(context),
                // Friends list
                Expanded(child: _buildMobileList(context)),
              ],
            ),
          ),
        ),

        // ── Right Panel: Chat ─────────────────────────────────────────
        Expanded(
          child: Obx(() {
            final user = _selectedUser.value;
            if (user == null) {
              return _buildChatPlaceholder(context);
            }
            return ChatView(
              recipient: user,
              embedded: true,
              embeddedOnClose: () => _selectedUser.value = null,
            );
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: EdgeInsets.zero,
        onTap: () {
          if (isDesktop) {
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
                onTap: () => Get.to(
                  () => UserProfileView(
                    userId: user.id ?? '',
                    heroTag:
                        'avatar_${isFriend ? "friend" : "suggested"}_${user.id}',
                  ),
                ),
                child: Hero(
                  tag: 'avatar_${isFriend ? "friend" : "suggested"}_${user.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(50),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: colorScheme.surface,
                      backgroundImage:
                          (user.userImage != null && user.userImage!.isNotEmpty)
                          ? CachedNetworkImageProvider(user.userImage!.first)
                          : null,
                      child: (user.userImage == null || user.userImage!.isEmpty)
                          ? Icon(
                              Icons.person,
                              color: colorScheme.primary,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName ?? 'مستخدم',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Online indicator or arrow
              Icon(
                Icons.chevron_left_rounded,
                color: colorScheme.onSurface.withAlpha(70),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────

  Widget _buildEmptyFriends(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.person_off_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.onBackground.withAlpha(25),
        ),
        const SizedBox(height: 16),
        Text(
          'قائمة أصدقائك فارغة حالياً',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withAlpha(75),
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
        decoration: InputDecoration(
          hintText: 'ابحث عن صديق...',
          prefixIcon: const Icon(Icons.search, size: 20),
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
            color: colorScheme.onBackground.withAlpha(25),
          ),
          const SizedBox(height: 20),
          Text(
            'اختر صديقاً لبدء المحادثة',
            style: TextStyle(
              color: colorScheme.onBackground.withAlpha(75),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على أي اسم من القائمة على اليسار',
            style: TextStyle(
              color: colorScheme.onBackground.withAlpha(50),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
