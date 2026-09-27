import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/thresholds.dart';
import '../models/sensor_data.dart';

class FieldStatusCard extends StatelessWidget {
  final SensorData data;

  const FieldStatusCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final condition = SensorThresholds.calculateFieldCondition(data);
    final message = SensorThresholds.getFieldConditionMessage(data);

    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    String statusTitle;
    String badgeEmoji;

    switch (condition) {
      case FieldCondition.good:
        bgColor = AppColors.statusGoodBg;
        borderColor = AppColors.statusGood.withValues(alpha: 0.3);
        iconColor = AppColors.statusGood;
        textColor = AppColors.primaryDark;
        statusTitle = 'GOOD';
        badgeEmoji = '🟢';
        break;
      case FieldCondition.attention:
        bgColor = AppColors.statusAttentionBg;
        borderColor = AppColors.statusAttention.withValues(alpha: 0.3);
        iconColor = AppColors.statusAttention;
        textColor = AppColors.statusAttention;
        statusTitle = 'ATTENTION';
        badgeEmoji = '🟡';
        break;
      case FieldCondition.critical:
        bgColor = AppColors.statusCriticalBg;
        borderColor = AppColors.statusCritical.withValues(alpha: 0.3);
        iconColor = AppColors.statusCritical;
        textColor = AppColors.statusCritical;
        statusTitle = 'CRITICAL';
        badgeEmoji = '🔴';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('🌱', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'FIELD CONDITION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(badgeEmoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                condition == FieldCondition.good
                    ? Icons.check_circle_rounded
                    : (condition == FieldCondition.attention
                        ? Icons.warning_amber_rounded
                        : Icons.error_rounded),
                color: iconColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
