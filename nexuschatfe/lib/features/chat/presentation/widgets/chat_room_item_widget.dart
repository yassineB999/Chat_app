import 'package:flutter/material.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_room.dart';

class ChatRoomItemWidget extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const ChatRoomItemWidget({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = room.lastMessage;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          room.name.isNotEmpty ? room.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        room.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: lastMessage != null
          ? Text(
              _getLastMessageText(lastMessage.content, lastMessage.type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            )
          : const Text(
              'No messages yet',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
      trailing: lastMessage != null
          ? Text(
              _formatTime(lastMessage.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            )
          : null,
    );
  }

  String _getLastMessageText(String content, String type) {
    switch (type) {
      case 'IMAGE':
        return '📷 Image';
      case 'FILE':
        return '📎 File';
      case 'RECORD':
        return '🎤 Audio';
      default:
        return content;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
