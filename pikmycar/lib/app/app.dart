import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/services/theme_service.dart';
import '../core/services/trip_storage_service.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/repository/auth_repository.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/services/biometric_service.dart';
import 'router.dart';
import '../features/main_driver/transport_trip/bloc/trip_bloc.dart';
import '../features/main_driver/settings/bloc/settings_bloc.dart';
import '../features/main_driver/settings/bloc/settings_event.dart';

class PikMyCarApp extends StatelessWidget {
  const PikMyCarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => SecureStorageService()),
        RepositoryProvider(create: (_) => BiometricService()),
        RepositoryProvider(create: (_) => ThemeService()),
        RepositoryProvider(create: (_) => TripStorageService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              storageService: context.read<SecureStorageService>(),
              biometricService: context.read<BiometricService>(),
            ),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(context.read<ThemeService>()),
          ),
          BlocProvider(
            create: (context) => TripBloc(context.read<TripStorageService>()),
          ),
          BlocProvider(
            create: (context) => SettingsBloc()..add(LoadSettings()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'PikMyCar Driver App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              initialRoute: '/',
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
