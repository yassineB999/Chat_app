import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/auth/domain/entities/user_entity.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_room.dart';

import 'dart:io';

abstract class ChatRepository {
  /// Get all chat rooms for the authenticated user
  Future<Either<Failure, List<ChatRoom>>> getChatRooms();

  /// Get all messages for a specific chat room
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId);

  /// Send a message to a chat room
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String roomId,
    required String content,
    required String type,
    String? socketId,
    File? file,
  });

  /// Search for users by email
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);

  /// Create or get existing chat room between two users
  Future<Either<Failure, ChatRoom>> provideChatRoom({
    required String firstUserId,
    required String secondUserId,
  });
}
