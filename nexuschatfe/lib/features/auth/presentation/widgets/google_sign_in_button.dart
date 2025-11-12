import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/auth/domain/repository/google_auth_repository.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool loading;

  const GoogleSignInButton({Key? key, this.loading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: loading
            ? null
            : () async {
                final token = await GoogleAuthRepository.signInAndGetAccessToken();
                if (token == null || token.isEmpty) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Google sign-in cancelled or failed'),
                      ),
                    );
                  return;
                }
                context.read<AuthBloc>().add(
                      GoogleLoginRequested(accessToken: token),
                    );
              },
        icon: Image.asset(
          'assets/google_logo.png',
          width: 18,
          height: 18,
          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata),
        ),
        label: const Text('Continue with Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.black12),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
