import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'thank_you_screen.dart';
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
  bool isLoading = false;
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
    // PinCodeTextField disposes its controller automatically, calling dispose again causes a crash.
    super.dispose();
  }

  void showErrorToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: 78,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3D3E4B),
                                height: 20 / 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  Future<void> verifyOtp() async {
    if (isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      isOtpWrong = false;
    });

    final otp = otpController.text.trim();

    // Mock API Verification Request Delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    setState(() => isLoading = false);
    
    if (otp == "123456") {
      setState(() => isOtpWrong = true);
      showErrorToast(context, "Invalid OTP. Please try again.");
      return;
    }

    Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => const ThankYouScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
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
                    activeColor:
                        isOtpWrong ? Colors.red : Colors.grey.shade300,
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
                      onTap: isLoading || !showResendButton
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                                showResendButton = false;
                              });

                              await Future.delayed(
                                const Duration(seconds: 1),
                              );
                              if (!mounted) return;
                              setState(() {
                                isLoading = false;
                              });

                              showErrorToast(
                                context,
                                "OTP sent successfully!",
                              );
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
                  child: ElevatedButton(
                    onPressed: isOtpComplete && !isLoading ? verifyOtp : null,
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

