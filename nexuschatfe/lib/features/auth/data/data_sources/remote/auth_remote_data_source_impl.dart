import 'package:dio/dio.dart';
import 'package:nexuschatfe/core/utils/env.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/core/error/exceptions.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:nexuschatfe/features/auth/data/models/auth_session_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '${Env.apiBaseUrl}/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      // Laravel sometimes returns 201 for created, 200 for ok
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.post(
        '${Env.apiBaseUrl}/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return AuthSessionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Verification failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '${Env.apiBaseUrl}/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return AuthSessionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthSessionModel> loginWithGoogle({
    required String accessToken,
  }) async {
    try {
      final response = await _client.post(
        '${Env.apiBaseUrl}/auth/google',
        data: {'token': accessToken},
      );

      if (response.statusCode == 200) {
        return AuthSessionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Google login failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout({required String token}) async {
    try {
      final response = await _client.post(
        '${Env.apiBaseUrl}/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        // Even if the server complains, we usually consider logout successful locally,
        // but here we strictly throw if the server errors out.
        throw ServerException(
          message: response.data['message'] ?? 'Logout failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
