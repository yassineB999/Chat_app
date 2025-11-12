import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<Either<DioException, String>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.register(name: name, email: email, password: password);
  }
}
