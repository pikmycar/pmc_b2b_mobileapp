import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../app/main_wrapper.dart';
import '../../common/widgets/biometric_dialog.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_role.dart';
import '../../main_driver/dashboard/main_driver_dashboard.dart';
import '../../support_driver/dashboard/support_driver_dashboard.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // ✅ FIX: Use separate, stable variables that don't get wiped on mismatch
  String _firstPin = '';       // Locked in after step 1
  String _currentInput = '';   // Tracks live input for current step
  bool _isConfirm = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // ✅ FIX: Only update _currentInput, never touch _firstPin here
    setState(() {
      _currentInput = value;
    });
  }

  void _onSubmit() async {
    if (!_isConfirm) {
      if (_currentInput.length == 4) {
        // ✅ FIX: Lock in the first PIN BEFORE clearing anything
        final lockedPin = _currentInput;

        _pinController.clear();

        setState(() {
          _firstPin = lockedPin;   // Save it safely
          _currentInput = '';
          _isConfirm = true;
        });
      }
    } else {
      if (_currentInput.length == 4) {
        await _validate();
      }
    }
  }

  Future<void> _validate() async {
    // ✅ FIX: Compare _firstPin (locked) vs _currentInput (confirm entry)
    if (_firstPin == _currentInput) {
      final storage = context.read<SecureStorageService>();

      await storage.savePin(_firstPin);
      await storage.setLoggedIn(true);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const BiometricDialog(),
      );

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;
      final role = await storage.getUserRole();
      
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainWrapper(
            child: role == UserRole.supportDriver.toString() 
                ? const SupportDriverDashboard() 
                : const MainDriverDashboard(),
          ),
        ),
        (route) => false,
      );
    } else {
      _confirmController.clear();

      setState(() {
        // ✅ FIX: Reset to step 1 cleanly — _firstPin cleared too
        _firstPin = '';
        _currentInput = '';
        _isConfirm = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN mismatch. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isConfirm ? "Confirm PIN" : "Create PIN"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                _isConfirm ? "Re-enter your PIN" : "Set a 4-digit PIN",
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(height: 30),

              // ✅ FIX: Use a ValueKey so Flutter rebuilds the widget
              // cleanly when switching between step 1 and step 2.
              // Without this, the old controller's value leaks into
              // the new field and triggers a phantom onChanged("").
              PinCodeTextField(
                key: ValueKey(_isConfirm), // 👈 CRITICAL
                controller: _isConfirm ? _confirmController : _pinController,
                appContext: context,
                length: 4,
                keyboardType: TextInputType.number,
                obscureText: true,
                autoFocus: true,
                animationType: AnimationType.fade,
                beforeTextPaste: (text) => false,
                onChanged: _onChanged,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 65,
                  fieldWidth: 65,
                  inactiveColor: AppColors.borderNeutral,
                  selectedColor: AppColors.accent,
                  activeColor: AppColors.primary,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _currentInput.length == 4 ? _onSubmit : null,
                  child: Text(
                    _isConfirm ? "Confirm PIN" : "Continue",
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.textInversePrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}