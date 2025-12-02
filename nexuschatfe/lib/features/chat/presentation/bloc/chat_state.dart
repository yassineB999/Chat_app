import 'package:equatable/equatable.dart';
import 'package:nexuschatfe/features/auth/domain/entities/user_entity.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_room.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatRoomsLoading extends ChatState {}

class ChatMessagesLoading extends ChatState {}

@Deprecated('Use ChatRoomsLoading or ChatMessagesLoading')
class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> rooms;

  const ChatRoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String roomId;

  const ChatMessagesLoaded({required this.messages, required this.roomId});

  @override
  List<Object?> get props => [messages, roomId];
}

class ChatOperationSuccess extends ChatState {
  final String message;

  const ChatOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserSearchResultsLoaded extends ChatState {
  final List<UserEntity> users;

  const UserSearchResultsLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class ChatRoomCreated extends ChatState {
  final ChatRoom room;

  const ChatRoomCreated(this.room);

  @override
  List<Object?> get props => [room];
}
