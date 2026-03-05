import 'package:flutter/material.dart';

class ProfileDetailItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProfileDetailItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon != null
                  ? Icon(icon, color: Colors.white, size: 20)
                  : Text(
                      label.isNotEmpty ? label[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: colorScheme.primary, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null && onDelete == null)
              Icon(
                Icons.open_in_new_outlined,
                size: 14,
                color: colorScheme.primary.withOpacity(0.5),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: colorScheme.error.withOpacity(0.7),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
