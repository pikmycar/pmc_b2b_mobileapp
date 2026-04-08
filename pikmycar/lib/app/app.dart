import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/repository/auth_repository.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/services/biometric_service.dart';
import 'router.dart';

class PikMyCarApp extends StatelessWidget {
  const PikMyCarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => SecureStorageService()),
        RepositoryProvider(create: (_) => BiometricService()),
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
        ],
        child: MaterialApp(
          title: 'PikMyCar Driver App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
