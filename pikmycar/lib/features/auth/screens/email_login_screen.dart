import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'timer_text.dart';
import 'thank_you_screen.dart';
import '../../../core/theme/app_theme.dart';

class EmailLoginScreen extends StatefulWidget {
  final String email;

  const EmailLoginScreen({super.key, required this.email});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpComplete = false;
  bool _showResendButton = false;
  bool _isOtpWrong = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // PinCodeTextField disposes its controller automatically
    super.dispose();
  }

  Future<void> _verify() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // Mock API Delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ThankYouScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Login with Email",
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              const Text(
                "Enter your email address",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),

              // Email Field
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintText: "Enter your email address",
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Enter OTP instead",
                style: AppTextStyles.heading4,
              ),
              const SizedBox(height: 24),

              // OTP Fields
              PinCodeTextField(
                controller: _otpController,
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    _isOtpComplete = value.length == 6;
                    _isOtpWrong = false;
                  });
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(6),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: AppColors.accent,
                  activeColor: _isOtpWrong ? Colors.red : Colors.grey.shade300,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Resend OTP / Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap:
                        _showResendButton
                            ? () {
                              setState(() => _showResendButton = false);
                              // logic to resend
                            }
                            : null,
                    child: Text(
                      "Resend OTP",
                      style: AppTextStyles.caption.copyWith(
                        color: _showResendButton ? Colors.black : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!_showResendButton)
                    TimerText(
                      durationSeconds: 55,
                      onTimerComplete: () {
                        if (!mounted) return;
                        setState(() {
                          _showResendButton = true;
                        });
                      },
                    )
                  else
                    const Text(
                      "00 : 00",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 48),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          )
                          : const Text(
                            "Verify",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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
