import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final int id;
  final int senderId;
  final String content;
  final String type; // TEXT, IMAGE, FILE, RECORD
  final DateTime timestamp;
  final String? senderName;
  final String? senderEmail;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.senderName,
    this.senderEmail,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    content,
    type,
    timestamp,
    senderName,
    senderEmail,
  ];
}
