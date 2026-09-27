import 'package:flutter/material.dart';
import '../services/sensor_data_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/thresholds.dart';
import 'history_screen.dart';
import 'sensor_details_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  final SensorDataService service;
  final Function(int) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.service,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        if (service.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (service.error != null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppColors.statusCritical),
                  const SizedBox(height: 16),
                  const Text('Unable to load field data', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: service.refreshData, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final data = service.currentData;
        final activeAlerts = service.getActiveAlerts();
        final condition = SensorThresholds.calculateFieldCondition(data);
        final isHealthy = condition == FieldCondition.good;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: service.refreshData,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildFieldSelectorAndHealth(isHealthy),
                  const SizedBox(height: 16),
                  _buildDemoScenarioBar(service),
                  const SizedBox(height: 32),
                  if (activeAlerts.isNotEmpty) ...[
                    _buildActiveAlert(activeAlerts.first, context),
                    const SizedBox(height: 24),
                  ],
                  _buildCompactSensors(context, data, service),
                  const SizedBox(height: 24),
                  _buildInsight(data),
                  const SizedBox(height: 24),
                  _buildNearbyFarmersCard(context),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final notifService = NotificationService();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Good morning, Farmer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        ListenableBuilder(
          listenable: notifService,
          builder: (context, _) {
            final unread = notifService.unreadCount;
            return IconButton(
              icon: unread > 0
                  ? Badge(
                      label: Text('$unread'),
                      backgroundColor: AppColors.statusCritical,
                      child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                    )
                  : const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen(service: notifService)));
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFieldSelectorAndHealth(bool isHealthy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: AppColors.primary, size: 28),
        const SizedBox(width: 8),
        const Text(
          'Field 01',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHealthy ? AppColors.statusGoodBg : AppColors.statusAttentionBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.warning_rounded,
                color: isHealthy ? AppColors.statusGood : AppColors.statusAttention,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isHealthy ? 'Healthy' : 'Attention',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isHealthy ? AppColors.statusGood : AppColors.statusAttention,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoScenarioBar(SensorDataService service) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text('DEMO:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          _buildScenarioChip(service, 'Normal', DemoScenario.normal),
          const SizedBox(width: 8),
          _buildScenarioChip(service, 'Dry', DemoScenario.lowSoilMoisture),
          const SizedBox(width: 8),
          _buildScenarioChip(service, 'Hot', DemoScenario.highTemperature),
          const SizedBox(width: 8),
          _buildScenarioChip(service, 'Rain', DemoScenario.rainDetected),
          const SizedBox(width: 8),
          _buildScenarioChip(service, 'Offline', DemoScenario.deviceOffline),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(SensorDataService service, String label, DemoScenario scenario) {
    final isSelected = service.currentScenario == scenario;
    return InkWell(
      onTap: () => service.setDemoScenario(scenario),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAlert(dynamic alert, BuildContext context) {
    return InkWell(
      onTap: () => onNavigateToTab(3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.statusAttentionBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.statusAttention.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusAttention.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.statusAttention, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(alert.message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.statusAttention),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSensors(BuildContext context, dynamic data, SensorDataService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Conditions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                _buildSensorTile(context, 'Moisture', '${data.soilMoisture.toStringAsFixed(0)}%', Icons.water_drop, AppColors.soilMoisture, width / 2 - 6, service, 'soilMoisture'),
                _buildSensorTile(context, 'Temperature', '${data.temperature.toStringAsFixed(1)}°C', Icons.thermostat, AppColors.temperature, width / 2 - 6, service, 'temperature'),
                _buildSensorTile(context, 'Humidity', '${data.humidity.toStringAsFixed(0)}%', Icons.air, AppColors.humidity, width / 2 - 6, service, 'humidity'),
                _buildSensorTile(context, 'Light', '${data.light.toStringAsFixed(0)} lux', Icons.wb_sunny, AppColors.light, width / 2 - 6, service, 'light'),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniSensor('Water', '${data.waterLevel.toStringAsFixed(0)}%', Icons.propane_tank, AppColors.waterLevel),
              Container(width: 1, height: 24, color: AppColors.cardBorder),
              _buildMiniSensor('Rain', data.rain ? 'Yes' : 'No', Icons.water, AppColors.rain),
              Container(width: 1, height: 24, color: AppColors.cardBorder),
              _buildMiniSensor('Battery', '${data.battery.toStringAsFixed(0)}%', Icons.battery_charging_full, AppColors.battery),
              Container(width: 1, height: 24, color: AppColors.cardBorder),
              _buildMiniSensor('Status', data.isOffline ? 'Offline' : 'Online', Icons.wifi, data.isOffline ? AppColors.statusCritical : AppColors.statusGood),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSensorTile(BuildContext context, String label, String value, IconData icon, Color color, double width, SensorDataService service, String key) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SensorDetailsScreen(sensorKey: key, service: service))),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSensor(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildInsight(dynamic data) {
    String insight = 'Field conditions are currently stable.';
    if (data.isOffline) {
      insight = 'Gateway is offline. Cannot determine conditions.';
    } else if (data.soilMoisture < 30) {
      insight = 'Soil moisture is low. Consider running irrigation system.';
    } else if (data.temperature > 35) {
      insight = 'Temperature is unusually high. Monitor crops for heat stress.';
    } else if (data.rain) {
      insight = 'Rain detected. Automated irrigation has been paused.';
    } else if (data.waterLevel < 20) {
      insight = 'Reservoir water level is low. Refill soon.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(fontSize: 14, color: AppColors.primaryDark, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyFarmersCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧑‍🌾 Nearby Farmers Network',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Direct Call & Instant Message with nearby farmers',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onNavigateToTab(1),
                  icon: const Icon(Icons.call, size: 16, color: AppColors.primary),
                  label: const Text('Call Farmers'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onNavigateToTab(1),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: const Text('Direct Message'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(service: service))),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('History'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: AppColors.cardBorder),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onNavigateToTab(2),
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: const Text('Explore Equipment'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
