import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/sensor_data_service.dart';
import '../utils/app_colors.dart';
import '../utils/thresholds.dart';
import 'history_screen.dart';

class SensorDetailsScreen extends StatelessWidget {
  final String sensorKey;
  final SensorDataService service;

  const SensorDetailsScreen({
    super.key,
    required this.sensorKey,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final data = service.currentData;
        final history = service.getHistoricalData(sensorKey, HistoryTimeframe.hours24);

        String title;
        String valueStr;
        String unit;
        IconData icon;
        Color color;
        String statusText;
        Color statusColor;
        String normalRange;
        String description;

        switch (sensorKey) {
          case 'soilMoisture':
            title = 'Soil Moisture';
            valueStr = data.soilMoisture.toStringAsFixed(0);
            unit = '%';
            icon = Icons.water_drop_rounded;
            color = AppColors.soilMoisture;
            statusText = SensorThresholds.getSoilMoistureStatusText(data.soilMoisture);
            statusColor = SensorThresholds.getSoilMoistureColor(data.soilMoisture);
            normalRange = '35% – 65%';
            description =
                'Measures volumetric water content in soil. Optimal levels promote healthy root respiration and nutrient uptake.';
            break;

          case 'temperature':
            title = 'Field Temperature';
            valueStr = data.temperature.toStringAsFixed(1);
            unit = '°C';
            icon = Icons.thermostat_rounded;
            color = AppColors.temperature;
            statusText = data.temperature > 35 ? 'HIGH' : 'NORMAL';
            statusColor = data.temperature > 35 ? AppColors.statusAttention : AppColors.statusGood;
            normalRange = '20°C – 32°C';
            description =
                'Monitors ambient air temperature in field canopy. High temperatures cause heat stress and excessive evapotranspiration.';
            break;

          case 'humidity':
            title = 'Relative Humidity';
            valueStr = data.humidity.toStringAsFixed(0);
            unit = '%';
            icon = Icons.air_rounded;
            color = AppColors.humidity;
            statusText = 'OPTIMAL';
            statusColor = AppColors.statusGood;
            normalRange = '60% – 85%';
            description =
                'Tracks atmospheric moisture surrounding foliage. Helps predict fungal spore germination risks.';
            break;

          case 'waterLevel':
            title = 'Water Storage Level';
            valueStr = data.waterLevel.toStringAsFixed(0);
            unit = '%';
            icon = Icons.propane_tank_rounded;
            color = AppColors.waterLevel;
            statusText = data.waterLevel < 30 ? 'LOW' : 'NORMAL';
            statusColor = data.waterLevel < 30 ? AppColors.statusAttention : AppColors.statusGood;
            normalRange = '40% – 100%';
            description =
                'Reservoir supply level for drip irrigation line pumping. Triggers automatic dry-run pump safety cutoff.';
            break;

          case 'light':
            title = 'Solar Radiation / Light';
            valueStr = data.light.toStringAsFixed(0);
            unit = 'lux';
            icon = Icons.wb_sunny_rounded;
            color = AppColors.light;
            statusText = data.light > 800 ? 'BRIGHT' : 'NORMAL';
            statusColor = AppColors.statusGood;
            normalRange = '300 lux – 900 lux';
            description =
                'Photosynthetically Active Radiation (PAR) intensity received by field canopy.';
            break;

          case 'battery':
            title = 'Gateway Battery';
            valueStr = data.battery.toStringAsFixed(0);
            unit = '%';
            icon = Icons.battery_charging_full_rounded;
            color = AppColors.battery;
            statusText = data.battery < 20 ? 'LOW' : 'GOOD';
            statusColor = data.battery < 20 ? AppColors.statusAttention : AppColors.statusGood;
            normalRange = '30% – 100%';
            description =
                'Solar regulator charge level for wireless IoT sensor node field transmitter.';
            break;

          default:
            title = 'Sensor Telemetry';
            valueStr = '0';
            unit = '';
            icon = Icons.sensors_rounded;
            color = AppColors.primary;
            statusText = 'NORMAL';
            statusColor = AppColors.statusGood;
            normalRange = 'N/A';
            description = 'Field telemetry sensor details.';
        }

        // Calculate min, max, avg
        double minVal = history.isNotEmpty ? history.first.value : 0.0;
        double maxVal = history.isNotEmpty ? history.first.value : 0.0;
        double sum = 0.0;

        for (final pt in history) {
          if (pt.value < minVal) minVal = pt.value;
          if (pt.value > maxVal) maxVal = pt.value;
          sum += pt.value;
        }
        double avgVal = history.isNotEmpty ? sum / history.length : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text('$title Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.show_chart_rounded),
                tooltip: 'Full History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(service: service),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              valueStr,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: color,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              unit,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Target Range: ',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            Text(
                              normalRange,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid (Min, Max, Avg)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('MINIMUM', '${minVal.toStringAsFixed(1)}$unit'),
                        Container(height: 24, width: 1, color: AppColors.cardBorder),
                        _buildStatColumn('AVERAGE', '${avgVal.toStringAsFixed(1)}$unit'),
                        Container(height: 24, width: 1, color: AppColors.cardBorder),
                        _buildStatColumn('MAXIMUM', '${maxVal.toStringAsFixed(1)}$unit'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mini Chart
                  const Text(
                    '24-HOUR TREND PREVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minY: (minVal - 5).clamp(0.0, 100.0),
                          maxY: (maxVal + 5).clamp(0.0, 100.0),
                          lineBarsData: [
                            LineChartBarData(
                              spots: history
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                                  .toList(),
                              isCurved: true,
                              color: color,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: color.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sensor Description & Field Guidance
                  const Text(
                    'FIELD GUIDANCE & DESCRIPTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action to History Screen
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryScreen(service: service),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart_rounded, size: 18),
                      label: const Text(
                        'OPEN FULL FIELD HISTORY',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
