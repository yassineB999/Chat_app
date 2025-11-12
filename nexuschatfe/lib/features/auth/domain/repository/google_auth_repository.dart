import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthRepository {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await GoogleSignIn.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In initialization error: $e');
      }
    }
  }

  static Future<String?> signInAndGetAccessToken() async {
    await initialize();

    try {
      final Completer<GoogleSignInAccount?> completer =
          Completer<GoogleSignInAccount?>();

      StreamSubscription<GoogleSignInAuthenticationEvent>? subscription;
      subscription = GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          subscription?.cancel();
          completer.complete(event.user);
        }
      });

      // Trigger the Google Sign-In UI
      await GoogleSignIn.instance.authenticate();

      // Wait for the sign-in event to complete
      final GoogleSignInAccount? googleUser = await completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          subscription?.cancel();
          return null; // User took too long or closed the dialog
        },
      );

      // User cancelled the flow
      if (googleUser == null) {
        subscription.cancel();
        return null;
      }

      // These scopes are required to get the user's email and profile
      const List<String> scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ];

      // Get the authorization headers containing the access token
      final Map<String, String>? headers = await googleUser.authorizationClient
          .authorizationHeaders(scopes);

      if (headers == null) return null;

      // Extract the token from the 'Authorization: Bearer <TOKEN>' header
      final String? authHeader =
          headers['Authorization'] ?? headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        return authHeader.substring(7);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred during Google sign-in: $e');
      }
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out from Google: $e');
      }
    }
  }
}
