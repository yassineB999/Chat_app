import 'package:nexuschatfe/comon/ressources/data_states.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository _repository;

  LoginWithGoogle(this._repository);

  Future<DataState<AuthSession>> call({required String accessToken}) {
    return _repository.loginWithGoogleToken(accessToken: accessToken);
  }
}
