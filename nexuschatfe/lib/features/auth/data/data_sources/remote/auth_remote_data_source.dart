import 'package:nexuschatfe/features/auth/data/models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSessionModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> loginWithGoogle({required String accessToken});

  Future<void> logout({required String token});
}
