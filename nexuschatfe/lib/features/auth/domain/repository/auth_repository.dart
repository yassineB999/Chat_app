import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<DioException, String>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<DioException, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<DioException, AuthSession>> loginWithGoogleToken({
    required String accessToken,
  });

  Future<Either<DioException, bool>> logout({required String token});

  Future<bool> isLoggedIn();
}
