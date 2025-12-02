import 'package:dio/dio.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalService _authLocalService;

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
}
