import 'package:get_it/get_it.dart';
import 'package:nexuschatfe/config/network/auth_interceptor.dart';
import 'package:nexuschatfe/config/network/dio_client.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_serviceimpl.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/remote/auth_remote_data_source_impl.dart';
import 'package:nexuschatfe/features/auth/data/repository/auth_repository_impl.dart';
import 'package:nexuschatfe/features/auth/domain/repository/auth_repository.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'package:nexuschatfe/core/services/pusher_config.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/verify_otp.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:nexuschatfe/features/chat/data/data_sources/remote/chat_remote_data_source.dart';
import 'package:nexuschatfe/features/chat/data/data_sources/remote/chat_remote_data_source_impl.dart';
import 'package:nexuschatfe/features/chat/data/repository/chat_repository_impl.dart';
import 'package:nexuschatfe/features/chat/domain/repository/chat_repository.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/get_chat_rooms.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/get_messages.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/provide_chat_room.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/search_users.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/send_message.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // 1. Local Services (no dependencies)
  getIt.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());

  // 2. Auth Interceptor (depends on AuthLocalService)
  getIt.registerSingleton<AuthInterceptor>(
    AuthInterceptor(getIt<AuthLocalService>()),
  );

  // 3. Core HTTP Client (depends on AuthInterceptor)
  getIt.registerSingleton<DioClient>(DioClient(getIt<AuthInterceptor>()));

  // 4. Data Sources

  // Remote (This replaces the old ApiService)
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // 3. Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalService>(),
    ),
  );

  // 4. Use Cases
  getIt.registerSingleton<RegisterUser>(RegisterUser(getIt<AuthRepository>()));
  getIt.registerSingleton<LoginUser>(LoginUser(getIt<AuthRepository>()));
  getIt.registerSingleton<LoginWithGoogle>(
    LoginWithGoogle(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LogoutUser>(LogoutUser(getIt<AuthRepository>()));
  getIt.registerSingleton<VerifyOtp>(VerifyOtp(getIt<AuthRepository>()));

  // Services
  getIt.registerLazySingleton<PusherConfig>(
    () => PusherConfig(getIt<DioClient>()),
  );

  // ---------------------------------------------------------------------------
  // CHAT FEATURE
  // ---------------------------------------------------------------------------

  // 1. Data Sources
  getIt.registerSingleton<ChatRemoteDataSource>(
    ChatRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // 2. Repositories
  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(getIt<ChatRemoteDataSource>()),
  );

  // 3. Use Cases
  getIt.registerSingleton<GetChatRooms>(GetChatRooms(getIt<ChatRepository>()));
  getIt.registerSingleton<GetMessages>(GetMessages(getIt<ChatRepository>()));
  getIt.registerSingleton<SendMessage>(SendMessage(getIt<ChatRepository>()));
  getIt.registerSingleton<SearchUsers>(SearchUsers(getIt<ChatRepository>()));
  getIt.registerSingleton<ProvideChatRoom>(
    ProvideChatRoom(getIt<ChatRepository>()),
  );

  // 4. Blocs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUser: getIt<RegisterUser>(),
      loginUser: getIt<LoginUser>(),
      loginWithGoogle: getIt<LoginWithGoogle>(),
      logoutUser: getIt<LogoutUser>(),
      verifyOtp: getIt<VerifyOtp>(),
      localService: getIt<AuthLocalService>(),
    ),
  );

  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      getChatRooms: getIt<GetChatRooms>(),
      getMessages: getIt<GetMessages>(),
      sendMessage: getIt<SendMessage>(),
      searchUsers: getIt<SearchUsers>(),
      provideChatRoom: getIt<ProvideChatRoom>(),
      pusherConfig: getIt<PusherConfig>(),
      authLocalService: getIt<AuthLocalService>(),
    ),
  );
}
