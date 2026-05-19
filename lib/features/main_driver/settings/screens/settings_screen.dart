import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              /// SECURITY
              _sectionTitle(context, "SECURITY"),
              _tile(
                context,
                Icons.account_balance_wallet_outlined,
                "Earnings & Withdraw",
                () => Navigator.pushNamed(context, '/withdraw'),
              ),
              _tile(
                context,
                Icons.lock_reset_rounded,
                "Reset Login PIN",
                () => Navigator.pushNamed(context, '/reset_pin'),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  leading: Icon(Icons.fingerprint_rounded, color: colorScheme.primary),
                  title: Text(
                    "Biometric Login",
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: state.preferences['biometric'] ?? false,
                    onChanged: (val) {
                      context.read<SettingsBloc>()
                          .add(TogglePreference('biometric', val));
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// PREFERENCES
              _sectionTitle(context, "PREFERENCES"),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  leading: Icon(Icons.notifications_none_rounded, color: colorScheme.primary),
                  title: Text(
                    "Push Notifications",
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: state.preferences['notifications'] ?? true,
                    onChanged: (val) {
                      context.read<SettingsBloc>()
                          .add(TogglePreference('notifications', val));
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// APP INFO
              Center(
                child: Text(
                  "PikMyCar Driver · v2.4.0",
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withOpacity(0.2)),
        onTap: onTap,
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: colorScheme.onSurface.withOpacity(0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}