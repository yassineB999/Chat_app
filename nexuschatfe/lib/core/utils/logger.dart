import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const String _prefix = '🔹';

  /// Log informational messages
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log('$_prefix $logMessage', name: 'INFO');
    }
  }

  /// Log debug messages
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log('🐛 $logMessage', name: 'DEBUG');
    }
  }

  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log(
        '❌ $logMessage',
        name: 'ERROR',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log warning messages
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log('⚠️ $logMessage', name: 'WARNING');
    }
  }

  /// Log success messages
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log('✅ $logMessage', name: 'SUCCESS');
    }
  }

  /// Log network requests
  static void network(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log('🌐 $logMessage', name: 'NETWORK');
    }
  }

  /// Log Pusher events
  static void pusher(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? '[$tag] $message' : message;
      developer.log('🔥 $logMessage', name: 'PUSHER');
    }
  }
}
