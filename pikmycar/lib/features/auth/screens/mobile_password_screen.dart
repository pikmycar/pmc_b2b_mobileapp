import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'otp_verification_screen.dart';
import '../../../core/theme/app_theme.dart';

class MobilePasswordScreen extends StatefulWidget {
  final String mobile;

  const MobilePasswordScreen({
    super.key,
    required this.mobile,
  });

  @override
  State<MobilePasswordScreen> createState() => _MobilePasswordScreenState();
}

class _MobilePasswordScreenState extends State<MobilePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  void _onLogin() {
    context.read<AuthBloc>().add(
          LoginRequested(
            username: widget.mobile,
            password: _passwordController.text,
          ),
        );
  }

  void _onLoginWithOtpInstead() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
                email: "+91 ${widget.mobile}",
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthOtpRequired) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: "+91 ${widget.mobile}",
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          final storage = context.read<SecureStorageService>();
          final pin = await storage.getPin();
          if (!mounted) return;

          if (pin == null) {
            Navigator.pushReplacementNamed(context, '/create_pin');
          } else {
            Navigator.pushReplacementNamed(context, '/pin_login');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Enter your password",
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  "An OTP has been sent to",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 8),
                Text(
                  "+91 ${widget.mobile}",
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Enter your password",
                  ),
                ),
                const SizedBox(height: 8),

                // Forgot Password & Login with OTP row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onLoginWithOtpInstead,
                      child: const Text("Login with OTP instead"),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final bool isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onLogin,
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Login"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
