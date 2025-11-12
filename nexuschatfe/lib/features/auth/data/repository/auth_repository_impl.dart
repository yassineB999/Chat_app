import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/config/di/app_providers.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_apiservice.dart';
import 'package:nexuschatfe/features/auth/data/models/auth_session_model.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthApiservice get _api => getIt<AuthApiservice>();
  AuthLocalService get _local => getIt<AuthLocalService>();

  @override
  Future<Either<DioException, bool>> logout({required String token}) async {
    try {
      final Response response = await _api.logout(token: token);
      final success = response.statusCode == 200 || response.statusCode == 204;
      if (success) {
        await _local.logout();
      }
      return Right(success);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<DioException, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await _api.login(
        email: email,
        password: password,
      );
      final session = AuthSessionModel.fromJson(
        response.data is Map<String, dynamic> ? response.data : {},
      );
      if (session.token.isNotEmpty) {
        await _local.saveToken(session.token);
      }
      return Right(session);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<DioException, AuthSession>> loginWithGoogleToken({
    required String accessToken,
  }) async {
    try {
      final Response response = await _api.loginWithGoogleToken(
        accessToken: accessToken,
      );
      final session = AuthSessionModel.fromJson(
        response.data is Map<String, dynamic> ? response.data : {},
      );
      if (session.token.isNotEmpty) {
        await _local.saveToken(session.token);
      }
      return Right(session);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<DioException, String>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await _api.register(
        name: name,
        email: email,
        password: password,
      );
      final data = response.data;
      final token = data is Map<String, dynamic>
          ? (data['token'] as String? ?? '')
          : '';
      if (token.isEmpty) {
        return Left(DioException(
          requestOptions: RequestOptions(path: '/register'),
          response: response,
          message:
              'Registration succeeded but no token was returned (status ${response.statusCode}).',
        ));
      }
      await _local.saveToken(token);
      return Right(token);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<bool> isLoggedIn() {
    return _local.isLoggedIn();
  }
}
