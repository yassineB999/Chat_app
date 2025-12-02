import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/config/routes/app_navigation.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_event.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_state.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      context.read<ChatBloc>().add(SearchUsersEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _onSearchChanged,
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatRoomCreated) {
            AppNavigator.toChatRoom(
              context,
              state.room.id.toString(),
              state.room.name,
            );
          } else if (state is ChatError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        buildWhen: (previous, current) =>
            current is ChatLoading ||
            current is UserSearchResultsLoaded ||
            current is ChatError,
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserSearchResultsLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[0].toUpperCase()),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated &&
                        authState.session.user != null) {
                      context.read<ChatBloc>().add(
                        CreateChatRoom(
                          currentUserId: authState.session.user!.id.toString(),
                          otherUserId: user.id.toString(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You must be logged in')),
                      );
                    }
                  },
                );
              },
            );
          }
          return const Center(
            child: Text('Search for users to start chatting'),
          );
        },
      ),
    );
  }
}
