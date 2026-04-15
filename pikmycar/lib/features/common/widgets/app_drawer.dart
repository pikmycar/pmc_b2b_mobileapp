import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<String?>(
                    future: context.read<SecureStorageService>().getUserRole(),
                    builder: (context, snapshot) {
                      final roleStr = snapshot.data;
                      String roleDisplay = 'Driver';
                      if (roleStr == UserRole.mainDriver.toString()) {
                        roleDisplay = 'Main Driver';
                      } else if (roleStr == UserRole.supportDriver.toString()) {
                        roleDisplay = 'Support Driver';
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roleDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.star, color: AppColors.accent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '4.9 Rating',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          ListTile(
            leading: Icon(Icons.home_outlined, color: isDark ? AppColors.primary : AppColors.primaryDark),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.history, color: isDark ? AppColors.primary : AppColors.primaryDark),
            title: const Text('My Trips'),
            onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/trip_history');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: isDark ? AppColors.primary : AppColors.primaryDark),
            title: const Text('Settings'),
            onTap: () {
               print("DEBUG: [AppDrawer] Navigating to /settings");
               Navigator.pop(context);
               Navigator.pushNamed(context, '/settings');
            },
          ),
          
          const Divider(),
          
          // Theme Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, currentMode) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _themeIcon(context, Icons.brightness_auto, "Auto", ThemeMode.system, currentMode),
                        _themeIcon(context, Icons.light_mode, "Light", ThemeMode.light, currentMode),
                        _themeIcon(context, Icons.dark_mode, "Dark", ThemeMode.dark, currentMode),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.info),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          
          const Divider(),
          
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final storage = context.read<SecureStorageService>();
              await storage.logout();
              
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _themeIcon(BuildContext context, IconData icon, String label, ThemeMode mode, ThemeMode currentMode) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.read<ThemeCubit>().updateTheme(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
