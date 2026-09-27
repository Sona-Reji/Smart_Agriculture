import '../models/notification_item.dart';

class MockNotifications {
  static List<NotificationItem> getInitialNotifications() {
    final now = DateTime.now();

    return [
      NotificationItem(
        id: 'notif_01',
        title: 'Soil Moisture Alert',
        message: 'Soil moisture in Field 01 dropped to 18%. Recommended: Check irrigation lines.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        type: NotificationType.alert,
        iconEmoji: '⚠️',
      ),
      NotificationItem(
        id: 'notif_02',
        title: 'Connection Accepted',
        message: 'Rajesh Shinde accepted your farmer connection request.',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: NotificationType.connection,
        iconEmoji: '🤝',
      ),
      NotificationItem(
        id: 'notif_03',
        title: 'Resource Match Found',
        message: 'A 13HP Power Tiller matching your equipment request is available nearby.',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: NotificationType.resource,
        iconEmoji: '🛠',
      ),
      NotificationItem(
        id: 'notif_04',
        title: 'Community Reply',
        message: 'Anil Kumar replied to your post: "Yellowing leaves on tomato plants..."',
        timestamp: now.subtract(const Duration(hours: 4)),
        type: NotificationType.community,
        iconEmoji: '💬',
      ),
      NotificationItem(
        id: 'notif_05',
        title: 'New Farming Tip',
        message: 'Suresh Patil posted a new tip on Jeevamrutha organic soil revitalization.',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: NotificationType.community,
        iconEmoji: '🌱',
      ),
      NotificationItem(
        id: 'notif_06',
        title: 'Device Battery Healthy',
        message: 'Field 01 gateway battery reached 91% charge via solar regulator.',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.alert,
        isRead: true,
        iconEmoji: '🔋',
      ),
    ];
  }
}
