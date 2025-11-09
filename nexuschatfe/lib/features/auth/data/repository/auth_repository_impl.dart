import 'package:dio/dio.dart';
import 'package:nexuschatfe/comon/ressources/data_states.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_api_service.dart';
import 'package:nexuschatfe/features/auth/data/models/auth_session_model.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _remote;

  AuthRepositoryImpl({AuthApiService? remote})
    : _remote = remote ?? AuthApiService();

  @override
  Future<DataState<String>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.register(
        name: name,
        email: email,
        password: password,
      );
      final token = response.data is Map<String, dynamic>
          ? (response.data['token'] ?? '')
          : '';
      if (token.isEmpty) {
        return DataError(
          DioException.badResponse(
            statusCode: response.statusCode ?? 500,
            requestOptions: response.requestOptions,
            response: response,
          ),
        );
      }
      return DataSuccess(token);
    } on DioException catch (e) {
      return DataError(e);
    } catch (_) {
      return DataError(
        DioException(requestOptions: RequestOptions(path: '/register')),
      );
    }
  }

  @override
  Future<DataState<AuthSessionModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(email: email, password: password);
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final session = AuthSessionModel.fromJson(data);
      if (session.token.isEmpty) {
        return DataError(
          DioException.badResponse(
            statusCode: response.statusCode ?? 500,
            requestOptions: response.requestOptions,
            response: response,
          ),
        );
      }
      return DataSuccess(session);
    } on DioException catch (e) {
      return DataError(e);
    } catch (_) {
      return DataError(
        DioException(requestOptions: RequestOptions(path: '/login')),
      );
    }
  }

  @override
  Future<DataState<AuthSessionModel>> loginWithGoogleToken({
    required String accessToken,
  }) async {
    try {
      final response = await _remote.loginWithGoogleToken(
        accessToken: accessToken,
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final session = AuthSessionModel.fromJson(data);
      if (session.token.isEmpty) {
        return DataError(
          DioException.badResponse(
            statusCode: response.statusCode ?? 500,
            requestOptions: response.requestOptions,
            response: response,
          ),
        );
      }
      return DataSuccess(session);
    } on DioException catch (e) {
      return DataError(e);
    } catch (_) {
      return DataError(
        DioException(
          requestOptions: RequestOptions(path: '/auth/google/callback'),
        ),
      );
    }
  }

  @override
  Future<DataState<bool>> logout({required String token}) async {
    try {
      final response = await _remote.logout(token: token);
      final ok =
          (response.statusCode ?? 500) >= 200 &&
          (response.statusCode ?? 500) < 300;
      return DataSuccess(ok);
    } on DioException catch (e) {
      return DataError(e);
    } catch (_) {
      return DataError(
        DioException(requestOptions: RequestOptions(path: '/logout')),
      );
    }
  }
}
