import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/config/di/app_providers.dart';
import 'package:nexuschatfe/config/routes/app_router.dart';
import 'package:nexuschatfe/config/theme/app_theme.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/login_with_google.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/logout_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/register_user.dart';
import 'package:nexuschatfe/features/auth/domain/use_case/verify_otp.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexuschatfe/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_bloc.dart';

class NexusChatApp extends StatefulWidget {
  const NexusChatApp({super.key});

  @override
  State<NexusChatApp> createState() => _NexusChatAppState();
}

class _NexusChatAppState extends State<NexusChatApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    // 1. Create AuthBloc
    _authBloc = AuthBloc(
      registerUser: getIt<RegisterUser>(),
      loginUser: getIt<LoginUser>(),
      loginWithGoogle: getIt<LoginWithGoogle>(),
      logoutUser: getIt<LogoutUser>(),
      verifyOtp: getIt<VerifyOtp>(),
      localService: getIt<AuthLocalService>(),
    )..add(const CheckAuthStatusRequested());

    // 2. Create AppRouter with AuthBloc dependency
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Provide Blocs to the tree
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider<ChatBloc>(create: (context) => getIt<ChatBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'NexusChat',

        // Theme Configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // GoRouter configuration
        routerConfig: _appRouter.router,
      ),
    );
  }
}
