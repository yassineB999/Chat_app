import 'package:dio/dio.dart';
import 'package:nexuschatfe/comon/utils/env.dart';
import 'package:nexuschatfe/config/di/app_providers.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_apiservice.dart';

class AuthApiServiceImpl extends AuthApiservice {
  DioClient get _client => getIt<DioClient>();

  @override
  Future<Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = '${Env.apiBaseUrl}/register';
    final payload = {'name': name, 'email': email, 'password': password};
    return _client.post(url, data: payload);
  }

  @override
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    final url = '${Env.apiBaseUrl}/login';
    final payload = {'email': email, 'password': password};
    return _client.post(url, data: payload);
  }

  @override
  Future<Response> loginWithGoogleToken({required String accessToken}) async {
    final url = '${Env.apiBaseUrl}/auth/google/callback';
    return _client.post(url, data: {'access_token': accessToken});
  }

  @override
  Future<Response> logout({required String token}) async {
    final url = '${Env.apiBaseUrl}/logout';
    final options = Options(headers: {'Authorization': 'Bearer $token'});
    return _client.post(url, options: options);
  }
}
