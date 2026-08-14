import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';
import '../../../shared/widgets/widgets.dart';

class TeamListCard extends StatelessWidget {
  final List<InvitationModel> team;
  final bool isLoading;

  const TeamListCard({super.key, required this.team, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.group_rounded, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'فريقي${team.isNotEmpty ? ' (${team.length})' : ''}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (isLoading)
            const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (team.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_disabled_rounded,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لم تقم بدعوة أي شخص بعد',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'شارك كود الدعوة الخاص بك مع أصدقائك',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: team.length,
              separatorBuilder: (_, __) => Divider(
                color: colorScheme.onSurface.withOpacity(0.06),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final member = team[index];
                final invitee = member.invitee;
                final name =
                    '${invitee?.firstName ?? ''} ${invitee?.lastName ?? ''}'
                        .trim();
                final userName = invitee?.userName ?? '';
                final imageUrl =
                    (invitee?.userImage != null &&
                        invitee!.userImage!.isNotEmpty)
                    ? invitee.userImage!.first
                    : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // Avatar
                      SafeCachedAvatar(
                        imageUrl: imageUrl,
                        radius: 22,
                        backgroundColor: colorScheme.primary.withOpacity(0.15),
                      ),
                      const SizedBox(width: 14),

                      // Name & username
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (name.isNotEmpty)
                              Text(
                                name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (userName.isNotEmpty)
                              Text(
                                '@$userName',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),

                      // Joined date
                      if (member.createdAt != null)
                        Text(
                          _formatDate(member.createdAt!),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.6,
                            ),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
