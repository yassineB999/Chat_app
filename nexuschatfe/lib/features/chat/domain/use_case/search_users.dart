import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/auth/domain/entities/user_entity.dart';
import 'package:nexuschatfe/features/chat/domain/repository/chat_repository.dart';

class SearchUsers {
  final ChatRepository repository;

  SearchUsers(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(String query) {
    return repository.searchUsers(query);
  }
}
