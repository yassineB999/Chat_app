import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/domain/repository/chat_repository.dart';

import 'dart:io';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, ChatMessage>> call({
    required String roomId,
    required String content,
    required String type,
    String? socketId,
    File? file,
  }) {
    return repository.sendMessage(
      roomId: roomId,
      content: content,
      type: type,
      socketId: socketId,
      file: file,
    );
  }
}
