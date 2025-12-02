import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/core/utils/env.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherConfig {
  final DioClient _dioClient;
  late PusherChannelsFlutter _pusherClient;
  PusherChannel? _currentChannel;
  String? _currentRoomId;

  PusherConfig(this._dioClient);

  Future<void> init(
    String token,
    String userId,
    Function(dynamic) onEventData,
  ) async {
    _pusherClient = PusherChannelsFlutter.getInstance();

    try {
      log(
        '🔧 Initializing Pusher with key: ${Env.pusherAppKey}, cluster: ${Env.pusherAppCluster}',
      );
      await _pusherClient.init(
        apiKey: Env.pusherAppKey,
        cluster: Env.pusherAppCluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: (event) {
          log("🔥 [Pusher] Incoming Event: ${event.eventName}");
          log("🔥 [Pusher] Event Data: ${event.data}");
          log("🔥 [Pusher] Channel: ${event.channelName}");

          // Check for both simple name and fully qualified name just in case
          if (event.eventName == 'message.sent' ||
              event.eventName == 'App\\\\Events\\\\PushChatMessageEvent' ||
              event.eventName.endsWith('message.sent') ||
              event.eventName.contains('PushChatMessageEvent')) {
            log('✅ [Pusher] Message event matched, forwarding to callback');
            try {
              // Parse JSON event.data string to Map
              final Map<String, dynamic> messageData = jsonDecode(event.data);
              log('📦 [Pusher] Parsed message data: $messageData');
              onEventData(messageData);
            } catch (e) {
              log('❌ [Pusher] Error parsing event data: $e');
            }
          } else {
            log('⚠️ [Pusher] Event not matched: ${event.eventName}');
          }
        },
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onAuthorizer: (channelName, socketId, options) =>
            onAuthorizer(channelName, socketId, options, token),
      );

      await _pusherClient.connect();
      log('✅ Pusher connected successfully');
    } catch (e) {
      log("❌ Error in initialization: $e");
    }
  }

  /// Subscribe to a specific chat room channel
  Future<void> subscribeToRoom(String roomId) async {
    try {
      // Unsubscribe from previous channel if exists
      if (_currentChannel != null && _currentRoomId != null) {
        log('🔄 Unsubscribing from previous room: $_currentRoomId');
        await unsubscribeFromRoom(_currentRoomId!);
      }

      final channelName = 'private-chat.room.$roomId';
      log('📡 Subscribing to channel: $channelName');

      _currentChannel = await _pusherClient.subscribe(channelName: channelName);
      _currentRoomId = roomId;

      log('✅ Successfully subscribed to $channelName');
    } catch (e) {
      log('❌ Error subscribing to room $roomId: $e');
    }
  }

  /// Unsubscribe from a specific chat room channel
  Future<void> unsubscribeFromRoom(String roomId) async {
    try {
      final channelName = 'private-chat.room.$roomId';
      log('Unsubscribing from channel: $channelName');

      await _pusherClient.unsubscribe(channelName: channelName);

      if (_currentRoomId == roomId) {
        _currentChannel = null;
        _currentRoomId = null;
      }

      log('Successfully unsubscribed from $channelName');
    } catch (e) {
      log('Error unsubscribing from room $roomId: $e');
    }
  }

  void disconnect() {
    _pusherClient.disconnect();
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("🔗 Connection changed: $previousState -> $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("❌ Pusher Error: $message code: $code exception: $e");
  }

  void onEvent(PusherEvent event) {
    log("onEvent: $event");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("✅ Subscription succeeded: $channelName data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("❌ Subscription Error: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("❌ Decryption Failure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("👤 Member added: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("👤 Member removed: $channelName user: $member");
  }

  dynamic onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
    String token,
  ) async {
    try {
      var authUrl = "${Env.apiBaseUrl}/broadcasting/auth";
      log('🔐 Authorizing channel: $channelName with socket: $socketId');
      var result = await _dioClient.post(
        authUrl,
        data: {'socket_id': socketId, 'channel_name': channelName},
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // The Pusher library expects a Map<String, dynamic> with 'auth' key
      // or just the JSON response depending on the library version.
      // Based on the working example, it returns the auth data directly.
      log("✅ Authorization successful: ${result.data}");
      return result.data;
    } catch (e) {
      log("❌ Error in authorizer: $e");
      return {};
    }
  }

  Future<String?> getSocketId() async {
    try {
      final socketId = await _pusherClient.getSocketId();
      log('🔌 Socket ID retrieved: $socketId');
      return socketId;
    } catch (e) {
      log('❌ Error getting socket ID: $e');
      return null;
    }
  }
}
