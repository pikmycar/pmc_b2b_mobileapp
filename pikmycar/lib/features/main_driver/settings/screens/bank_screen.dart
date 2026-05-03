import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/bloc/commonScreen/bank/create_bank_bloc.dart';
import '../../../auth/bloc/commonScreen/bank/create_bank_event.dart';
import '../../../auth/bloc/commonScreen/bank/create_bank_state.dart';
import '../../../auth/bloc/commonScreen/bank/get_bank_bloc.dart';
import '../../../auth/bloc/commonScreen/bank/get_bank_event.dart';
import '../../../auth/bloc/commonScreen/bank/get_bank_state.dart';
import '../../../auth/data/models/get_bank.dart';
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
  late TextEditingController _branchController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _ifscController = TextEditingController();
    _bankController = TextEditingController();
    _branchController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _ifscController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CreateBankBloc(
            repository: BankRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => GetBankBloc(
            repository: GetBankRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          )..add(FetchBankEvent()),
        ),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Payout Settings",
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              BlocBuilder<GetBankBloc, GetBankState>(
                builder: (context, state) {
                  if (state is GetBankLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is GetBankSuccess) {
                    final bankDataList = state.response.data ?? [];
                    if (bankDataList.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LINKED ACCOUNT${bankDataList.length > 1 ? 'S' : ''}",
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...bankDataList.map((bank) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildApiLinkedAccountCard(context, bank),
                              )),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),

              Text(
                "ADD NEW ACCOUNT",
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            const SizedBox(height: 16),
            _buildTextField(innerContext, _nameController, "Account Holder Name", Icons.person_outline),
            const SizedBox(height: 24),
            _buildTextField(innerContext, _numberController, "Account Number", Icons.vignette_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _buildTextField(innerContext, _ifscController, "IFSC Code", Icons.qr_code_rounded),
            const SizedBox(height: 24),
            _buildTextField(innerContext, _bankController, "Bank Name", Icons.account_balance_outlined),
            const SizedBox(height: 24),
            _buildTextField(innerContext, _branchController, "Branch Name", Icons.account_tree_outlined),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: BlocConsumer<CreateBankBloc, CreateBankState>(
                listener: (context, state) {
                  if (state is CreateBankSuccess) {
                    // Refresh the GetBankBloc list to show newly added account
                    context.read<GetBankBloc>().add(FetchBankEvent());

                    // Clear the controllers
                    _nameController.clear();
                    _numberController.clear();
                    _ifscController.clear();
                    _bankController.clear();
                    _branchController.clear();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.response.message ?? "Bank details added successfully"),
                        backgroundColor: colorScheme.secondary,
                      ),
                    );
                  } else if (state is CreateBankError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CreateBankLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : () {
                      context.read<CreateBankBloc>().add(
                        SubmitCreateBankEvent(
                          accountHolderName: _nameController.text,
                          accountNumber: _numberController.text,
                          ifscCode: _ifscController.text,
                          bankName: _bankController.text,
                          branchName: _branchController.text,
                        ),
                      );
                    },
                    child: isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text("SAVE DETAILS"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
          );
        },
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

  Widget _buildApiLinkedAccountCard(BuildContext context, BankData bank) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withBlue(100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance, color: colorScheme.onPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bank.bankName?.isNotEmpty == true ? bank.bankName! : "Bank Account",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (bank.isDefault == true)
                Icon(Icons.check_circle, color: Colors.greenAccent.shade400),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            "**** **** **** ****",
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (bank.accountHolderName ?? "").toUpperCase(),
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (bank.branchName != null && bank.branchName!.isNotEmpty)
                Text(
                  "Branch: ${bank.branchName}",
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
