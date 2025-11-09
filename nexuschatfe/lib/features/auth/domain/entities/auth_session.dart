import 'package:equatable/equatable.dart';
import 'package:nexuschatfe/features/auth/domain/entities/user_entity.dart';

class AuthSession extends Equatable {
  final UserEntity? user;
  final String token;

  const AuthSession({required this.token, this.user});

  @override
  List<Object?> get props => [user, token];
}
