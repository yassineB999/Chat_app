import 'package:dio/dio.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/core/utils/env.dart';
import 'package:nexuschatfe/features/auth/data/models/user_model.dart';
import 'package:nexuschatfe/features/chat/data/data_sources/remote/chat_remote_data_source.dart';
import 'package:nexuschatfe/features/chat/data/models/chat_message_model.dart';
import 'package:nexuschatfe/features/chat/data/models/chat_room_model.dart';

import 'dart:io';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _client;

  ChatRemoteDataSourceImpl(this._client);

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      print('🌐 [API] GET /chat/rooms');
      final response = await _client.get('${Env.apiBaseUrl}/chat/rooms');
      print('🌐 [API] Response status: ${response.statusCode}');

      if (response.data['status'] == true) {
        final List<dynamic> roomsJson = response.data['data'];
        print('🌐 [API] Parsed ${roomsJson.length} rooms');
        return roomsJson.map((json) => ChatRoomModel.fromJson(json)).toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to get chat rooms',
      );
    } catch (e) {
      print('❌ [API] Error getting chat rooms: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId) async {
    try {
      final response = await _client.get(
        '${Env.apiBaseUrl}/chat/rooms/$roomId/messages',
      );

      if (response.data['status'] == true) {
        final List<dynamic> messagesJson = response.data['data'];
        return messagesJson
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to get messages',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String content,
    required String type,
    String? socketId,
    File? file,
  }) async {
    try {
      dynamic data;

      if (file != null) {
        String fileName = file.path.split('/').last;
        data = FormData.fromMap({
          'content': content,
          'type': type,
          'file': await MultipartFile.fromFile(file.path, filename: fileName),
        });
      } else {
        data = {'content': content, 'type': type};
      }

      final response = await _client.post(
        '${Env.apiBaseUrl}/chat/rooms/$roomId/messages',
        data: data,
        options: socketId != null
            ? Options(headers: {'X-Socket-ID': socketId})
            : null,
      );

      if (response.data['status'] == true) {
        return ChatMessageModel.fromJson(response.data['data']);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to send message',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _client.get(
        '${Env.apiBaseUrl}/users/search',
        queryParameters: {'query': query},
      );

      if (response.data['status'] == true) {
        final List<dynamic> usersJson = response.data['data'];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to search users',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChatRoomModel> provideChatRoom({
    required String firstUserId,
    required String secondUserId,
  }) async {
    try {
      final response = await _client.post(
        '${Env.apiBaseUrl}/chat/provide',
        data: {'first_user': firstUserId, 'second_user': secondUserId},
      );

      if (response.data['status'] == true) {
        return ChatRoomModel.fromJson(response.data['data']);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to provide chat room',
      );
    } catch (e) {
      rethrow;
    }
  }
}
