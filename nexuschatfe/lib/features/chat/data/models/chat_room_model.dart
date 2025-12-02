import 'package:nexuschatfe/features/chat/data/models/chat_message_model.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.name,
    required super.email,
    super.lastMessage,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    ChatMessageModel? lastMsg;

    if (json['lastMessage'] != null) {
      lastMsg = ChatMessageModel.fromJson(json['lastMessage']);
    }

    return ChatRoomModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      lastMessage: lastMsg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (lastMessage != null)
        'lastMessage': ChatMessageModel.fromEntity(lastMessage!).toJson(),
    };
  }

  /// Convert domain entity to model
  factory ChatRoomModel.fromEntity(ChatRoom room) {
    return ChatRoomModel(
      id: room.id,
      name: room.name,
      email: room.email,
      lastMessage: room.lastMessage,
    );
  }
}
