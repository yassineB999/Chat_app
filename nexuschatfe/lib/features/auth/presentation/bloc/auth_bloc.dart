import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:nexuschatfe/comon/ressources/data_states.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser _registerUser;
  final LoginUser _loginUser;
  final LoginWithGoogle _loginWithGoogle;
  final LogoutUser _logoutUser;

  AuthBloc({
    required RegisterUser registerUser,
    required LoginUser loginUser,
    required LoginWithGoogle loginWithGoogle,
    required LogoutUser logoutUser,
  })  : _registerUser = registerUser,
        _loginUser = loginUser,
        _loginWithGoogle = loginWithGoogle,
        _logoutUser = logoutUser,
        super(const AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<LoginRequested>(_onLoginRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _registerUser.call(name: event.name, email: event.email, password: event.password);
    if (result is DataSuccess<String>) {
      final session = AuthSession(token: result.data!, user: null);
      emit(AuthAuthenticated(session));
    } else if (result is DataError<String>) {
      emit(AuthError(_extractMessage(result.failure)));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginUser.call(email: event.email, password: event.password);
    if (result is DataSuccess<AuthSession>) {
      emit(AuthAuthenticated(result.data!));
    } else if (result is DataError<AuthSession>) {
      emit(AuthError(_extractMessage(result.failure)));
    }
  }

  Future<void> _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginWithGoogle.call(accessToken: event.accessToken);
    if (result is DataSuccess<AuthSession>) {
      emit(AuthAuthenticated(result.data!));
    } else if (result is DataError<AuthSession>) {
      emit(AuthError(_extractMessage(result.failure)));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final currentState = state;
    final token = event.token ?? (currentState is AuthAuthenticated ? currentState.session.token : null);
    if (token == null || token.isEmpty) {
      emit(const AuthError('No token available for logout'));
      return;
    }
    final result = await _logoutUser.call(token: token);
    if (result is DataSuccess<bool>) {
      if (result.data == true) {
        emit(const AuthLoggedOut());
        emit(const AuthUnauthenticated());
      } else {
        emit(const AuthError('Logout failed'));
      }
    } else if (result is DataError<bool>) {
      emit(AuthError(_extractMessage(result.failure)));
    }
  }

  String _extractMessage(DioException? failure) {
    if (failure == null) return 'Unknown error';
    final statusCode = failure.response?.statusCode;
    final data = failure.response?.data;
    final serverMessage = data is Map<String, dynamic> ? (data['message'] as String? ?? '') : '';
    final message = serverMessage.isNotEmpty
        ? serverMessage
        : failure.message ?? 'Request failed${statusCode != null ? ' (HTTP $statusCode)' : ''}';
    return message;
  }
}