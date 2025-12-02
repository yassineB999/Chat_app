import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/home_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/login_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/verify_otp_screen.dart';
import 'package:nexuschatfe/features/auth/presentation/pages/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // 1. Authenticated -> Home
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        // 2. Verify OTP
        else if (state is AuthAwaitingOtpVerification) {
          return VerifyOtpScreen(email: state.email);
        }
        // 3. App Start Up -> Splash
        else if (state is AuthInitial) {
          return const SplashScreen();
        }
        // 4. Login, Error, Loading, or Unauthenticated -> Login Screen
        else {
          return const LoginScreen();
        }
      },
    );
  }
}
