import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/data/models/user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.token, super.user});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthSessionModel(
      token: json['token'] ?? '',
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}
