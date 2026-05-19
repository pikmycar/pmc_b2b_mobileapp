import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/services/theme_service.dart';
import '../core/services/trip_storage_service.dart';
import '../features/auth/data/repository/auth_repository.dart';
import '../features/auth/data/datasource/auth_api.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/services/theme_service.dart';
import '../core/services/trip_storage_service.dart';
import '../core/services/biometric_service.dart';
import 'router.dart';
import '../features/auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../features/main_driver/settings/bloc/settings_bloc.dart';
import '../features/main_driver/settings/bloc/settings_event.dart';
import '../features/auth/data/datasource/driver_api.dart';
import '../core/services/location_service.dart';

class PikMyCarApp extends StatelessWidget {
  const PikMyCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => SecureStorageService()),
        RepositoryProvider(create: (context) => ApiClient(context.read<SecureStorageService>())),
        RepositoryProvider(create: (context) => AuthApi(context.read<ApiClient>())),
        RepositoryProvider(create: (context) => AuthRepository(context.read<AuthApi>())),
        RepositoryProvider(create: (_) => BiometricService()),
        RepositoryProvider(create: (_) => ThemeService()),
        RepositoryProvider(create: (_) => TripStorageService()),
        RepositoryProvider(create: (_) => LocationService()),
        RepositoryProvider(create: (context) => DriverApi(context.read<ApiClient>())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              storage: context.read<SecureStorageService>(),
            )..add(AppStarted()),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(context.read<ThemeService>()),
          ),
          BlocProvider(
            create: (context) => TripBloc(
              context.read<TripStorageService>(),
              context.read<DriverApi>(),
              context.read<LocationService>(),
            ),
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
