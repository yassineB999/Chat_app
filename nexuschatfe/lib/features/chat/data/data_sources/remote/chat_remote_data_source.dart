import 'package:nexuschatfe/features/auth/data/models/user_model.dart';
import 'package:nexuschatfe/features/chat/data/models/chat_message_model.dart';
import 'package:nexuschatfe/features/chat/data/models/chat_room_model.dart';

import 'dart:io';

abstract class ChatRemoteDataSource {
  /// Get all chat rooms for the authenticated user
  /// Endpoint: GET /api/chat/rooms
  Future<List<ChatRoomModel>> getChatRooms();

  /// Get all messages for a specific chat room
  /// Endpoint: GET /api/chat/rooms/{roomId}/messages
  Future<List<ChatMessageModel>> getMessages(String roomId);

  /// Send a message to a chat room
  /// Endpoint: POST /api/chat/rooms/{roomId}/messages
  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String content,
    required String type,
    String? socketId,
    File? file,
  });

  /// Search for users by email
  /// Endpoint: GET /api/users/search?query={query}
  Future<List<UserModel>> searchUsers(String query);

  /// Create or get existing chat room between two users
  /// Endpoint: POST /api/chat/provide
  Future<ChatRoomModel> provideChatRoom({
    required String firstUserId,
    required String secondUserId,
  });
}
