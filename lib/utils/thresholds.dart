import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import 'app_colors.dart';

enum SoilMoistureStatus { dry, normal, high }

enum FieldCondition { good, attention, critical }

class SensorThresholds {
  // Soil Moisture Thresholds (%)
  static const double soilMoistureDryMax = 25.0;
  static const double soilMoistureHighMin = 70.0;

  // Temperature Thresholds (°C)
  static const double tempHighThreshold = 35.0;

  // Water Level Thresholds (%)
  static const double waterLevelLowThreshold = 30.0;

  // Battery Level Thresholds (%)
  static const double batteryLowThreshold = 20.0;

  /// Returns soil moisture status enum based on value
  static SoilMoistureStatus getSoilMoistureStatus(double moisture) {
    if (moisture < soilMoistureDryMax) {
      return SoilMoistureStatus.dry;
    } else if (moisture > soilMoistureHighMin) {
      return SoilMoistureStatus.high;
    }
    return SoilMoistureStatus.normal;
  }

  /// Returns soil moisture display text
  static String getSoilMoistureStatusText(double moisture) {
    switch (getSoilMoistureStatus(moisture)) {
      case SoilMoistureStatus.dry:
        return 'DRY';
      case SoilMoistureStatus.normal:
        return 'NORMAL';
      case SoilMoistureStatus.high:
        return 'HIGH';
    }
  }

  /// Returns soil moisture status color
  static Color getSoilMoistureColor(double moisture) {
    switch (getSoilMoistureStatus(moisture)) {
      case SoilMoistureStatus.dry:
        return AppColors.statusCritical;
      case SoilMoistureStatus.normal:
        return AppColors.statusGood;
      case SoilMoistureStatus.high:
        return AppColors.statusAttention;
    }
  }

  /// Overall Rule-based Field Status Calculation
  static FieldCondition calculateFieldCondition(SensorData data) {
    if (data.isOffline) {
      return FieldCondition.critical;
    }

    if (data.soilMoisture < 20.0 || data.waterLevel < 15.0) {
      return FieldCondition.critical;
    }

    if (data.soilMoisture < soilMoistureDryMax ||
        data.waterLevel < waterLevelLowThreshold ||
        data.temperature > tempHighThreshold ||
        data.battery < batteryLowThreshold) {
      return FieldCondition.attention;
    }

    return FieldCondition.good;
  }

  /// Summary description narrative for overall field condition
  static String getFieldConditionMessage(SensorData data) {
    if (data.isOffline) {
      return 'Device offline. Field sensors are not transmitting data.';
    }

    if (data.soilMoisture < 20.0) {
      return 'Soil moisture is critically low (${data.soilMoisture.toStringAsFixed(0)}%). Immediate irrigation recommended.';
    }

    if (data.soilMoisture < soilMoistureDryMax) {
      return 'Soil moisture is low (${data.soilMoisture.toStringAsFixed(0)}%). Check irrigation scheduling.';
    }

    if (data.waterLevel < waterLevelLowThreshold) {
      return 'Water tank level is low (${data.waterLevel.toStringAsFixed(0)}%). Reserve water running out.';
    }

    if (data.temperature > tempHighThreshold) {
      return 'Field temperature elevated (${data.temperature.toStringAsFixed(1)}°C). Crops may experience heat stress.';
    }

    if (data.battery < batteryLowThreshold) {
      return 'Sensor device battery is low (${data.battery.toStringAsFixed(0)}%). Maintenance required soon.';
    }

    return 'All monitored conditions are currently normal and within optimal range.';
  }

  /// Calculate Health Score (0 - 100)
  static int calculateHealthScore(SensorData data) {
    if (data.isOffline) return 0;

    double score = 100.0;

    // Soil moisture penalty (optimal: 35-65%)
    if (data.soilMoisture < 25) {
      score -= (25 - data.soilMoisture) * 2.5;
    } else if (data.soilMoisture > 70) {
      score -= (data.soilMoisture - 70) * 1.5;
    }

    // Temperature penalty (optimal: 20-32°C)
    if (data.temperature > 32) {
      score -= (data.temperature - 32) * 3.0;
    } else if (data.temperature < 15) {
      score -= (15 - data.temperature) * 2.0;
    }

    // Water level penalty
    if (data.waterLevel < 30) {
      score -= (30 - data.waterLevel) * 1.2;
    }

    // Battery penalty
    if (data.battery < 20) {
      score -= (20 - data.battery) * 1.0;
    }

    return score.clamp(0.0, 100.0).round();
  }

  /// Health status narrative string
  static String getHealthScoreStatusText(int score, bool isOffline) {
    if (isOffline) return 'Offline';
    if (score >= 80) return 'Healthy';
    if (score >= 55) return 'Fair';
    if (score >= 35) return 'Needs Attention';
    return 'Critical';
  }
}
