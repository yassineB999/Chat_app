import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexuschatfe/config/routes/go_router_refresh_stream.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/home_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/login_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/register_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/splash_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/verify_otp_screen.dart';
import 'package:nexuschatfe/features/chat/presentation/pages/chat_room_screen.dart';
import 'package:nexuschatfe/features/chat/presentation/pages/user_search_screen.dart';

/// GoRouter configuration for the entire app.
///
/// This router handles all navigation and authentication-based redirects.
/// The [authBloc] is used to determine the current authentication state
/// and redirect users to the appropriate screens.
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // Redirect logic for authentication
    redirect: (context, state) {
      final authState = authBloc.state;
      final currentLocation = state.matchedLocation;

      final isOnSplash = currentLocation == '/splash';
      final isLoggingIn = currentLocation == '/login';
      final isRegistering = currentLocation == '/register';
      final isVerifyingOtp = currentLocation.startsWith('/verify-otp');
      final isOnAuthPage = isLoggingIn || isRegistering || isVerifyingOtp;

      // 1. If auth state is still being determined (AuthInitial),
      //    stay on splash screen to prevent flicker
      if (authState is AuthInitial) {
        return isOnSplash ? null : '/splash';
      }

      // 2. If authenticated -> Go to home (unless already on a protected route)
      if (authState is AuthAuthenticated) {
        if (isOnSplash || isOnAuthPage) {
          return '/home';
        }
        return null; // Stay on current protected route
      }

      // 3. If awaiting OTP verification -> Go to verify OTP screen
      if (authState is AuthAwaitingOtpVerification) {
        if (!isVerifyingOtp) {
          return '/verify-otp/${authState.email}';
        }
        return null;
      }

      // 4. If unauthenticated (AuthUnauthenticated, AuthError, AuthLoggedOut)
      //    -> Redirect to login if not already on an auth page
      if (!isOnAuthPage) {
        return '/login';
      }

      // No redirect needed
      return null;
    },

    routes: [
      // ─────────────────────────────────────────────────────────────────────
      // SPLASH ROUTE - Shown during initial auth check
      // ─────────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // AUTH ROUTES
      // ─────────────────────────────────────────────────────────────────────
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

      // ─────────────────────────────────────────────────────────────────────
      // MAIN APP ROUTES
      // ─────────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Root redirect
      GoRoute(path: '/', redirect: (context, state) => '/splash'),

      // ─────────────────────────────────────────────────────────────────────
      // CHAT ROUTES
      // ─────────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/chat',
        name: 'chat',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/chat/room/:roomId',
        name: 'chatRoom',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          final roomName = state.uri.queryParameters['name'] ?? 'Chat';
          return ChatRoomScreen(roomId: roomId, roomName: roomName);
        },
      ),

      // ─────────────────────────────────────────────────────────────────────
      // USER ROUTES
      // ─────────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/search-users',
        name: 'searchUsers',
        builder: (context, state) => const UserSearchScreen(),
      ),
    ],

    // Error handling - shown for unknown routes
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
