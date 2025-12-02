class AppConstants {
  AppConstants._();

  // API Constants
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRedirects = 5;
  static const int imageQuality = 70;

  // Pusher Event Names
  static const String pusherMessageSentEvent = 'message.sent';
  static const String pusherMessageEventClass =
      'App\\\\Events\\\\PushChatMessageEvent';

  // Channel Prefixes
  static const String privateChatChannelPrefix = 'private-chat.room.';

  // Broadcast Auth Endpoint
  static const String broadcastAuthEndpoint = '/broadcasting/auth';

  // File Extensions
  static const List<String> documentExtensions = ['pdf', 'doc', 'docx'];

  // UI Constants
  static const Duration toastDuration = Duration(seconds: 4);
  static const double defaultBorderRadius = 12.0;
  static const double defaultSpacing = 16.0;

  // Cache
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxMessageLength = 5000;
}
