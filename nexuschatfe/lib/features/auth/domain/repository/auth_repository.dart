import 'package:nexuschatfe/comon/ressources/data_states.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<DataState<String>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<DataState<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<DataState<AuthSession>> loginWithGoogleToken({
    required String accessToken,
  });

  Future<DataState<bool>> logout({required String token});
}
