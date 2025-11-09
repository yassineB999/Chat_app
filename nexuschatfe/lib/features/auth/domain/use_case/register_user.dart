import 'package:nexuschatfe/comon/ressources/data_states.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<DataState<String>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.register(name: name, email: email, password: password);
  }
}
