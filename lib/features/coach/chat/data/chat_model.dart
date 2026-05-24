import 'package:gym_app/core/enums/messages_tab.dart';

class CoachChatMessage {
  final String name;
  final String message;
  final MessageType type;
  final String time;
  final int? senderId;

  CoachChatMessage({
    required this.name,
    required this.message,
    required this.type,
    required this.time,
    this.senderId,
  });

  factory CoachChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    return CoachChatMessage(
      senderId: json['sender_id'] as int?,
      name: sender['name'] as String? ?? 'Member',
      message: json['body'] as String? ?? '',
      type: MessageType.member,
      time: _formatTime(json['sent_at'] as String?),
    );
  }

  static String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return 'Yesterday';
    } catch (_) {
      return '';
    }
  }
}
