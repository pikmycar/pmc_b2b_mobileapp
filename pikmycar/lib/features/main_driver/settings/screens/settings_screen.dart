import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Settings"),
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
            padding: const EdgeInsets.all(16),
            children: [

              /// 🔹 SECURITY
              _sectionTitle("Security"),
              _tile(
                Icons.account_balance_wallet_outlined,
                "Earnings & Withdraw",
                () => Navigator.pushNamed(context, '/withdraw'),
              ),
              _tile(
                Icons.lock_outline,
                "Reset PIN",
                () => Navigator.pushNamed(context, '/reset_pin'),
              ),

              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text("Biometric Login"),
                trailing: Switch(
                  value: state.preferences['biometric'] ?? false,
                  onChanged: (val) {
                    context.read<SettingsBloc>()
                        .add(TogglePreference('biometric', val));
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 PREFERENCES
              _sectionTitle("Preferences"),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text("Notifications"),
                trailing: Switch(
                  value: state.preferences['notifications'] ?? true,
                  onChanged: (val) {
                    context.read<SettingsBloc>()
                        .add(TogglePreference('notifications', val));
                  },
                ),
              ),


              const SizedBox(height: 30),

              /// 🔹 LOGOUT
          
            ],
          );
        },
      ),
    );
  }

  /// 🔹 TILE
  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}