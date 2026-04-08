import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../common/widgets/biometric_dialog.dart';
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
    super.dispose();
  }

  void _onVerify() {
    context.read<AuthBloc>().add(OtpVerified(otp: otpController.text));
  }

  void _showBiometricPrompt(String role) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BiometricDialog(),
    ).then((_) {
      if (mounted) {
        final route = role == 'main_driver'
            ? '/main_driver_dashboard'
            : '/support_driver_dashboard';
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.isFirstLogin) {
              _showBiometricPrompt(state.role);
            } else {
              final route = state.role == 'main_driver'
                  ? '/main_driver_dashboard'
                  : '/support_driver_dashboard';
              Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                  const Text(
                    "Enter OTP",
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "An OTP has been sent to",
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.email,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Enter OTP",
                    style: AppTextStyles.caption,
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
                      borderRadius: BorderRadius.circular(6),
                      fieldHeight: 50,
                      fieldWidth: 45,
                      inactiveColor: Colors.grey.shade300,
                      selectedColor: AppColors.accent,
                      activeColor: isOtpWrong ? Colors.red : Colors.grey.shade300,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
                                // Logic for resending OTP could be added here
                              },
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: showResendButton ? Colors.black : AppColors.textSecondary,
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
                        const Text(
                          "00 : 00",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final bool isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isOtpComplete && !isLoading ? _onVerify : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                              : const Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
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

