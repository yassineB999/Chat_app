import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_room.dart';
import 'package:nexuschatfe/features/chat/domain/repository/chat_repository.dart';

class ProvideChatRoom {
  final ChatRepository repository;

  ProvideChatRoom(this.repository);

  Future<Either<Failure, ChatRoom>> call({
    required String firstUserId,
    required String secondUserId,
  }) {
    return repository.provideChatRoom(
      firstUserId: firstUserId,
      secondUserId: secondUserId,
    );
  }
}
