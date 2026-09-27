import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/thresholds.dart';
import '../models/sensor_data.dart';

class HealthScoreCard extends StatelessWidget {
  final SensorData data;

  const HealthScoreCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final score = SensorThresholds.calculateHealthScore(data);
    final statusText = SensorThresholds.getHealthScoreStatusText(score, data.isOffline);

    Color scoreColor;
    if (data.isOffline) {
      scoreColor = AppColors.statusOffline;
    } else if (score >= 80) {
      scoreColor = AppColors.statusGood;
    } else if (score >= 55) {
      scoreColor = AppColors.statusAttention;
    } else {
      scoreColor = AppColors.statusCritical;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FIELD HEALTH SCORE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Status: $statusText',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Score display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                  height: 1.0,
                ),
              ),
              const Text(
                ' / 100',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (score / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(height: 8),

          // Disclaiming note
          const Text(
            'Prototype monitoring score based on optimal sensor ranges.',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
