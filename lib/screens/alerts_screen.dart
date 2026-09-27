import 'package:flutter/material.dart';
import '../services/sensor_data_service.dart';
import '../widgets/alert_card.dart';
import '../utils/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  final SensorDataService service;

  const AlertsScreen({
    super.key,
    required this.service,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final activeAlerts = widget.service.getActiveAlerts();
        final resolvedAlerts = widget.service.getResolvedAlerts();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Field Alerts'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ACTIVE'),
                      if (activeAlerts.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statusCritical,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${activeAlerts.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('RESOLVED'),
                      if (resolvedAlerts.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${resolvedAlerts.length}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Active Alerts Tab
              _buildAlertList(
                alerts: activeAlerts,
                emptyTitle: 'No Active Alerts',
                emptySubtitle: 'All monitored field parameters are currently operating normally.',
                emptyIcon: Icons.verified_user_rounded,
              ),

              // Resolved Alerts Tab
              _buildAlertList(
                alerts: resolvedAlerts,
                emptyTitle: 'No Resolved Alerts',
                emptySubtitle: 'Historical alert log is empty.',
                emptyIcon: Icons.history_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertList({
    required List alerts,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
  }) {
    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 56, color: AppColors.statusGood),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return AlertCard(
          alert: alert,
          onResolve: () {
            widget.service.markAlertResolved(alert.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Alert "${alert.title}" marked as resolved.'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },

    );
  }
}
