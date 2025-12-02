import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class LogoutUser {
  final AuthRepository _repository;

  LogoutUser(this._repository);

  Future<Either<Failure, bool>> call({required String token}) {
    return _repository.logout(token: token);
  }
}
