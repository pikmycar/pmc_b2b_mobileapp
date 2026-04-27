import 'package:flutter/material.dart';
import 'dart:async';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    // Validation
    if (pin.length < 4) {
      _showError("PIN must be at least 4 digits");
      return;
    }
    if (pin != confirmPin) {
      _showError("PINs do not match");
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("PIN updated successfully"),
          backgroundColor: colorScheme.secondary,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reset PIN",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set a new secure PIN for your account.",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            
            _buildPasswordField(
              context,
              controller: _pinController,
              label: "ENTER NEW PIN",
              obscure: _obscurePin,
              onToggle: () => setState(() => _obscurePin = !_obscurePin),
            ),
            
            const SizedBox(height: 24),
            
            _buildPasswordField(
              context,
              controller: _confirmPinController,
              label: "CONFIRM NEW PIN",
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            
            const SizedBox(height: 64),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("UPDATE PIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900, 
            color: colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 8),
          decoration: InputDecoration(
            counterText: "",
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: colorScheme.onSurface.withOpacity(0.3)),
              onPressed: onToggle,
            ),
            hintText: "••••••",
            hintStyle: TextStyle(letterSpacing: 8, color: colorScheme.onSurface.withOpacity(0.1)),
          ),
        ),
      ],
    );
  }
}
