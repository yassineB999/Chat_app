import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSession>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSession>> loginWithGoogleToken({
    required String accessToken,
  });

  Future<Either<Failure, bool>> logout({required String token});

  Future<bool> isLoggedIn();
}
