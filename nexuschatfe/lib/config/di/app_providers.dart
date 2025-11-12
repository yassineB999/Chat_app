import 'package:get_it/get_it.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'package:nexuschatfe/features/auth/data/repository/auth_repository_impl.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_api_service_impl.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_apiservice.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_serviceimpl.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core client
  getIt.registerSingleton<DioClient>(DioClient());

  // Services
  getIt.registerSingleton<AuthApiservice>(AuthApiServiceImpl());
  getIt.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());

  // Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Use cases
  getIt.registerSingleton<RegisterUser>(RegisterUser(getIt<AuthRepository>()));
  getIt.registerSingleton<LoginUser>(LoginUser(getIt<AuthRepository>()));
  getIt.registerSingleton<LoginWithGoogle>(
    LoginWithGoogle(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LogoutUser>(LogoutUser(getIt<AuthRepository>()));
}
