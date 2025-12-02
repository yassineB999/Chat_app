import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/core/utils/toast_service.dart'; // ✨ Use the new Service
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:nexuschatfe/features/auth/presentation/widgets/primary_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _currentOtp = '';
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  // ✨ Lock to prevent double submission
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      _canResend = false;
      _start = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onVerifyPressed() {
    // ✨ FIX 1: Strict check against local flag AND Bloc state
    if (_isVerifying || context.read<AuthBloc>().state is AuthLoading) return;

    if (_currentOtp.length != 6) {
      // ✨ FIX 2: Use ToastService for warning
      ToastService.showWarning(
        context,
        'Please enter the complete 6-digit code.',
      );
      return;
    }

    // Lock execution immediately
    setState(() {
      _isVerifying = true;
    });

    context.read<AuthBloc>().add(
      OtpVerificationRequested(email: widget.email, otp: _currentOtp),
    );
  }

  void _onResendPressed() {
    if (!_canResend) return;
    context.read<AuthBloc>().add(ResendOtpRequested(email: widget.email));
    startTimer();

    // ✨ FIX 3: Use ToastService for success
    ToastService.showSuccess(context, 'A new OTP has been sent.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Allows user to go back to login/logout if stuck
            context.read<AuthBloc>().add(const LogoutRequested());
          },
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // ✨ FIX 4: Release lock on error
            setState(() {
              _isVerifying = false;
            });
            // Show error using Service
            ToastService.showError(context, state.message);
          }
          // Note: We do not navigate manually here.
          // Main.dart (AuthWrapper) handles the success navigation to HomeScreen.
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Combine local lock with global loading state
            final isLoading = state is AuthLoading || _isVerifying;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter the 6-digit code sent to: ${widget.email}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    OtpInputField(
                      onCompleted: (otp) {
                        setState(() => _currentOtp = otp);
                        // Only trigger if not already loading
                        if (!_isVerifying) {
                          _onVerifyPressed();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    PrimaryButton(
                      label: 'Verify',
                      loading: isLoading,
                      onPressed: (_currentOtp.length == 6 && !isLoading)
                          ? _onVerifyPressed
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive the code?"),
                        TextButton(
                          onPressed: _canResend && !isLoading
                              ? _onResendPressed
                              : null,
                          child: Text(
                            _canResend ? 'Resend' : 'Resend in ${_start}s',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
