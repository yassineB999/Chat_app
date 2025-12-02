import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexuschatfe/core/utils/env.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/audio_message.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiverMessageItemWidget extends StatelessWidget {
  final ChatMessage message;
  final String receiverName;

  const ReceiverMessageItemWidget({
    super.key,
    required this.message,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
            child: Text(
              receiverName.isNotEmpty ? receiverName[0].toUpperCase() : '?',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for sender messages
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;

    switch (message.type) {
      case 'IMAGE':
        final imageUrl = _getFullUrl(message.content);
        print('🖼️ [ReceiverMessage] Displaying image: $imageUrl');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) {
                  print(
                    '❌ [ReceiverMessage] Image error: $error for URL: $url',
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(height: 4),
                      Text(
                        'Failed to load image',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                },
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
          ],
        );
      case 'FILE':
        final fileUrl = _getFullUrl(message.content);
        return InkWell(
          onTap: () async {
            final uri = Uri.parse(fileUrl);
            try {
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                print('Could not launch $fileUrl');
                // Fallback: try platform default
                await launchUrl(uri);
              }
            } catch (e) {
              print('Error launching URL: $e');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.grey),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'File Attachment',
                  style: style?.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        );
      case 'AUDIO':
        final audioUrl = _getFullUrl(message.content);
        print('🎵 [ReceiverMessage] Audio URL: $audioUrl');
        return SizedBox(width: 200, child: AudioMessage(source: audioUrl));
      default:
        return Text(message.content, style: style);
    }
  }

  /// Converts relative URLs to full URLs by prepending the base URL
  String _getFullUrl(String content) {
    // If content already has http/https, return as is
    if (content.startsWith('http://') || content.startsWith('https://')) {
      return content;
    }
    // If content is a relative path, prepend the base URL
    final baseUrl = Env.apiBaseUrl;
    // Remove leading slash if present to avoid double slashes
    final path = content.startsWith('/') ? content.substring(1) : content;
    return '$baseUrl/$path';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
