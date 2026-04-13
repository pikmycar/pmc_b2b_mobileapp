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
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildMenuItem(
                      icon: Icons.notifications_none_outlined,
                      title: "Notifications",
                      badge: _buildBadge("3", Colors.red),
                    ),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: "My Profile",
                      showChevron: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: "Documents",
                      badge: _buildBadge("VERIFIED", const Color(0xFF1E6B3F), isText: true),
                    ),
                    _buildMenuItem(
                      icon: Icons.account_balance_outlined,
                      title: "Bank Account",
                      showChevron: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      showChevron: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      showChevron: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: "Logout",
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                      showChevron: true,
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final storage = context.read<SecureStorageService>();
    await storage.logout();
    
    if (!context.mounted) return;
    
    // Clear stack and go to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.designYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "AR",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Abdul Rahman",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Support Driver",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6B3F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "VERIFIED",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
          const SizedBox(height: 40),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? badge,
    bool showChevron = false,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Icon(icon, color: iconColor ?? Colors.black54, size: 28),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) badge,
            if (showChevron) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isText ? 12 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
