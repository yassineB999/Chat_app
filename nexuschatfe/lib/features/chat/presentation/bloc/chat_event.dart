import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRooms extends ChatEvent {
  const LoadChatRooms();
}

class LoadMessages extends ChatEvent {
  final String roomId;

  const LoadMessages(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SendMessageEvent extends ChatEvent {
  final String roomId;
  final String content;
  final String type;
  final File? file;

  const SendMessageEvent({
    required this.roomId,
    this.content = '',
    required this.type,
    this.file,
  });

  @override
  List<Object?> get props => [roomId, content, type, file];
}

class ReceiveMessage extends ChatEvent {
  final Map<String, dynamic> messageData;

  const ReceiveMessage(this.messageData);

  @override
  List<Object?> get props => [messageData];
}

class SearchUsersEvent extends ChatEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateChatRoom extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  const CreateChatRoom({
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [currentUserId, otherUserId];
}

class SubscribeToChatChannel extends ChatEvent {
  final String roomId;

  const SubscribeToChatChannel(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class UnsubscribeFromChatChannel extends ChatEvent {
  final String roomId;

  const UnsubscribeFromChatChannel(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Reset chat state to initial state (useful for navigation)
class ResetChatState extends ChatEvent {
  const ResetChatState();
}
