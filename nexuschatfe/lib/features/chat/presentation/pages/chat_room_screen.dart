import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_event.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_state.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/messages_list_widget.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/send_message_widget.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store reference to ChatBloc to use in dispose
    _chatBloc = context.read<ChatBloc>();
  }

  @override
  void initState() {
    super.initState();
    // Schedule events to run after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatBloc.add(LoadMessages(widget.roomId));
      _chatBloc.add(SubscribeToChatChannel(widget.roomId));
    });
  }

  @override
  void dispose() {
    // Safe to use _chatBloc here since it was stored in didChangeDependencies
    _chatBloc.add(UnsubscribeFromChatChannel(widget.roomId));
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currentUserId =
              authState is AuthAuthenticated && authState.session.user != null
              ? authState.session.user!.id.toString()
              : '';

          return Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is ChatMessagesLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                    }
                  },
                  buildWhen: (previous, current) =>
                      current is ChatMessagesLoading ||
                      current is ChatMessagesLoaded ||
                      current is ChatError,
                  builder: (context, state) {
                    if (state is ChatMessagesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatMessagesLoaded) {
                      return MessagesListWidget(
                        messages: state.messages,
                        currentUserId: currentUserId,
                        receiverName: widget.roomName,
                        scrollController: _scrollController,
                      );
                    } else if (state is ChatError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              SendMessageWidget(roomId: widget.roomId),
            ],
          );
        },
      ),
    );
  }
}
