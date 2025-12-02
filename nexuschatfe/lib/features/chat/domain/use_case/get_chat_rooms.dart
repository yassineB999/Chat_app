import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_room.dart';
import 'package:nexuschatfe/features/chat/domain/repository/chat_repository.dart';

class GetChatRooms {
  final ChatRepository repository;

  GetChatRooms(this.repository);

  Future<Either<Failure, List<ChatRoom>>> call() {
    return repository.getChatRooms();
  }
}
