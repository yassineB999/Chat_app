import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexuschatfe/core/services/media_picker_service.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_event.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/audio_recorder.dart';

class SendMessageWidget extends StatefulWidget {
  final String roomId;

  const SendMessageWidget({super.key, required this.roomId});

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  final TextEditingController _controller = TextEditingController();

  File? _selectedImage;
  File? _selectedFile;
  bool _showAudioRecorder = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    if (_hasText || _selectedImage != null || _selectedFile != null) {
      String type = 'TEXT';
      File? file;

      if (_selectedImage != null) {
        type = 'IMAGE';
        file = _selectedImage;
      } else if (_selectedFile != null) {
        type = 'FILE';
        file = _selectedFile;
      }

      context.read<ChatBloc>().add(
        SendMessageEvent(
          roomId: widget.roomId,
          content: _controller.text.trim(),
          type: type,
          file: file,
        ),
      );

      _clearState();
    }
  }

  void _sendAudioMessage(String path) {
    context.read<ChatBloc>().add(
      SendMessageEvent(
        roomId: widget.roomId,
        content: 'Audio Message',
        type: 'AUDIO',
        file: File(path),
      ),
    );

    setState(() {
      _showAudioRecorder = false;
    });
  }

  void _clearState() {
    _controller.clear();
    setState(() {
      _selectedImage = null;
      _selectedFile = null;
      _hasText = false;
    });
  }

  Future<void> _pickImage() async {
    final file = await MediaPickerService.pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImage = file;
        _selectedFile = null;
      });
    }
  }

  Future<void> _pickFile() async {
    final file = await MediaPickerService.pickDocument();
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _selectedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preview Area
        if (_selectedImage != null || _selectedFile != null)
          _buildPreviewArea(theme),

        // Audio Recorder
        if (_showAudioRecorder) AudioRecorderWidget(onStop: _sendAudioMessage),

        // Input Area
        if (!_showAudioRecorder)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment buttons
                  if (!_hasText &&
                      _selectedImage == null &&
                      _selectedFile == null) ...[
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.blue),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: _pickFile,
                    ),
                  ],

                  // Text field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send/Mic button
                  if (_hasText ||
                      _selectedImage != null ||
                      _selectedFile != null)
                    FloatingActionButton(
                      mini: true,
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send, size: 20),
                    )
                  else
                    FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        setState(() {
                          _showAudioRecorder = true;
                        });
                      },
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.mic, size: 20),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: Stack(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (_selectedFile != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    size: 40,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: _clearState,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
