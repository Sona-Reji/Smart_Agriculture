import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../mock/mock_notifications.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal() {
    _notifications = MockNotifications.getInitialNotifications();
  }

  late List<NotificationItem> _notifications;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }
}
