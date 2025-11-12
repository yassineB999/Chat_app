import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final user = state.session.user;
              final token = state.session.token;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null
                        ? 'Welcome, ${user.name}!'
                        : 'Welcome! You are logged in.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Token: ${token.isNotEmpty ? token.substring(0, token.length > 12 ? 12 : token.length) + '...' : 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text('This is a simple home page.'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              );
            }
            return const Center(child: Text('Not authenticated'));
          },
        ),
      ),
    );
  }
}