import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import 'thank_you_screen.dart';
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
  bool _isLoading = false;

  void _onLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;

    // Direct to thank you
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ThankYouScreen()),
    );
  }

  void _onLoginWithOtpInstead() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: "+971 ${widget.mobile}",
        )
      ),
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
                "Enter your password",
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              const Text(
                "An OTP has been sent to",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                "+971 ${widget.mobile}",
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

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
                    hintStyle: TextStyle(
                      color: Colors.black26,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Forgot Password & Login with OTP row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _onLoginWithOtpInstead,
                    child: Text(
                      "Login with OTP instead",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      : const Text(
                          "Login",
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
    );
  }
}
