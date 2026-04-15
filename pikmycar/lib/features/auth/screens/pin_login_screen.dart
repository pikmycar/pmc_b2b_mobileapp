import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_role.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _pinController;
  String _pin = '';
  bool _isLoading = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _pinController = TextEditingController();

    /// 🔥 SHAKE ANIMATION
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation =
        Tween<double>(begin: 0, end: 12).chain(CurveTween(curve: Curves.elasticIn))
            .animate(_shakeController);

    /// 🔥 AUTO BIOMETRIC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  Future<void> _tryBiometric() async {
    final storage = context.read<SecureStorageService>();
    final biometricService = context.read<BiometricService>();

    final enabled = await storage.isBiometricEnabled();
    if (!enabled) return;

    final success = await biometricService.authenticate();

    if (!mounted) return;

    if (success) {
      final role = await storage.getUserRole();

      Navigator.pushReplacementNamed(
        context,
        role == UserRole.supportDriver.toString()
            ? '/support_driver_dashboard'
            : '/main_driver_dashboard',
      );
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final storage = context.read<SecureStorageService>();
    final savedPin = await storage.getPin();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (_pin == savedPin) {
      final role = await storage.getUserRole();

      Navigator.pushReplacementNamed(
        context,
        role == UserRole.supportDriver.toString()
            ? '/support_driver_dashboard'
            : '/main_driver_dashboard',
      );
    } else {
      /// ❌ SHAKE EFFECT
      _shakeController.forward(from: 0);

      _pinController.clear();
      setState(() => _pin = '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect PIN")),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌈 PREMIUM GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8FAFF),
                  Color(0xFFEFF3FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  /// 🔥 TITLE
                  const Center(
                    child: Text(
                      "Welcome Back",
                      style: AppTextStyles.heading2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// 🔥 HEADING
                  Text(
                    "Enter your PIN",
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Fast & secure access to your driver account",
                    style: AppTextStyles.caption,
                  ),

                  const SizedBox(height: 50),

                  /// 🔥 PIN WITH SHAKE
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Center(
                      child: PinCodeTextField(
                        appContext: context,
                        controller: _pinController,
                        length: 4,
                        obscureText: true,
                        animationType: AnimationType.fade,
                        onChanged: (val) => setState(() => _pin = val),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 65,
                          fieldWidth: 65,
                          inactiveColor: Colors.grey.shade200,
                          selectedColor: AppColors.accent,
                          activeColor: AppColors.accent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  /// 🔥 PREMIUM BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          _pin.length == 4 && !_isLoading ? _verifyPin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shadowColor: AppColors.accent.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🔐 BIOMETRIC
                  Center(
                    child: TextButton.icon(
                      onPressed: _tryBiometric,
                      icon: Icon(Icons.fingerprint,
                          color: AppColors.accent),
                      label: Text(
                        "Use Biometric",
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔁 PASSWORD SWITCH
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Use Password Instead",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// 💬 FOOTER
                  const Center(
                    child: Text(
                      "Your data is securely encrypted 🔒",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}