import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You cannot go offline during an active trip."),
      ),
    );
  }

  Future<void> _toggleOnlineStatus(BuildContext context) async {
    bool newStatus = !isOnline;
    onOnlineStatusChanged?.call(newStatus);
  }

  /// 🔔 NOTIFICATION CLICK
  void _handleNotificationTap(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isOnline ? const Color(0xFF00C853) : Colors.white,
      elevation: 0,

      leading: IconButton(
        icon: Icon(Icons.menu,
            color: isOnline ? Colors.white : Colors.black),
        onPressed: onMenuTap,
      ),

      centerTitle: true,

      /// 🔥 ONLINE TOGGLE
      title: GestureDetector(
        onTap: () async {
          if (canGoOffline || !isOnline) {
            await _toggleOnlineStatus(context);
          } else {
            _showOfflineSnackBar(context);
          }
        },
        child: _buildStatusToggle(),
      ),

      /// 🔔 NOTIFICATION ICON
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: isOnline ? Colors.white : Colors.black,
          ),
          onPressed: () => _handleNotificationTap(context),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      width: 130,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFF00C853).withOpacity(0.8)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(40),
        border: isOnline ? null : Border.all(color: Colors.redAccent),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment:
                isOnline ? Alignment.center : const Alignment(0.25, 0),
            child: Text(
              isOnline ? "Online" : "Go Online",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isOnline ? Colors.white : const Color(0xFF131313),
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
                    ? const Color(0xFF00E676)
                    : Colors.redAccent,
                shape: BoxShape.circle,
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