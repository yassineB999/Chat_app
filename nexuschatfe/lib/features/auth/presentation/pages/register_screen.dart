import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/app_text_field.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  // ✨ BEST PRACTICE: Use const constructors.
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // ✨ BEST PRACTICE: Dispose all controllers.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() != true) return;

    context.read<AuthBloc>().add(
      RegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✨ CORRECTED: No BlocProvider here.
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
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
                SnackBar(content: Text('Account created successfully!')),
              );
          }
        },
        builder: (context, state) {
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
                        controller: _nameController,
                        label: 'Name',
                        hint: 'Jane Doe',
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
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
                        hint: 'Create a password',
                        obscure: true,
                        validator: (v) => (v?.length ?? 0) < 6
                            ? 'Minimum 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Create Account',
                        loading: isLoading,
                        onPressed: _onRegisterPressed,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            // ✨ BEST PRACTICE: Use pop() to go back to the previous screen.
                            : () => Navigator.of(context).pop(),
                        child: const Text('Already have an account? Sign In'),
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
