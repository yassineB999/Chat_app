import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexuschatfe/config/routes/go_router_refresh_stream.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/home_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/login_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/register_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/verify_otp_screen.dart';
import 'package:nexuschatfe/features/chat/presentation/pages/chat_room_screen.dart';
import 'package:nexuschatfe/features/chat/presentation/pages/user_search_screen.dart';

/// GoRouter configuration for the entire app
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // Redirect logic for authentication
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;

      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isVerifyingOtp = state.matchedLocation.startsWith('/verify-otp');
      final isOnAuthPage = isLoggingIn || isRegistering || isVerifyingOtp;

      // 1. If not logged in and not on auth page -> Redirect to Login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // 2. If logged in and on auth page -> Redirect to Home
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }

      // 3. If awaiting OTP -> Redirect to Verify OTP (if not already there)
      if (authState is AuthAwaitingOtpVerification && !isVerifyingOtp) {
        return '/verify-otp/${authState.email}';
      }

      // No redirect needed
      return null;
    },

    routes: [
      // Root - redirect based on auth status
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final authState = authBloc.state;
          return (authState is AuthAuthenticated) ? '/home' : '/login';
        },
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-otp/:email',
        name: 'verifyOtp',
        builder: (context, state) {
          final email = state.pathParameters['email'] ?? '';
          return VerifyOtpScreen(email: email);
        },
      ),

      // Home Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Chat Routes
      GoRoute(
        path: '/chat',
        name: 'chat',
        redirect: (context, state) => '/home', // Redirect /chat to /home
      ),

      // Chat Room Route
      GoRoute(
        path: '/chat/room/:roomId',
        name: 'chatRoom',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          final roomName = state.uri.queryParameters['name'] ?? 'Chat';
          return ChatRoomScreen(roomId: roomId, roomName: roomName);
        },
      ),

      // User Search Route
      GoRoute(
        path: '/search-users',
        name: 'searchUsers',
        builder: (context, state) => const UserSearchScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
