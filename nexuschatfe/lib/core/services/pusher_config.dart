import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/core/constants/app_constants.dart';
import 'package:nexuschatfe/core/utils/env.dart';
import 'package:nexuschatfe/core/utils/logger.dart';
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
      AppLogger.pusher(
        'Initializing Pusher with key: ${Env.pusherAppKey}, cluster: ${Env.pusherAppCluster}',
      );

      await _pusherClient.init(
        apiKey: Env.pusherAppKey,
        cluster: Env.pusherAppCluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: (event) {
          AppLogger.pusher('Incoming Event: ${event.eventName}');
          AppLogger.debug('Event Data: ${event.data}', tag: 'Pusher');
          AppLogger.debug('Channel: ${event.channelName}', tag: 'Pusher');

          // Check if this is a message event
          if (_isMessageEvent(event.eventName)) {
            AppLogger.success(
              'Message event matched, forwarding to callback',
              tag: 'Pusher',
            );
            try {
              // Parse JSON event.data string to Map
              final Map<String, dynamic> messageData = jsonDecode(event.data);
              AppLogger.debug(
                'Parsed message data: $messageData',
                tag: 'Pusher',
              );
              onEventData(messageData);
            } catch (e) {
              AppLogger.error(
                'Error parsing event data',
                tag: 'Pusher',
                error: e,
              );
            }
          } else {
            AppLogger.warning(
              'Event not matched: ${event.eventName}',
              tag: 'Pusher',
            );
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
      AppLogger.success('Pusher connected successfully', tag: 'Pusher');
    } catch (e) {
      AppLogger.error('Error in initialization', tag: 'Pusher', error: e);
    }
  }

  /// Helper method to check if event name matches message event patterns
  bool _isMessageEvent(String eventName) {
    return eventName == AppConstants.pusherMessageSentEvent ||
        eventName == AppConstants.pusherMessageEventClass ||
        eventName.endsWith(AppConstants.pusherMessageSentEvent) ||
        eventName.contains('PushChatMessageEvent');
  }

  /// Subscribe to a specific chat room channel
  Future<void> subscribeToRoom(String roomId) async {
    try {
      // Unsubscribe from previous channel if exists
      if (_currentChannel != null && _currentRoomId != null) {
        AppLogger.info(
          'Unsubscribing from previous room: $_currentRoomId',
          tag: 'Pusher',
        );
        await unsubscribeFromRoom(_currentRoomId!);
      }

      final channelName = '${AppConstants.privateChatChannelPrefix}$roomId';
      AppLogger.network('Subscribing to channel: $channelName', tag: 'Pusher');

      _currentChannel = await _pusherClient.subscribe(channelName: channelName);
      _currentRoomId = roomId;

      AppLogger.success(
        'Successfully subscribed to $channelName',
        tag: 'Pusher',
      );
    } catch (e) {
      AppLogger.error(
        'Error subscribing to room $roomId',
        tag: 'Pusher',
        error: e,
      );
    }
  }

  /// Unsubscribe from a specific chat room channel
  Future<void> unsubscribeFromRoom(String roomId) async {
    try {
      final channelName = '${AppConstants.privateChatChannelPrefix}$roomId';
      AppLogger.info('Unsubscribing from channel: $channelName', tag: 'Pusher');

      await _pusherClient.unsubscribe(channelName: channelName);

      if (_currentRoomId == roomId) {
        _currentChannel = null;
        _currentRoomId = null;
      }

      AppLogger.success(
        'Successfully unsubscribed from $channelName',
        tag: 'Pusher',
      );
    } catch (e) {
      AppLogger.error(
        'Error unsubscribing from room $roomId',
        tag: 'Pusher',
        error: e,
      );
    }
  }

  void disconnect() {
    _pusherClient.disconnect();
    AppLogger.info('Pusher disconnected', tag: 'Pusher');
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    AppLogger.network(
      'Connection changed: $previousState → $currentState',
      tag: 'Pusher',
    );
  }

  void onError(String message, int? code, dynamic e) {
    AppLogger.error(
      'Pusher Error: $message (code: $code)',
      tag: 'Pusher',
      error: e,
    );
  }

  void onEvent(PusherEvent event) {
    AppLogger.debug('onEvent: $event', tag: 'Pusher');
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    AppLogger.success('Subscription succeeded: $channelName', tag: 'Pusher');
  }

  void onSubscriptionError(String message, dynamic e) {
    AppLogger.error('Subscription Error: $message', tag: 'Pusher', error: e);
  }

  void onDecryptionFailure(String event, String reason) {
    AppLogger.error(
      'Decryption Failure: $event (reason: $reason)',
      tag: 'Pusher',
    );
  }

  void onMemberAdded(String channelName, PusherMember member) {
    AppLogger.debug('Member added to $channelName: $member', tag: 'Pusher');
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    AppLogger.debug('Member removed from $channelName: $member', tag: 'Pusher');
  }

  dynamic onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
    String token,
  ) async {
    try {
      var authUrl = "${Env.apiBaseUrl}${AppConstants.broadcastAuthEndpoint}";
      AppLogger.network(
        'Authorizing channel: $channelName with socket: $socketId',
        tag: 'Pusher',
      );

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

      AppLogger.success(
        'Authorization successful: ${result.data}',
        tag: 'Pusher',
      );
      return result.data;
    } catch (e) {
      AppLogger.error('Error in authorizer', tag: 'Pusher', error: e);
      return {};
    }
  }

  Future<String?> getSocketId() async {
    try {
      final socketId = await _pusherClient.getSocketId();
      AppLogger.debug('Socket ID retrieved: $socketId', tag: 'Pusher');
      return socketId;
    } catch (e) {
      AppLogger.error('Error getting socket ID', tag: 'Pusher', error: e);
      return null;
    }
  }
}
