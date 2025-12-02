import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.type,
    required super.timestamp,
    super.senderName,
    super.senderEmail,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Parse sender info if available
    final sender = json['sender'] as Map<String, dynamic>?;

    // Handle both API response format and broadcast event format
    // API: {id, senderId, content, type, timestamp, sender: {name, email}}
    // Broadcast: {id, chat_room_id, user_id, content, type, created_at}

    return ChatMessageModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'] ?? 0,
      senderId: json['senderId'] is String
          ? int.tryParse(json['senderId']) ?? 0
          : json['senderId'] ?? json['user_id'] ?? 0,
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      timestamp: _parseTimestamp(json['timestamp'] ?? json['created_at']),
      senderName: sender?['name'],
      senderEmail: sender?['email'],
    );
  }

  /// Parse timestamp from various formats
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      if (senderName != null || senderEmail != null)
        'sender': {'name': senderName, 'email': senderEmail},
    };
  }

  /// Convert domain entity to model
  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      senderId: message.senderId,
      content: message.content,
      type: message.type,
      timestamp: message.timestamp,
      senderName: message.senderName,
      senderEmail: message.senderEmail,
    );
  }
}
