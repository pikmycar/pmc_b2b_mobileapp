import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../common/widgets/biometric_dialog.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  late TextEditingController _pinController;

  String _firstPin = ''; 
  String _currentInput = ''; 
  bool _isConfirm = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _currentInput = value;
    });
  }

  void _onSubmit() async {
    if (!_isConfirm) {
      if (_currentInput.length == 4) {
        final lockedPin = _currentInput;
        if (mounted) _pinController.clear();
        setState(() {
          _firstPin = lockedPin;
          _currentInput = '';
          _isConfirm = true;
        });
      }
    } else {
      if (_currentInput.length == 4) {
        if (_firstPin == _currentInput) {
          // Trigger BLoC event
          context.read<AuthBloc>().add(PinCreated(_currentInput));
        } else {
          _pinController.clear();
          setState(() {
            _firstPin = '';
            _currentInput = '';
            _isConfirm = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PIN mismatch. Please try again.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          // Show biometric dialog before going home (Optional but kept as per existing flow)
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const BiometricDialog(),
          );

          if (!mounted) return;
          
          if (state.role == "main_driver") {
            Navigator.pushNamedAndRemoveUntil(context, '/driver_home', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isConfirm ? "Confirm PIN" : "Create PIN")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  _isConfirm ? "Re-enter your PIN" : "Set a 4-digit PIN",
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 30),
                PinCodeTextField(
                  key: ValueKey(_isConfirm),
                  controller: _pinController,
                  appContext: context,
                  length: 4,
                  autoDisposeControllers: false,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  animationType: AnimationType.fade,
                  onChanged: _onChanged,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 65,
                    fieldWidth: 65,
                    inactiveColor: colorScheme.outlineVariant,
                    selectedColor: colorScheme.primary,
                    activeColor: colorScheme.primary,
                    activeFillColor: colorScheme.surface,
                    inactiveFillColor: colorScheme.surface,
                    selectedFillColor: colorScheme.surface,
                  ),
                  backgroundColor: Colors.transparent,
                  cursorColor: colorScheme.primary,
                  enableActiveFill: true,
                  textStyle: textTheme.titleLarge,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final bool isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: (_currentInput.length == 4 && !isLoading) ? _onSubmit : null,
                        child: isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isConfirm ? "Confirm PIN" : "Continue"),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
