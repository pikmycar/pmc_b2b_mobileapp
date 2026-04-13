import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
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
            leading: const Icon(Icons.home_outlined, color: AppColors.primary),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: const Text('My Trips'),
            onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/trip_history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
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
              // Clear stack and go to login
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
