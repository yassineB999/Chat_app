import 'package:equatable/equatable.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';

class ChatRoom extends Equatable {
  final int id;
  final String name;
  final String email;
  final ChatMessage? lastMessage;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.email,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [id, name, email, lastMessage];
}
