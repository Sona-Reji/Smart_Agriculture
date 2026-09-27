import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../utils/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surface : AppColors.primaryContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? AppColors.cardBorder : AppColors.primaryLight.withValues(alpha: 0.5),
            width: item.isRead ? 1.0 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.isRead ? AppColors.background : AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Text(
                  item.iconEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeAgo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
