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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Text(
                  "Choose Your Role",
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _roleCard(
                      label: "Main Driver",
                      icon: Icons.person,
                      role: UserRole.mainDriver,
                      activeColor: colorScheme.primary,
                      onColor: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _roleCard(
                      label: "Support Driver",
                      icon: Icons.support_agent,
                      role: UserRole.supportDriver,
                      activeColor: colorScheme.secondary,
                      onColor: colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  "Login or Sign Up",
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              
              // Toggle Switch
              Row(
                children: [
                  Expanded(child: _toggleItem("Mobile", _isMobileSelected, () => setState(() => _isMobileSelected = true))),
                  const SizedBox(width: 12),
                  Expanded(child: _toggleItem("Email", !_isMobileSelected, () => setState(() => _isMobileSelected = false))),
                ],
              ),
              const SizedBox(height: 48),
              
              Text(
                _isMobileSelected
                    ? "Enter your registered\nMobile number"
                    : "Enter your registered\nEmail address",
                style: textTheme.displayLarge?.copyWith(fontSize: 26, height: 1.25),
              ),
              const SizedBox(height: 16),
              Text(
                "Be part of a community where you choose how you ride.",
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 40),

              // Input Field
              if (_isMobileSelected)
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        "+91 ",
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    hintText: "50 123 4567",
                  ),
                )
              else
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Enter Email Address",
                  ),
                ),
              
              const SizedBox(height: 40),

              // Continue Button
              ElevatedButton(
                onPressed: _isLoading ? null : _onContinue,
                child: _isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                    : const Text("Continue"),
              ),

              const SizedBox(height: 48),

              // Bottom Text
              Center(
                child: Column(
                  children: [
                    Text(
                      "By continuing, you agree to our Terms",
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          TextSpan(
                            text: '   &   ',
                            style: TextStyle(decoration: TextDecoration.none, color: colorScheme.onSurface.withOpacity(0.5)),
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

  Widget _roleCard({required String label, required IconData icon, required UserRole role, required Color activeColor, required Color onColor}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : colorScheme.surface,
          border: Border.all(color: isSelected ? activeColor : colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? onColor : colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? onColor : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
