import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary, // Themed header background
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(context),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: _buildMenuList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.onPrimary.withOpacity(0.2), width: 4),
                ),
                child: Center(
                  child: Text(
                    "AR",
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Abdul Rahman",
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Support Driver",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              color: colorScheme.onSecondary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "VERIFIED",
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, "340", "Total Trips"),
              _buildStatDivider(context),
              _buildStatItem(context, "4.9★", "Rating"),
              _buildStatDivider(context),
              _buildStatItem(context, "98%", "Accept Rate"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.6),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 24,
      width: 1,
      color: colorScheme.onPrimary.withOpacity(0.2),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.notifications_none_rounded,
                title: "Notifications",
                badge: _buildBadge(context, "3", colorScheme.error),
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              _divider(context),

              _buildMenuItem(
                context,
                icon: Icons.person_outline_rounded,
                title: "Personal Profile",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/profile_details');
                },
              ),
              _divider(context),

              _buildMenuItem(
                context,
                icon: Icons.description_outlined,
                title: "Driver Documents",
                badge: _buildBadge(context, "ACTIVE", colorScheme.secondary, isText: true),
                onTap: () {
                  Navigator.pushNamed(context, '/documents');
                },
              ),
              _divider(context),

              _buildMenuItem(
                context,
                icon: Icons.account_balance_outlined,
                title: "Payout Settings",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/bank_account');
                },
              ),
              _divider(context),

              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: "App Settings",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              _divider(context),

              _buildMenuItem(
                context,
                icon: Icons.headset_mic_outlined,
                title: "Help & Support",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/support');
                },
              ),
              _divider(context),

              _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: "Log Out",
                textColor: colorScheme.error,
                iconColor: colorScheme.error,
                onTap: () => _handleLogout(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            "Version 2.4.0 (Build 2026)",
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? badge,
    bool showChevron = false,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? colorScheme.primary),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor ?? colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) badge,
          if (showChevron) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurface.withOpacity(0.2)),
          ],
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color, {bool isText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isText ? 12 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: isText ? 9 : 11,
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final storage = context.read<SecureStorageService>();
    await storage.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}