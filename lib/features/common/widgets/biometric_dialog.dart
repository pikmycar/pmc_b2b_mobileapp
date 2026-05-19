import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pikmycar/core/services/biometric_service.dart';
import '../../../core/storage/secure_storage_service.dart';

class BiometricDialog extends StatelessWidget {
  const BiometricDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Biometric Login?'),
      content: const Text(
        'Would you like to use Fingerprint or Face ID for faster login next time?',
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final biometricService =
                        RepositoryProvider.of<BiometricService>(context);
                    final authenticated = await biometricService.authenticate();

                    if (authenticated) {
                      final storage =
                          RepositoryProvider.of<SecureStorageService>(context);
                      await storage.setBiometricEnabled(true);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Enable'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
