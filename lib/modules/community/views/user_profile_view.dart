import 'package:flutter/material.dart';
import '../../profile/views/profile_view.dart';

/// Thin redirect to the unified [ProfileView].
/// All profile viewing logic now lives in [ProfileView].
class UserProfileView extends StatelessWidget {
  final String userId;
  final String? heroTag;

  const UserProfileView({super.key, required this.userId, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return ProfileView(userId: userId, heroTag: heroTag);
  }
}
