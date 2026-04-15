import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
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

  // 🔹 HEADER
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.designYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "AR",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Abdul Rahman",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Support Driver",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6B3F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "VERIFIED",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("340", "Trips"),
              _buildStatItem("4.9★", "Rating"),
              _buildStatItem("98%", "Accept"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.designYellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // 🔹 MENU LIST
  Widget _buildMenuList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [

              _buildMenuItem(
                icon: Icons.notifications_none,
                title: "Notifications",
                badge: _buildBadge("3", Colors.red),
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              _divider(),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: "My Profile",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/profile_details');
                },
              ),
              _divider(),

              _buildMenuItem(
                icon: Icons.description_outlined,
                title: "Documents",
                badge: _buildBadge("VERIFIED",
                    const Color(0xFF1E6B3F), isText: true),
                onTap: () {
                  Navigator.pushNamed(context, '/documents');
                },
              ),
              _divider(),

              _buildMenuItem(
                icon: Icons.account_balance_outlined,
                title: "Bank Account",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/bank_account');
                },
              ),
              _divider(),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: "Settings",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              _divider(),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: "Help & Support",
                showChevron: true,
                onTap: () {
                  Navigator.pushNamed(context, '/support');
                },
              ),
              _divider(),

              _buildMenuItem(
                icon: Icons.logout,
                title: "Logout",
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 MENU ITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? badge,
    bool showChevron = false,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, size: 22, color: iconColor ?? Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) badge,
          if (showChevron) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 18, color: Colors.grey),
          ],
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }

  Widget _buildBadge(String text, Color color,
      {bool isText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isText ? 10 : 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 🔹 LOGOUT
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