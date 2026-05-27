import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/models/user_role.dart';
import '../../../../features/auth/screens/login_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/bloc/commonScreen/profile/get_profile_bloc.dart';
import '../../../auth/bloc/commonScreen/profile/get_profile_event.dart';
import '../../../auth/bloc/commonScreen/profile/get_profile_state.dart';
import '../../../common/screens/ratings_screen.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../../auth/bloc/commonScreen/driver_location/trip_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout? All local cache will be cleared."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final storage = context.read<SecureStorageService>();
              await storage.logout();
              if (context.mounted) {
                context.read<TripBloc>().add(LogoutReset());
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
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
      body: FutureBuilder<String?>(
        future: context.read<SecureStorageService>().getUserRole(),
        builder: (innerContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final roleStr = snapshot.data;
          final isSupport = roleStr == "support_driver" || roleStr == UserRole.supportDriver.toString();

          if (isSupport) {
            return BlocProvider(
              create: (context) => GetProfileBloc(
                repository: ProfileRepository(
                  apiClient: context.read<ApiClient>(),
                ),
              )..add(FetchProfileEvent()),
              child: BlocBuilder<GetProfileBloc, GetProfileState>(
                builder: (context, state) {
                  String ratingSubtitle = "";
                  if (state is GetProfileSuccess) {
                    final ratingVal = state.profileDetails.data?.rating;
                    if (ratingVal != null) {
                      ratingSubtitle = "${ratingVal.toStringAsFixed(1)} ★";
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _tile(
                        context,
                        Icons.person_outline_rounded,
                        "Profile",
                        () => Navigator.pushNamed(context, '/profile_details'),
                      ),
                      _tile(
                        context,
                        Icons.account_balance_wallet_outlined,
                        "Earnings",
                        () => Navigator.pushNamed(context, '/withdraw'),
                      ),
                      _tile(
                        context,
                        Icons.account_balance_outlined,
                        "Bank Account",
                        () => Navigator.pushNamed(context, '/bank_account'),
                      ),
                      _tile(
                        context,
                        Icons.star_outline_rounded,
                        "Ratings",
                        () => Navigator.pushNamed(context, '/ratings'),
                        subtitle: ratingSubtitle.isNotEmpty ? ratingSubtitle : null,
                      ),
                      _tile(
                        context,
                        Icons.logout_rounded,
                        "Logout",
                        () => _handleLogout(context),
                      ),
                    ],
                  );
                },
              ),
            );
          }

          return BlocBuilder<SettingsBloc, SettingsState>(
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
                    decoration: AppTheme.premiumCardDecoration(context),
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
                    decoration: AppTheme.premiumCardDecoration(context),
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
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {String? subtitle}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.premiumCardDecoration(context),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
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