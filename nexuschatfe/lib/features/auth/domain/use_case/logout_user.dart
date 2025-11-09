import 'package:nexuschatfe/comon/ressources/data_states.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class LogoutUser {
  final AuthRepository _repository;

  LogoutUser(this._repository);

  Future<DataState<bool>> call({required String token}) {
    return _repository.logout(token: token);
  }
}
