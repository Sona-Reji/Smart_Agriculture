import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/notification_card.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  final NotificationService service;

  const NotificationsScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final notifications = service.notifications;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              if (notifications.isNotEmpty) ...[
                TextButton(
                  onPressed: service.markAllAsRead,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  tooltip: 'Clear All',
                  onPressed: service.clearAll,
                ),
              ],
            ],
          ),
          body: SafeArea(
            child: notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.textMuted),
                          SizedBox(height: 14),
                          Text(
                            'No notifications',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Alert updates, community replies, and connection requests will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return NotificationCard(
                        item: item,
                        onTap: () => service.markAsRead(item.id),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
