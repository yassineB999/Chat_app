import 'package:flutter/material.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/receiver_message_item_widget.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/sender_message_item_widget.dart';

class MessagesListWidget extends StatelessWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final String receiverName;
  final ScrollController scrollController;

  const MessagesListWidget({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.receiverName,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start the conversation!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId.toString() == currentUserId;

        if (isMe) {
          return SenderMessageItemWidget(message: message);
        } else {
          return ReceiverMessageItemWidget(
            message: message,
            receiverName: receiverName,
          );
        }
      },
    );
  }
}
