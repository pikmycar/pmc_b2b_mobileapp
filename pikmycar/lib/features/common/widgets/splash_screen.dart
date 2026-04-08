import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const SplashScreen({super.key, this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnim = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward(); // start animation

    // Trigger initial auth check
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Add a slight delay to allow animation to complete or for branding
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          
          if (state is AuthAuthenticated) {
            final route = state.role == 'main_driver'
                ? '/main_driver_dashboard'
                : '/support_driver_dashboard';
            Navigator.pushReplacementNamed(context, route);
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is AuthError) {
             Navigator.pushReplacementNamed(context, '/login');
          }
        });
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.splashGradientStart,
                AppColors.splashGradientEnd,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Skyline Image (aligned to bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/Png/SplashBackground.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),

              // Main Logo (and optional Text if missing from logo)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/Png/SplashLogo.png',
                          height: 160,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.local_taxi,
                            size: 100,
                            color: Color(0xFFFFCA20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer - Made in Dubai
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/Png/Bottomimage.png',
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Made In Dubai ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text("🇦🇪", style: TextStyle(fontSize: 14)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
