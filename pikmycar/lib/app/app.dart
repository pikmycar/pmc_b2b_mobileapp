import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class PikMyCarApp extends StatelessWidget {
  const PikMyCarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PikMyCar Driver App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Switch automatically based on system preferences
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
