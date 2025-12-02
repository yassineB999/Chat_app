import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension methods for type-safe navigation using Go Router
extension AppNavigation on GoRouter {
  // Auth Navigation
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToVerifyOtp(String email) => go('/verify-otp/$email');
  void goToHome() => go('/home');

  // Chat Navigation
  void goToChat() => go('/chat');
  void goToChatRoom(String roomId, {String? roomName}) {
    final uri = Uri(
      path: '/chat/room/$roomId',
      queryParameters: roomName != null ? {'name': roomName} : null,
    );
    go(uri.toString());
  }

  void goToSearchUsers() => go('/search-users');
}

/// Simplified navigation helpers that can be used from BuildContext
/// These are convenience methods that call go_router under the hood
class AppNavigator {
  AppNavigator._();

  // Auth
  static void toLogin(BuildContext context) => context.go('/login');
  static void toRegister(BuildContext context) => context.go('/register');
  static void toVerifyOtp(BuildContext context, String email) =>
      context.go('/verify-otp/$email');
  static void toHome(BuildContext context) => context.go('/home');

  // Chat
  static void toChat(BuildContext context) => context.go('/chat');
  static Future<void> toChatRoom(
    BuildContext context,
    String roomId,
    String roomName,
  ) async {
    final uri = Uri(
      path: '/chat/room/$roomId',
      queryParameters: {'name': roomName},
    );
    await context.push(uri.toString());
  }

  static Future<void> toUserSearch(BuildContext context) async =>
      await context.push('/search-users');

  // Back navigation
  static void back(BuildContext context) => context.pop();
}
