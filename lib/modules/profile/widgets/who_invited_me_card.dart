import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/invitation_model.dart';
import '../../../shared/widgets/widgets.dart';

class WhoInvitedMeCard extends StatelessWidget {
  final InvitationModel? invitedBy;

  const WhoInvitedMeCard({super.key, this.invitedBy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final inviter = invitedBy?.inviter;
    final name = '${inviter?.firstName ?? ''} ${inviter?.lastName ?? ''}'
        .trim();
    final userName = inviter?.userName ?? '';
    final imageUrl =
        (inviter?.userImage != null && inviter!.userImage!.isNotEmpty)
        ? inviter.userImage!.first
        : null;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.person_add_alt_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'دعاني',
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
          if (invitedBy == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'لم تتم دعوتك من قبل أحد',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primary.withOpacity(0.15),
                  backgroundImage: imageUrl != null
                      ? CachedNetworkImageProvider(imageUrl)
                      : null,
                  child: imageUrl == null
                      ? Icon(Icons.person, color: colorScheme.primary, size: 26)
                      : null,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (userName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '@$userName',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (invitedBy!.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'انضممت ${_formatDate(invitedBy!.createdAt!)}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
