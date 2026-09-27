import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../mock/mock_messages.dart';

class MessageService extends ChangeNotifier {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;

  MessageService._internal() {
    _chats = MockMessages.getInitialChatMap();
  }

  late Map<String, List<Message>> _chats;

  List<Message> getMessages(String farmerId) {
    return _chats[farmerId] ?? [];
  }

  void sendMessage(String farmerId, String text, {String farmerName = 'Farmer'}) {
    final now = DateTime.now();
    final newMsg = Message(
      id: 'msg_${now.millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'You',
      text: text,
      timestamp: now,
      isFromMe: true,
      isRead: true,
    );

    if (!_chats.containsKey(farmerId)) {
      _chats[farmerId] = [];
    }

    _chats[farmerId]!.add(newMsg);
    notifyListeners();

    // Friendly local mock auto-reply after 1.2 seconds to demonstrate interactive frontend
    Timer(const Duration(milliseconds: 1200), () {
      final replyOptions = [
        'Namaste! Got your message. Yes, that sounds great. Let us coordinate the timing.',
        'Thanks for reaching out! I will check the field and get back to you in a few minutes.',
        'Sounds good! Let me know when you are planning to visit or pick it up.',
        'Understood. I have noted this down. Happy to help a fellow farmer!',
      ];
      final replyText = replyOptions[now.second % replyOptions.length];

      final autoReply = Message(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        senderId: farmerId,
        senderName: farmerName,
        text: replyText,
        timestamp: DateTime.now(),
        isFromMe: false,
        isRead: true,
      );

      _chats[farmerId]?.add(autoReply);
      notifyListeners();
    });
  }
}
