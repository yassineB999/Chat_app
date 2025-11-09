import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/app_text_field.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/primary_button.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/google_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to NexusChat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return AbsorbPointer(
            absorbing: isLoading,
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onSubmit: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<AuthBloc>().add(LoginRequested(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ));
                        }
                      },
                      onGoogle: () {
                        // In a real app, you'd obtain the Google access token here
                        context.read<AuthBloc>().add(const GoogleLoginRequested(accessToken: 'mock_access_token'));
                      },
                      loading: isLoading,
                    ),
                    _RegisterForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onSubmit: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<AuthBloc>().add(RegisterRequested(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ));
                        }
                      },
                      loading: isLoading,
                    ),
                  ],
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final bool loading;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onGoogle,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: emailController,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Email is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: passwordController,
              label: 'Password',
              hint: '••••••••',
              obscure: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Login', onPressed: onSubmit, loading: loading),
            const SizedBox(height: 12),
            GoogleButton(onPressed: onGoogle, loading: loading),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool loading;

  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: nameController,
                label: 'Name',
                hint: 'Jane Doe',
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailController,
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordController,
                label: 'Password',
                hint: '••••••••',
                obscure: true,
                validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Create Account', onPressed: onSubmit, loading: loading),
            ],
          ),
        ),
      ),
    );
  }
}