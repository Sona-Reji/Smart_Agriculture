import '../models/message.dart';

class MockMessages {
  static Map<String, List<Message>> getInitialChatMap() {
    final now = DateTime.now();

    return {
      'farmer_01': [
        Message(
          id: 'm1',
          senderId: 'me',
          senderName: 'You',
          text: 'Namaste Rajesh bhai, do you have a power tiller available for rent tomorrow?',
          timestamp: now.subtract(const Duration(minutes: 45)),
          isFromMe: true,
        ),
        Message(
          id: 'm2',
          senderId: 'farmer_01',
          senderName: 'Rajesh Shinde',
          text: 'Namaste! Yes, it is fully serviced and available from 8 AM tomorrow.',
          timestamp: now.subtract(const Duration(minutes: 38)),
          isFromMe: false,
        ),
        Message(
          id: 'm3',
          senderId: 'me',
          senderName: 'You',
          text: 'Great, I need it for bed preparation in Field 01. Will pick it up in the morning.',
          timestamp: now.subtract(const Duration(minutes: 25)),
          isFromMe: true,
        ),
        Message(
          id: 'm4',
          senderId: 'farmer_01',
          senderName: 'Rajesh Shinde',
          text: 'Sure, I will keep the furrower attachment fitted for you.',
          timestamp: now.subtract(const Duration(minutes: 20)),
          isFromMe: false,
        ),
      ],
      'farmer_03': [
        Message(
          id: 'm5',
          senderId: 'farmer_03',
          senderName: 'Anil Kumar',
          text: 'Hello! I noticed your alert about low soil moisture. Did you get the pump started?',
          timestamp: now.subtract(const Duration(hours: 3)),
          isFromMe: false,
        ),
        Message(
          id: 'm6',
          senderId: 'me',
          senderName: 'You',
          text: 'Yes Anil, scheduled the drip cycle right now. Thanks for checking in!',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 40)),
          isFromMe: true,
        ),
      ],
      'farmer_06': [
        Message(
          id: 'm7',
          senderId: 'farmer_06',
          senderName: 'Meena Rathod',
          text: 'Hey! The capsicum plug seedlings you asked about will be ready for pickup Friday.',
          timestamp: now.subtract(const Duration(hours: 6)),
          isFromMe: false,
        ),
      ],
    };
  }
}
