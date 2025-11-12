import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nexuschatfe/config/di/app_providers.dart';
import 'package:nexuschatfe/features/auth/domain/repository/google_auth_repository.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/login_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/home_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GoogleAuthRepository.initialize();
  await initializeDependencies();
  runApp(
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        registerUser: getIt<RegisterUser>(),
        loginUser: getIt<LoginUser>(),
        loginWithGoogle: getIt<LoginWithGoogle>(),
        logoutUser: getIt<LogoutUser>(),
      )..add(const CheckAuthStatusRequested()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexusChat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Root decides screen based on AuthState.
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }
          // Show login by default for initial/unauthenticated/logged out/error states
          return const LoginScreen();
        },
      ),
    );
  }
}
