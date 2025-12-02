import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser _registerUser;
  final LoginUser _loginUser;
  final LoginWithGoogle _loginWithGoogle;
  final LogoutUser _logoutUser;
  final VerifyOtp _verifyOtp;
  final AuthLocalService _localService;

  AuthBloc({
    required RegisterUser registerUser,
    required LoginUser loginUser,
    required LoginWithGoogle loginWithGoogle,
    required LogoutUser logoutUser,
    required VerifyOtp verifyOtp,
    required AuthLocalService localService,
  }) : _registerUser = registerUser,
       _loginUser = loginUser,
       _loginWithGoogle = loginWithGoogle,
       _logoutUser = logoutUser,
       _verifyOtp = verifyOtp,
       _localService = localService,
       super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _localService.getToken();
    if (token != null && token.isNotEmpty) {
      final session = AuthSession(token: token, user: null);
      emit(AuthAuthenticated(session));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    // NOTE: We do NOT emit AuthLoading here to prevent the AuthWrapper
    // from flickering to the Login screen. The RegisterScreen UI handles the spinner.

    final result = await _registerUser.call(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthAwaitingOtpVerification(event.email)),
    );
  }

  Future<void> _onOtpVerificationRequested(
    OtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    // NOTE: We do NOT emit AuthLoading here.
    // This fixes the "Flash to Login" bug.

    final result = await _verifyOtp.call(email: event.email, otp: event.otp);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAwaitingOtpVerification(event.email));
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _loginUser.call(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _loginWithGoogle.call(accessToken: event.accessToken);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    final token = currentState.session.token;
    emit(const AuthLoading());

    final result = await _logoutUser.call(token: token);
    await _localService.logout();

    result.fold(
      (failure) {
        // Even if API fails, we log out locally
        emit(const AuthUnauthenticated());
      },
      (success) {
        emit(const AuthUnauthenticated());
      },
    );
  }
}
