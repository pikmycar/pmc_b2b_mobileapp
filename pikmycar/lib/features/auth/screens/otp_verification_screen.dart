import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'create_pin_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'timer_text.dart';
import '../../../core/theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? otpCode;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.otpCode,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final TextEditingController otpController;
  bool isOtpComplete = false;
  bool isOtpWrong = false;
  bool showResendButton = false;

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController(text: widget.otpCode ?? '');
    isOtpComplete = otpController.text.length == 6;
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    context.read<AuthBloc>().add(OtpVerified(otp: otpController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: true,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            final storage = context.read<SecureStorageService>();
            await storage.setLoggedIn(true);
            await storage.setBiometricEnabled(true);
            final pin = await storage.getPin();

            if (!mounted) return;

            if (pin == null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePinScreen(),
                ),
              );
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
                    "Enter OTP",
                    style: textTheme.displayLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "An OTP has been sent to",
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.email,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Enter OTP",
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 16),
                  PinCodeTextField(
                    controller: otpController,
                    appContext: context,
                    length: 6,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        isOtpComplete = value.length == 6;
                        isOtpWrong = false;
                      });
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(16),
                      fieldHeight: 50,
                      fieldWidth: 45,
                      inactiveColor: colorScheme.outlineVariant,
                      selectedColor: colorScheme.primary,
                      activeColor: isOtpWrong ? colorScheme.error : colorScheme.primary,
                      activeFillColor: colorScheme.surface,
                      inactiveFillColor: colorScheme.surface,
                      selectedFillColor: colorScheme.surface,
                    ),
                    backgroundColor: Colors.transparent,
                    cursorColor: colorScheme.primary,
                    enableActiveFill: true,
                    textStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Timer + Resend Text Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: !showResendButton
                            ? null
                            : () {
                                setState(() {
                                  showResendButton = false;
                                });
                              },
                        child: Text(
                          "Resend OTP",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: showResendButton ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                      if (!showResendButton)
                        TimerText(
                          durationSeconds: 55,
                          onTimerComplete: () {
                            if (!mounted) return;
                            setState(() {
                              showResendButton = true;
                            });
                          },
                        )
                      else
                        Text(
                          "00 : 00",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final bool isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isOtpComplete && !isLoading ? _onVerify : null,
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Verify"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
