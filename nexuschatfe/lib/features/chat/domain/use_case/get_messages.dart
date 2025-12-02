import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/domain/repository/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Future<Either<Failure, List<ChatMessage>>> call(String roomId) {
    return repository.getMessages(roomId);
  }
}
