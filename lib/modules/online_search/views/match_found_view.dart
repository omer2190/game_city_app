import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../matchmaking_controller.dart';
import '../../../data/models/matchmaking_model.dart';
import '../../../modules/community/views/user_profile_view.dart';

class MatchFoundView extends StatelessWidget {
  final MatchmakingController controller;
  final MatchResult match;
  final Color primary;

  const MatchFoundView({
    super.key,
    required this.controller,
    required this.match,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          // margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'تم العثور على لاعب!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 16),
              // عرض صورة لاعب
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    (match.userImages != null && match.userImages!.isNotEmpty)
                    ? CachedNetworkImageProvider(match.userImages!.first)
                    : null,
                child: (match.userImages == null || match.userImages!.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                '${match.firstName ?? ''} ${match.lastName ?? ''}'.trim() != ''
                    ? '${match.firstName ?? ''} ${match.lastName ?? ''}'
                    : match.userName ?? match.withUserId ?? 'لاعب مجهول',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              if (match.notes != null && match.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'ملاحظات: ${match.notes}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  final userId = match.withUserId;
                  if (userId != null) {
                    Get.to(() => UserProfileView(userId: userId));
                  } else {
                    Get.snackbar('Error', 'User ID not found');
                  }

                  // Reset state to allow new search
                  controller.matchFound(false);
                  controller.matchResult.value = null;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'عرض الملف الشخصي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.matchFound(false);
                        controller.matchResult.value = null;
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('رجوع'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.matchFound(false);
                        controller.matchResult.value = null;
                        controller.startSearch();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('بحث مجدد'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
