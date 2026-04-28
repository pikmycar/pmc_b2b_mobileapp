import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    // 🎬 Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    print("🚀 Splash Started");

    // ✅ SAFE NAVIGATION CALL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });
  }

  // 🔥 MAIN NAVIGATION LOGIC
  Future<void> _handleNavigation() async {
    print("✅ handleNavigation STARTED");

    final storage = context.read<SecureStorageService>();

    final isLoggedIn = await storage.isLoggedIn();
    final pin = await storage.getPin();
    final biometric = await storage.isBiometricEnabled();

    print("isLoggedIn: $isLoggedIn");
    print("PIN: $pin");
    print("Biometric Enabled: $biometric");

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ✅ CASE 1: Logged in + PIN exists
    if (isLoggedIn && pin != null && pin.isNotEmpty) {
      print("➡️ Navigating to PIN LOGIN");
      Navigator.pushReplacementNamed(context, '/pin_login');
      return;
    }

    // ✅ CASE 2: Logged in but no PIN
    if (isLoggedIn && (pin == null || pin.isEmpty)) {
      print("➡️ Navigating to CREATE PIN");
      Navigator.pushReplacementNamed(context, '/create_pin');
      return;
    }

    // ❌ CASE 3: Not logged in
    print("➡️ Navigating to LOGIN");
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // 🌄 Background image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/Png/SplashBackground.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

            // 🚗 Logo animation & Text
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
                        height: 240, // Increased logo size
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_taxi,
                          size: 100,
                          color: Color(0xFFFFCA20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Made In Dubai 🇦🇪",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}