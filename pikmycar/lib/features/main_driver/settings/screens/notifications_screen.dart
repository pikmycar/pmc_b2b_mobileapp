import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(item);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> item) {
    IconData icon;
    Color color;

    switch (item['type']) {
      case 'trip':
        icon = Icons.local_taxi;
        color = Colors.indigo;
        break;
      case 'payment':
        icon = Icons.account_balance_wallet;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(item['time']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['body']!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No Notifications yet", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
