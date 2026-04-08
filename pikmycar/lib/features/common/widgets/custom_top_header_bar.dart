import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final ValueChanged<bool>? onOnlineStatusChanged;
  final bool isOnline;
  final bool canGoOffline;

  const CustomTopHeaderBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onOnlineStatusChanged,
    required this.isOnline,
    this.canGoOffline = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showOfflineSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You cannot go offline during an active trip."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleOnlineStatus(BuildContext context) async {
    // Stripped location and GraphQL API requirements for the demo
    bool newStatus = !isOnline;
    onOnlineStatusChanged?.call(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          isOnline ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: isOnline ? Colors.white : Colors.black,
        ),
        onPressed: onMenuTap,
      ),
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
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: isOnline ? Colors.white : Colors.black,
          ),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }

  Widget _buildStatusToggle(BuildContext context) {
    return Container(
      width: 130,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isOnline ? Theme.of(context).colorScheme.secondary.withOpacity(0.8) : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(40),
        border: isOnline
            ? null
            : Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: isOnline
                ? Alignment.center
                : const Alignment(0.25, 0),
            child: Text(
              isOnline ? "Online" : "Go Online",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isOnline
                    ? Colors.white
                    : const Color(0xFF131313),
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            alignment: isOnline
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isOnline
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
