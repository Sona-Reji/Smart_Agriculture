import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/sensor_data_service.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  final SensorDataService service;

  const HistoryScreen({
    super.key,
    required this.service,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryTimeframe _selectedTimeframe = HistoryTimeframe.hours24;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Field History'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeframe selection chips
                  _buildTimeframeSelector(),
                  const SizedBox(height: 16),

                  // Chart 1: Soil Moisture
                  _buildMetricChartCard(
                    title: 'Soil Moisture',
                    unit: '%',
                    color: AppColors.soilMoisture,
                    metricKey: 'soilMoisture',
                    currentValue: widget.service.currentData.soilMoisture,
                  ),
                  const SizedBox(height: 16),

                  // Chart 2: Temperature
                  _buildMetricChartCard(
                    title: 'Temperature',
                    unit: '°C',
                    color: AppColors.temperature,
                    metricKey: 'temperature',
                    currentValue: widget.service.currentData.temperature,
                  ),
                  const SizedBox(height: 16),

                  // Chart 3: Humidity
                  _buildMetricChartCard(
                    title: 'Humidity',
                    unit: '%',
                    color: AppColors.humidity,
                    metricKey: 'humidity',
                    currentValue: widget.service.currentData.humidity,
                  ),
                  const SizedBox(height: 16),

                  // Chart 4: Water Level
                  _buildMetricChartCard(
                    title: 'Water Level',
                    unit: '%',
                    color: AppColors.waterLevel,
                    metricKey: 'waterLevel',
                    currentValue: widget.service.currentData.waterLevel,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector() {
    return Row(
      children: [
        _buildTimeChip('Today', HistoryTimeframe.today),
        const SizedBox(width: 8),
        _buildTimeChip('24 Hours', HistoryTimeframe.hours24),
        const SizedBox(width: 8),
        _buildTimeChip('7 Days', HistoryTimeframe.days7),
      ],
    );
  }

  Widget _buildTimeChip(String label, HistoryTimeframe timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTimeframe = timeframe;
          });
        }
      },
    );
  }

  Widget _buildMetricChartCard({
    required String title,
    required String unit,
    required Color color,
    required String metricKey,
    required double currentValue,
  }) {
    final points = widget.service.getHistoricalData(metricKey, _selectedTimeframe);

    double minVal = points.isNotEmpty ? points.first.value : 0.0;
    double maxVal = points.isNotEmpty ? points.first.value : 0.0;

    for (final pt in points) {
      if (pt.value < minVal) minVal = pt.value;
      if (pt.value > maxVal) maxVal = pt.value;
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Current: ${currentValue.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // fl_chart Line Chart
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: AppColors.cardBorder,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          val.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < points.length) {
                          final dt = points[idx].timestamp;
                          final timeStr = _selectedTimeframe == HistoryTimeframe.days7
                              ? '${dt.month}/${dt.day}'
                              : '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                          return Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: (minVal - 10).clamp(0.0, 100.0),
                maxY: (maxVal + 10).clamp(0.0, 100.0),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Summary Stats Footer (Current, Minimum, Maximum)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Current', '${currentValue.toStringAsFixed(1)}$unit'),
                Container(height: 20, width: 1, color: AppColors.cardBorder),
                _buildStatItem('Minimum', '${minVal.toStringAsFixed(1)}$unit'),
                Container(height: 20, width: 1, color: AppColors.cardBorder),
                _buildStatItem('Maximum', '${maxVal.toStringAsFixed(1)}$unit'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
