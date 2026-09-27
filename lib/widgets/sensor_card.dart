import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String statusText;
  final Color statusColor;
  final Color iconColor;
  final bool isFeatured; // Used to emphasize Soil Moisture
  final double? progressValue; // 0.0 to 1.0 for progress bar

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.statusText,
    required this.statusColor,
    required this.iconColor,
    this.isFeatured = false,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isFeatured ? 16 : 14),
      decoration: BoxDecoration(
        color: isFeatured ? AppColors.primaryContainer.withValues(alpha: 0.4) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardBorder,
          width: isFeatured ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Icon + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: isFeatured ? 24 : 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isFeatured ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          // Value & Unit
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isFeatured ? 26 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Optional Progress Bar for Soil Moisture / Water Level / Battery
          if (progressValue != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
