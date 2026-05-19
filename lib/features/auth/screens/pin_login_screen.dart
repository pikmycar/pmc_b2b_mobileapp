import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/storage/secure_storage_service.dart';
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
    try {
      // pin_code_fields sometimes automatically disposes the controller,
      // causing a double-dispose crash here. We catch and ignore it.
      _pinController.dispose();
    } catch (_) {}
    
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              /// 🔥 TITLE
              Center(
                child: Text(
                  "Welcome Back",
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 48),

              /// 🔥 HEADING
              Text(
                "Enter your PIN",
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Fast & secure access to your driver account",
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
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
                      borderRadius: BorderRadius.circular(16),
                      fieldHeight: 65,
                      fieldWidth: 65,
                      inactiveColor: colorScheme.outlineVariant,
                      selectedColor: colorScheme.primary,
                      activeColor: colorScheme.primary,
                      activeFillColor: colorScheme.surface,
                      inactiveFillColor: colorScheme.surface,
                      selectedFillColor: colorScheme.surface,
                    ),
                    backgroundColor: Colors.transparent,
                    cursorColor: colorScheme.primary,
                    enableActiveFill: true,
                    textStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              /// 🔥 PREMIUM BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _pin.length == 4 && !_isLoading ? _verifyPin : null,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔐 BIOMETRIC
              Center(
                child: TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Use Biometric"),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔁 PASSWORD SWITCH
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    "Use Password Instead",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 💬 FOOTER
              Center(
                child: Text(
                  "Your data is securely encrypted 🔒",
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}