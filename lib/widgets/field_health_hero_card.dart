import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../utils/app_colors.dart';
import '../utils/thresholds.dart';

class FieldHealthHeroCard extends StatelessWidget {
  final SensorData data;

  const FieldHealthHeroCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final score = SensorThresholds.calculateHealthScore(data);
    final condition = SensorThresholds.calculateFieldCondition(data);
    
    Color scoreColor;
    String conditionText;
    Color conditionBg;

    if (data.isOffline) {
      scoreColor = AppColors.statusOffline;
      conditionText = 'Device Offline';
      conditionBg = AppColors.statusOfflineBg;
    } else if (condition == FieldCondition.good) {
      scoreColor = AppColors.statusGood;
      conditionText = 'Good condition';
      conditionBg = AppColors.statusGoodBg;
    } else if (condition == FieldCondition.attention) {
      scoreColor = AppColors.statusAttention;
      conditionText = 'Attention Needed';
      conditionBg = AppColors.statusAttentionBg;
    } else {
      scoreColor = AppColors.statusCritical;
      conditionText = 'Critical Attention';
      conditionBg = AppColors.statusCriticalBg;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Field Health Label & Condition Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FIELD HEALTH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: conditionBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      conditionText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Score Display & Visual Indicator Bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                ' / 100',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              // Custom circular progress or score indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      score >= 80 ? 'Optimal' : (score >= 55 ? 'Moderate' : 'Risk'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (score / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(height: 16),

          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 14),

          // Small Visual Status Indicators for: Soil, Temp, Water, Device
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStatusPill(
                icon: Icons.water_drop_rounded,
                label: 'Soil',
                value: '${data.soilMoisture.toStringAsFixed(0)}%',
                isOk: data.soilMoisture >= 25 && data.soilMoisture <= 80,
                color: AppColors.soilMoisture,
              ),
              _buildMiniStatusPill(
                icon: Icons.thermostat_rounded,
                label: 'Temp',
                value: '${data.temperature.toStringAsFixed(0)}°C',
                isOk: data.temperature <= 35,
                color: AppColors.temperature,
              ),
              _buildMiniStatusPill(
                icon: Icons.propane_tank_rounded,
                label: 'Water',
                value: '${data.waterLevel.toStringAsFixed(0)}%',
                isOk: data.waterLevel >= 30,
                color: AppColors.waterLevel,
              ),
              _buildMiniStatusPill(
                icon: Icons.cell_tower_rounded,
                label: 'Device',
                value: data.isOffline ? 'Off' : 'Online',
                isOk: !data.isOffline,
                color: AppColors.deviceStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusPill({
    required IconData icon,
    required String label,
    required String value,
    required bool isOk,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOk ? AppColors.textPrimary : AppColors.statusAttention,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
