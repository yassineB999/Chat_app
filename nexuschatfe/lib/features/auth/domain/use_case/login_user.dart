import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<Either<DioException, AuthSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
