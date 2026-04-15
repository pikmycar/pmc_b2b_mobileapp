import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../models/settings_models.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bank Account", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(_nameController, "Account Holder Name", Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(_numberController, "Account Number", Icons.vignette_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(_ifscController, "IFSC Code", Icons.code_outlined),
            const SizedBox(height: 20),
            _buildTextField(_bankController, "Bank Name", Icons.account_balance_outlined),
            
            const SizedBox(height: 60),
            
            SizedBox(
              width: double.infinity,
              height: 56,
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
                    const SnackBar(content: Text("Bank details saved successfully")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("SAVE DETAILS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.indigo.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.indigo.withOpacity(0.03),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo),
            ),
          ),
        ),
      ],
    );
  }
}
