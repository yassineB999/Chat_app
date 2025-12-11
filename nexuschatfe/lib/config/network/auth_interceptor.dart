import 'dart:async';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalService _authLocalService;

  /// Stream controller to notify about auth failures (401 errors).
  /// The AuthBloc or main app can listen to this to handle logout.
  static final StreamController<void> onAuthError =
      StreamController<void>.broadcast();

  AuthInterceptor(this._authLocalService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authLocalService.getToken();

    // Debug logging
    print('🔐 AuthInterceptor: Retrieving token...');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('✅ AuthInterceptor: Token attached - ${token.substring(0, 20)}...');
    } else {
      print('⚠️ AuthInterceptor: No token found in storage');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      print('❌ AuthInterceptor: 401 Unauthorized - Token expired or invalid');

      // Clear stored credentials on 401
      _authLocalService.logout();

      // Notify listeners (app can listen to this to handle logout)
      onAuthError.add(null);
    }

    handler.next(err);
  }

  /// Dispose the auth error stream when no longer needed
  static void dispose() {
    onAuthError.close();
  }
}
