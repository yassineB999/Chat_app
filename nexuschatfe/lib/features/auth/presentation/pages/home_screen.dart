import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/config/routes/app_navigation.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_event.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_state.dart';
import 'package:nexuschatfe/features/chat/presentation/widgets/chat_room_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load chat rooms when Home screen initializes
    context.read<ChatBloc>().add(const LoadChatRooms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexusChat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Users',
            onPressed: () => AppNavigator.toUserSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (previous, current) {
          print(
            '🔄 [HomeScreen] State change: ${previous.runtimeType} -> ${current.runtimeType}',
          );
          return current is ChatRoomsLoading ||
              current is ChatRoomsLoaded ||
              current is ChatError;
        },
        builder: (context, state) {
          print('🏗️ [HomeScreen] Building with state: ${state.runtimeType}');
          if (state is ChatRoomsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatRoomsLoaded) {
            if (state.rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No chats yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await AppNavigator.toUserSearch(context);
                        if (context.mounted) {
                          context.read<ChatBloc>().add(const LoadChatRooms());
                        }
                      },
                      child: const Text('Start a conversation'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.rooms.length,
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                return ChatRoomItemWidget(
                  room: room,
                  onTap: () async {
                    await AppNavigator.toChatRoom(
                      context,
                      room.id.toString(),
                      room.name,
                    );
                    // Reload chat rooms when returning from chat
                    if (context.mounted) {
                      context.read<ChatBloc>().add(const LoadChatRooms());
                    }
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(const LoadChatRooms());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppNavigator.toUserSearch(context);
          if (context.mounted) {
            context.read<ChatBloc>().add(const LoadChatRooms());
          }
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
