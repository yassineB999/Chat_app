import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/register_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/app_text_field.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  // ✨ BEST PRACTICE: Use const constructors for widgets.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // ✨ BEST PRACTICE: Always dispose controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    // ✨ BEST PRACTICE: Keep button callbacks clean. Validate and send event.
    if (_formKey.currentState?.validate() != true) return;

    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✨ CORRECTED: No BlocProvider here. This screen consumes the BLoC
    // that was provided in `main.dart`.
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // This listener handles one-time actions (side effects).
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AuthAuthenticated) {
            // In a real app, you would navigate to a home screen here.
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Signed in successfully!')),
              );
          }
        },
        builder: (context, state) {
          // This builder rebuilds the UI based on the state.
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Your password',
                        obscure: true,
                        validator: (v) => (v?.length ?? 0) < 6
                            ? 'Minimum 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Sign In',
                        loading: isLoading,
                        onPressed: _onLoginPressed,
                      ),
                      const SizedBox(height: 12),
                      GoogleSignInButton(loading: isLoading),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
