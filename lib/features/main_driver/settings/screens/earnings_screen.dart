import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import 'withdraw_screen.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Earnings",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final earnings = state.earnings;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // MAIN BALANCE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "AVAILABLE BALANCE",
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.6),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "₹${earnings?.availableBalance.toStringAsFixed(2) ?? "0.00"}",
                        style: textTheme.displayMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(color: colorScheme.onPrimary.withOpacity(0.1), height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat(context, "TOTAL EARNED", "₹${earnings?.totalEarnings.toStringAsFixed(2) ?? "0.00"}"),
                          Container(height: 30, width: 1, color: colorScheme.onPrimary.withOpacity(0.1)),
                          _buildMiniStat(context, "LAST TRIP", "₹450.00"),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // ACTION SECTION
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "QUICK ACTIONS",
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildActionItem(
                  context,
                  icon: Icons.account_balance_rounded,
                  title: "Withdraw to Bank",
                  subtitle: "Transfer earnings to your linked account",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
                ),
                const SizedBox(height: 16),
                _buildActionItem(
                  context,
                  icon: Icons.history_rounded,
                  title: "Transaction History",
                  subtitle: "View all previous withdrawals & earnings",
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          label, 
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary, 
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.02 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
