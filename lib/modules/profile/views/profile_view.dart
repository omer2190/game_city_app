import 'package:flutter/material.dart';
import 'package:game_city_app/modules/profile/views/desktop/visitor_desktop_shell.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'desktop/owner_desktop_shell.dart';
import 'mobile/owner_mobile_shell.dart';
import 'mobile/visitor_mobile_shell.dart';

class ProfileView extends StatelessWidget {
  final String? userId;
  final String? heroTag;

  ProfileView({super.key, this.userId, this.heroTag});

  bool get isOwner => userId == null;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopOrTablet;

    if (isOwner) {
      return isDesktop ? OwnerDesktopShell() : const OwnerMobileShell();
    }
    return isDesktop
        ? VisitorDesktopShell(userId: userId!, heroTag: heroTag)
        : VisitorMobileShell(userId: userId!, heroTag: heroTag);
  }
}
