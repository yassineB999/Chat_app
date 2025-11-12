import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository _repository;

  LoginWithGoogle(this._repository);

  Future<Either<DioException, AuthSession>> call({
    required String accessToken,
  }) {
    return _repository.loginWithGoogleToken(accessToken: accessToken);
  }
}
