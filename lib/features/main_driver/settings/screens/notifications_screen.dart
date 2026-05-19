import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final List<Map<String, String>> notifications = [
      {
        "title": "Trip Completed",
        "body": "You successfully completed trip #PKM-2847.",
        "time": "2 mins ago",
        "type": "trip"
      },
      {
        "title": "Payment Received",
        "body": "Your earnings of ₹450 has been added to your wallet.",
        "time": "1 hour ago",
        "type": "payment"
      },
      {
        "title": "New Document Verified",
        "body": "Your Driving License has been successfully verified.",
        "time": "Yesterday",
        "type": "system"
      },
      {
        "title": "System Update",
        "body": "A new version of the app is available. Update now!",
        "time": "2 days ago",
        "type": "system"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(context, item);
              },
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, String> item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    IconData icon;
    Color color;

    switch (item['type']) {
      case 'trip':
        icon = Icons.directions_car_filled;
        color = colorScheme.primary;
        break;
      case 'payment':
        icon = Icons.account_balance_wallet;
        color = colorScheme.secondary;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.orange; // System notification orange is standard
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title']!,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      item['time']!,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['body']!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 80, color: colorScheme.primary.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            "No Notifications yet",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.3),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
