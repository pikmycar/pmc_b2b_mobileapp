import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';
import 'package:provider/provider.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String?>(
        future: context.read<SecureStorageService>().getUserRole(),
        builder: (context, snapshot) {
          final roleStr = snapshot.data;
          final bool isMainDriver = roleStr == UserRole.mainDriver.toString();
          
          final List<Map<String, String>> history = isMainDriver 
            ? [
                {'date': '12 Apr 2026', 'type': 'Pick Me Delivery', 'amount': 'AED 150', 'status': 'Completed'},
                {'date': '11 Apr 2026', 'type': 'Pick Me Delivery', 'amount': 'AED 120', 'status': 'Completed'},
                {'date': '10 Apr 2026', 'type': 'Pick Me Delivery', 'amount': 'AED 50', 'status': 'Cancelled'},
              ]
            : [
                {'date': '12 Apr 2026', 'type': 'Customer Pickup', 'amount': 'AED 80', 'status': 'Completed'},
                {'date': '12 Apr 2026', 'type': 'Customer Pickup', 'amount': 'AED 95', 'status': 'Completed'},
                {'date': '11 Apr 2026', 'type': 'Customer Pickup', 'amount': 'AED 70', 'status': 'Completed'},
              ];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(item['type']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['date']!),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(
                        item['status']!, 
                        style: TextStyle(
                          color: item['status'] == 'Completed' ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
