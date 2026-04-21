import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomTopHeaderBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final ValueChanged<bool>? onOnlineStatusChanged;
  final bool isOnline;
  final bool canGoOffline;

  const CustomTopHeaderBar({
    super.key,
    this.onMenuTap,
    this.onOnlineStatusChanged,
    required this.isOnline,
    this.canGoOffline = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showOfflineSnackBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("You cannot go offline during an active trip."),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  Future<void> _toggleOnlineStatus(BuildContext context) async {
    bool newStatus = !isOnline;
    onOnlineStatusChanged?.call(newStatus);
  }

  void _handleNotificationTap(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Indigo/Primary look when online, surface look when offline
    final onlineColor = colorScheme.primary;
    final offlineColor = colorScheme.surface;
    final appBarBg = isOnline ? onlineColor : offlineColor;
    final foregroundColor = isOnline ? colorScheme.onPrimary : colorScheme.onSurface;

    return AppBar(
      backgroundColor: appBarBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: foregroundColor),
        onPressed: onMenuTap,
      ),
      centerTitle: true,
      title: GestureDetector(
        onTap: () async {
          if (canGoOffline || !isOnline) {
            await _toggleOnlineStatus(context);
          } else {
            _showOfflineSnackBar(context);
          }
        },
        child: _buildStatusToggle(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: foregroundColor),
          onPressed: () => _handleNotificationTap(context),
        ),
      ],
    );
  }

  Widget _buildStatusToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final onlineBg = colorScheme.primaryContainer;
    final offlineBg = colorScheme.onSurface.withOpacity(0.05);
    final indicatorColor = isOnline ? AppColors.success : colorScheme.error;

    return Container(
      width: 130,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isOnline ? onlineBg : offlineBg,
        borderRadius: BorderRadius.circular(40),
        border: isOnline ? null : Border.all(color: colorScheme.error.withOpacity(0.5)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: isOnline ? Alignment.center : const Alignment(0.25, 0),
            child: Text(
              isOnline ? "Online" : "Go Online",
              style: theme.textTheme.labelMedium?.copyWith(
                color: isOnline ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                size: 18,
                color: Colors.white, // Indicator icon usually stays white for contrast
              ),
            ),
          ),
        ],
      ),
    );
  }
}