import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../models/settings_models.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _ifscController;
  late TextEditingController _bankController;

  @override
  void initState() {
    super.initState();
    final bank = context.read<SettingsBloc>().state.bankDetails;
    _nameController = TextEditingController(text: bank?.accountHolder ?? "");
    _numberController = TextEditingController(text: bank?.accountNumber ?? "");
    _ifscController = TextEditingController(text: bank?.ifscCode ?? "");
    _bankController = TextEditingController(text: bank?.bankName ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _ifscController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bank Account",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(context, _nameController, "Account Holder Name", Icons.person_outline),
            const SizedBox(height: 24),
            _buildTextField(context, _numberController, "Account Number", Icons.vignette_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _buildTextField(context, _ifscController, "IFSC Code", Icons.qr_code_rounded),
            const SizedBox(height: 24),
            _buildTextField(context, _bankController, "Bank Name", Icons.account_balance_outlined),
            
            const SizedBox(height: 60),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final bank = BankModel(
                    accountHolder: _nameController.text,
                    accountNumber: _numberController.text,
                    ifscCode: _ifscController.text,
                    bankName: _bankController.text,
                  );
                  context.read<SettingsBloc>().add(SaveBankDetails(bank));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Bank details saved successfully"),
                      backgroundColor: colorScheme.secondary,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("SAVE DETAILS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(), 
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5), 
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: colorScheme.primary),
            hintText: "Enter ${label.toLowerCase()}",
          ),
        ),
      ],
    );
  }
}
