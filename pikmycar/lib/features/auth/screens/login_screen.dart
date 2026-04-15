import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'email_login_screen.dart';
import 'mobile_password_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_role.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isMobileSelected = true;
  
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  UserRole _selectedRole = UserRole.mainDriver;

  void _onContinue() async {
    setState(() => _isLoading = true);
    
    // Save role to secure storage
    final storage = context.read<SecureStorageService>();
    await storage.setUserRole(_selectedRole.toString());

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;
    
    if (_isMobileSelected) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => MobilePasswordScreen(
            mobile: _mobileController.text.isNotEmpty ? _mobileController.text : '501234567',
          )
        )
      );
    } else {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => EmailLoginScreen(
            email: _emailController.text.isNotEmpty ? _emailController.text : 'test@example.com',
          )
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  "Choose Your Role",
                  style: AppTextStyles.heading2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = UserRole.mainDriver),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.mainDriver ? AppColors.primary : Colors.white,
                          border: Border.all(color: _selectedRole == UserRole.mainDriver ? AppColors.primary : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _selectedRole == UserRole.mainDriver ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: _selectedRole == UserRole.mainDriver ? Colors.white : Colors.black54),
                            const SizedBox(height: 4),
                            Text(
                              "Main Driver",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == UserRole.mainDriver ? Colors.white : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = UserRole.supportDriver),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.supportDriver ? AppColors.secondary : Colors.white,
                          border: Border.all(color: _selectedRole == UserRole.supportDriver ? AppColors.secondary : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _selectedRole == UserRole.supportDriver ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.support_agent, color: _selectedRole == UserRole.supportDriver ? Colors.white : Colors.black54),
                            const SizedBox(height: 4),
                            Text(
                              "Support Driver",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == UserRole.supportDriver ? Colors.white : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Center(
                child: Text(
                  "Login or Sign Up",
                  style: AppTextStyles.heading2,
                ),
              ),
              const SizedBox(height: 32),
              
              // Toggle Switch
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isMobileSelected = true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isMobileSelected ? AppColors.accent.withOpacity(0.1) : Colors.white,
                          border: Border.all(color: _isMobileSelected ? AppColors.accent : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Mobile",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isMobileSelected = false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: !_isMobileSelected ? AppColors.accent.withOpacity(0.1) : Colors.white,
                          border: Border.all(color: !_isMobileSelected ? AppColors.accent : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              Text(
                _isMobileSelected
                    ? "Enter your registered\nMobile number"
                    : "Enter your registered\nEmail address",
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 26,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Be part of a community where you choose how you ride.",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 40),

              // Input Field
              if (_isMobileSelected)
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "+91 ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "50 123 4567",
                            hintStyle: TextStyle(
                              color: Colors.black26,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter Email Address",
                      hintStyle: TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onContinue,
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
                          "Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 48),

              // Bottom Text
              Center(
                child: Column(
                  children: [
                    const Text(
                      "By continuing, you agree to our Terms",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(
                            text: '   &   ',
                            style: TextStyle(decoration: TextDecoration.none, color: Colors.grey),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                  ],
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
