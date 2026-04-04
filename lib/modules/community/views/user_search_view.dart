import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../controllers/friends_controller.dart';
import '../controllers/suggested_friends_controller.dart';
import '../../../data/models/user_model.dart';
import '../../chat/views/chat_view.dart';
import 'user_profile_view.dart';

class UserSearchView extends StatelessWidget {
  UserSearchView({super.key});

  final FriendsController friendsController = Get.find<FriendsController>();
  final SuggestedFriendsController suggestedController = Get.put(
    SuggestedFriendsController(),
  );
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: colorScheme.onSurface),
      //   title: TextField(
      //     controller: _searchController,
      //     autofocus: true,
      //     style: TextStyle(color: colorScheme.onSurface),
      //     onChanged: (v) => friendsController.search(v),
      //     decoration: InputDecoration(
      //       hintText: 'ابحث عن لاعبين...',
      //       hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      //       border: InputBorder.none,
      //       suffixIcon: IconButton(
      //         icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
      //         onPressed: () {
      //           _searchController.clear();
      //           friendsController.search('');
      //         },
      //       ),
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          Header(
            title: 'المجتمع',
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (v) => friendsController.search(v),
              decoration: InputDecoration(
                hintText: 'ابحث عن لاعبين...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    friendsController.search('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final hasQuery = _searchController.text.isNotEmpty;

              if (friendsController.isSearchLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }

              if (hasQuery) {
                if (friendsController.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'لم يتم العثور على نتائج',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return _buildList(
                  friendsController.searchResults,
                  isSearch: true,
                );
              }

              // Default view: Suggestions
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 16,
                    ),
                    child: Text(
                      'لاعبون قد تعرفهم',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (suggestedController.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        );
                      }
                      return _buildList(
                        suggestedController.suggestions,
                        isSearch: false,
                      );
                    }),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<UserModel> users, {required bool isSearch}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserTile(context, user);
      },
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isFriend = friendsController.friendsList.any(
      (f) => f.id == user.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isFriend ? () => Get.to(() => ChatView(recipient: user)) : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(
                  () => UserProfileView(
                    userId: user.id ?? '',
                    heroTag: 'search_avatar_${user.id}',
                  ),
                ),
                child: Hero(
                  tag: 'search_avatar_${user.id}',
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        (user.userImage != null && user.userImage!.isNotEmpty)
                        ? CachedNetworkImageProvider(user.userImage!.first)
                        : null,
                    child: (user.userImage == null || user.userImage!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName ?? '',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user.userProfile?.bio != null)
                      Text(
                        user.userProfile!.bio!,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              _buildActionButton(context, user, isFriend),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    UserModel user,
    bool isFriend,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isFriend) {
      return Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant);
    }

    return IconButton(
      onPressed: () => suggestedController.sendFriendRequest(user.id ?? ''),
      icon: Icon(Icons.person_add_alt_1, color: colorScheme.primary),
    );
  }
}
