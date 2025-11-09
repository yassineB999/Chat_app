import 'package:get_it/get_it.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'package:nexuschatfe/features/auth/data/repository/auth_repository_impl.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_api_service.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Data sources
  getIt.registerLazySingleton<AuthApiService>(() => AuthApiService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt<AuthApiService>()),
  );

  // Use cases
  getIt.registerLazySingleton<RegisterUser>(
    () => RegisterUser(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LoginUser>(
    () => LoginUser(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LoginWithGoogle>(
    () => LoginWithGoogle(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUser>(
    () => LogoutUser(getIt<AuthRepository>()),
  );

  // Blocs (use factory to get a fresh instance when needed)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUser: getIt<RegisterUser>(),
      loginUser: getIt<LoginUser>(),
      loginWithGoogle: getIt<LoginWithGoogle>(),
      logoutUser: getIt<LogoutUser>(),
    ),
  );
}
