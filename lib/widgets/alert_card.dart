import 'package:flutter/material.dart';
import '../models/field_alert.dart';
import '../utils/app_colors.dart';

class AlertCard extends StatelessWidget {
  final FieldAlert alert;
  final VoidCallback? onResolve;
  final VoidCallback? onViewDetails;

  const AlertCard({
    super.key,
    required this.alert,
    this.onResolve,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color bgColor;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.critical:
        primaryColor = AppColors.statusCritical;
        bgColor = AppColors.statusCriticalBg;
        icon = Icons.error_outline_rounded;
        break;
      case AlertSeverity.warning:
        primaryColor = AppColors.statusAttention;
        bgColor = AppColors.statusAttentionBg;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.info:
        primaryColor = AppColors.soilMoisture;
        bgColor = AppColors.soilMoisture.withValues(alpha: 0.1);
        icon = Icons.info_outline_rounded;
        break;
    }

    if (alert.isResolved) {
      primaryColor = AppColors.textSecondary;
      bgColor = AppColors.background;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.isResolved ? AppColors.surface : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isResolved ? AppColors.cardBorder : primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alert.isResolved ? 'RESOLVED' : alert.severityName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            alert.fieldId,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Values & Details Grid
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT VALUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.currentValue,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RECOMMENDED ACTION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.recommendedAction,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action row & Timestamp footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timestamp
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(alert.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              // Actions
              Row(
                children: [
                  TextButton(
                    onPressed: onViewDetails ?? () => _showDetailsDialog(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (!alert.isResolved && onResolve != null) ...[
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: onResolve,
                      icon: const Icon(Icons.check_rounded, size: 14),
                      label: const Text(
                        'Resolve',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Field: ${alert.fieldId}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Telemetry Reading: ${alert.currentValue}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            const Text(
              'Diagnostic Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(alert.message, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Action:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(alert.recommendedAction, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!alert.isResolved && onResolve != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onResolve!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Resolved'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
