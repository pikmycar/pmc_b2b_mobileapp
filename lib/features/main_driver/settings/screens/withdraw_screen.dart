import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/bloc/commonScreen/bank/get_bank_bloc.dart';
import '../../../auth/bloc/commonScreen/bank/get_bank_event.dart';
import '../../../auth/bloc/commonScreen/bank/get_bank_state.dart';
import '../../../auth/bloc/commonScreen/earnings/get_earnings_bloc.dart';
import '../../../auth/bloc/commonScreen/earnings/get_earnings_event.dart';
import '../../../auth/bloc/commonScreen/earnings/get_earnings_state.dart';
import '../../../auth/data/models/get_bank.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isSuccess = false;
  BankData? _selectedBank;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessUI();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetBankBloc(
            repository: GetBankRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          )..add(FetchBankEvent()),
        ),
        BlocProvider(
          create: (context) => GetEarningsBloc(
            repository: EarningsRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          )..add(FetchEarningsEvent()),
        ),
      ],
      child: Builder(
        builder: (innerContext) {
          final theme = Theme.of(innerContext);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Withdraw Money",
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ENTER AMOUNT",
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      prefixStyle: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                      hintText: "0.00",
                      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.1)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.outlineVariant)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Real wallet balance from GetEarningsBloc
                  BlocBuilder<GetEarningsBloc, GetEarningsState>(
                    builder: (context, state) {
                      String balanceText = "0.00";
                      if (state is GetEarningsLoading) {
                        balanceText = "Loading...";
                      } else if (state is GetEarningsSuccess) {
                        final wallet = state.earnings.data?.walletBalance;
                        balanceText = wallet != null
                            ? wallet.toStringAsFixed(2)
                            : "0.00";
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Available: ₹$balanceText",
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  Text(
                    "WITHDRAW TO",
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Linked Accounts from API ---
                  BlocBuilder<GetBankBloc, GetBankState>(
                    builder: (context, state) {
                      if (state is GetBankLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetBankError) {
                        return _buildNoBankCard(colorScheme, textTheme);
                      } else if (state is GetBankSuccess) {
                        final bankList = state.response.data ?? [];
                        if (bankList.isEmpty) {
                          return _buildNoBankCard(colorScheme, textTheme);
                        }

                        // Auto-select the default bank or first one
                        if (_selectedBank == null) {
                          final defaultBank = bankList.firstWhere(
                            (b) => b.isDefault == true,
                            orElse: () => bankList.first,
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _selectedBank = defaultBank);
                          });
                        }

                        return Column(
                          children: bankList.map((bank) {
                            final isSelected = _selectedBank?.bankId == bank.bankId;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedBank = bank),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withOpacity(0.08)
                                      : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.account_balance_rounded,
                                          color: colorScheme.primary, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bank.bankName ?? "Bank Account",
                                            style: textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            bank.accountHolderName ?? "",
                                            style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurface.withOpacity(0.5)),
                                          ),
                                          if (bank.branchName != null && bank.branchName!.isNotEmpty)
                                            Text(
                                              "Branch: ${bank.branchName}",
                                              style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onSurface.withOpacity(0.4)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded,
                                          color: colorScheme.primary),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Add account button
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/bank_account'),
                    icon: const Icon(Icons.add),
                    label: const Text("Add another account"),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: (_selectedBank == null || _amountController.text.isEmpty)
                    ? null
                    : () {
                        final amount = double.tryParse(_amountController.text) ?? 0;
                        final earningsState = innerContext.read<GetEarningsBloc>().state;
                        final walletBalance = earningsState is GetEarningsSuccess
                            ? (earningsState.earnings.data?.walletBalance ?? 0.0)
                            : 0.0;
                        if (amount > 0 && amount <= walletBalance) {
                          innerContext.read<SettingsBloc>().add(WithdrawMoney(amount));
                          setState(() => _isSuccess = true);
                        } else {
                          ScaffoldMessenger.of(innerContext).showSnackBar(
                            SnackBar(
                              content: const Text("Invalid amount or insufficient balance"),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      },
                child: const Text("CONFIRM WITHDRAWAL"),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoBankCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Not Linked",
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  "Link your bank account first",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/bank_account'),
            child: const Text("LINK NOW"),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: colorScheme.secondary, size: 100),
              ),
              const SizedBox(height: 40),
              Text(
                "Withdrawal Successful!",
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your money will be credited to your bank account within 24-48 hours.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5), height: 1.5),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text("DONE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

