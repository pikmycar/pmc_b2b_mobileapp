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

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _pin = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // ✅ Trigger biometric after UI loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  // 🔥 BIOMETRIC LOGIN (FIXED)
  Future<void> _tryBiometric() async {
    final storage = context.read<SecureStorageService>();
    final biometricService = context.read<BiometricService>();

    final enabled = await storage.isBiometricEnabled();
    print("Biometric Enabled: $enabled");

    if (!enabled) return;

    try {
      final success = await biometricService.authenticate();
      print("Biometric Success: $success");

      if (!mounted) return;

      if (success) {
        final role = await storage.getUserRole();
        if (!mounted) return;
        
        if (role == UserRole.supportDriver.toString()) {
          Navigator.pushReplacementNamed(context, '/support_driver_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/main_driver_dashboard');
        }
      }
    } catch (e) {
      print("Biometric Error: $e");
    }
  }

  // 🔥 PIN VERIFY
  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final storage = context.read<SecureStorageService>();
    final savedPin = await storage.getPin();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (_pin == savedPin) {
      final role = await storage.getUserRole();
      if (!mounted) return;

      if (role == UserRole.supportDriver.toString()) {
        Navigator.pushReplacementNamed(context, '/support_driver_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/main_driver_dashboard');
      }
    } else {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    const Center(
                      child: Text(
                        "Welcome Back",
                        style: AppTextStyles.heading2,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "Login securely",
                      style: AppTextStyles.heading1.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Use Biometric or enter your PIN",
                      style: AppTextStyles.caption,
                    ),

                    const SizedBox(height: 40),

                    // 🔥 PIN FIELD
                    PinCodeTextField(
                      appContext: context,
                      controller: _pinController,
                      length: 4,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      animationType: AnimationType.fade,
                      onChanged: (val) => setState(() => _pin = val),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 60,
                        fieldWidth: 60,
                        inactiveColor: Colors.grey.shade300,
                        selectedColor: AppColors.accent,
                        activeColor: AppColors.accent,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🔥 LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _pin.length == 4 && !_isLoading
                            ? _verifyPin
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 BIOMETRIC BUTTON
                    Center(
                      child: TextButton.icon(
                        onPressed: _tryBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text("Use Biometric"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔁 PASSWORD OPTION
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

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}