import 'package:dio/dio.dart';
import 'package:nexuschatfe/comon/utils/env.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  Future<Response> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _dio.post(
      '/register',
      data: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<Response> login({required String email, required String password}) {
    return _dio.post('/login', data: {'email': email, 'password': password});
  }

  Future<Response> loginWithGoogleToken({required String accessToken}) {
    return _dio.post(
      '/auth/google/callback',
      data: {'access_token': accessToken},
    );
  }

  Future<Response> logout({required String token}) {
    return _dio.post(
      '/logout',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
