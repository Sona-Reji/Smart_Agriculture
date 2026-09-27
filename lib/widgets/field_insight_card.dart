import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../utils/app_colors.dart';

class FieldInsightCard extends StatelessWidget {
  final SensorData data;
  final VoidCallback onFindWaterPumpTap;
  final VoidCallback? onFindTractorTap;

  const FieldInsightCard({
    super.key,
    required this.data,
    required this.onFindWaterPumpTap,
    this.onFindTractorTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowMoisture = data.soilMoisture < 25.0;
    final isLowWater = data.waterLevel < 30.0;
    final isHighTemp = data.temperature > 35.0;
    final isOffline = data.isOffline;

    final isAbnormal = isLowMoisture || isLowWater || isHighTemp || isOffline;

    Color bgColor = isAbnormal ? AppColors.statusAttentionBg : AppColors.statusGoodBg;
    Color borderColor = isAbnormal
        ? AppColors.statusAttention.withValues(alpha: 0.3)
        : AppColors.statusGood.withValues(alpha: 0.3);
    Color textColor = isAbnormal ? AppColors.statusAttention : AppColors.primaryDark;

    String emoji = isAbnormal ? '⚠️' : '🌱';
    String title = isAbnormal ? 'Field Insight' : 'Field Insight';
    String message;
    String? buttonText;
    VoidCallback? buttonAction;

    if (isOffline) {
      message = 'Field gateway is currently offline. Check power supply or connection.';
      buttonText = 'Find Technician';
      buttonAction = onFindWaterPumpTap;
    } else if (isLowMoisture) {
      message = 'Soil moisture is low (${data.soilMoisture.toStringAsFixed(0)}%). Irrigation may be required immediately.';
      buttonText = 'Find Water Pump';
      buttonAction = onFindWaterPumpTap;
    } else if (isLowWater) {
      message = 'Water tank reservoir level is low (${data.waterLevel.toStringAsFixed(0)}%). Reserve water running low.';
      buttonText = 'Find Water Pump';
      buttonAction = onFindWaterPumpTap;
    } else if (isHighTemp) {
      message = 'Field temperature is elevated (${data.temperature.toStringAsFixed(1)}°C). Crops may experience heat stress.';
      buttonText = 'Find Sprayers & Tools';
      buttonAction = onFindWaterPumpTap;
    } else {
      message = 'Soil moisture and field conditions are healthy. No immediate action is required.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          if (buttonText != null && buttonAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: buttonAction,
              icon: const Icon(Icons.search_rounded, size: 16),
              label: Text(
                buttonText,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
