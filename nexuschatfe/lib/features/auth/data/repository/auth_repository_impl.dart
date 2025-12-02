import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/exceptions.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:nexuschatfe/features/auth/domain/entities/auth_session.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalService _localService;

  AuthRepositoryImpl(this._remoteDataSource, this._localService);

  @override
  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final session = await _remoteDataSource.verifyOtp(email: email, otp: otp);

      // Save token locally
      await _localService.saveToken(session.token);

      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _localService.saveToken(session.token);

      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> loginWithGoogleToken({
    required String accessToken,
  }) async {
    try {
      final session = await _remoteDataSource.loginWithGoogle(
        accessToken: accessToken,
      );

      await _localService.saveToken(session.token);

      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout({required String token}) async {
    try {
      await _remoteDataSource.logout(token: token);
      await _localService.logout();
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() {
    return _localService.isLoggedIn();
  }
}
