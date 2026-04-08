import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverGarageDeliveryScreen extends StatelessWidget {
  const SupportDriverGarageDeliveryScreen({Key? key}) : super(key: key);

  void _completeTrip(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Trip Completed'),
        content: const Text('Vehicle successfully delivered to the garage.'),
        actions: [
          TextButton(
            onPressed: () {
              // Return to Dashboard and clear stack
              Navigator.of(context).pushNamedAndRemoveUntil('/support_driver_dashboard', (route) => false);
            },
            child: const Text('Back to Home'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigating to Garage')),
      body: Stack(
        children: [
          // Simulated Map Navigation Background
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.navigation, size: 100, color: Colors.blueAccent),
                   SizedBox(height: 16),
                   Text('Turn-by-turn Navigation Simulation', style: TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // Navigation Info Panel High
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.turn_right, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In 500 ft', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                          Text('Turn right onto Main St', style: AppTextStyles.heading3),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Status Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ETA', style: AppTextStyles.labelSmall),
                          const Text('15 mins', style: AppTextStyles.heading2),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Distance', style: AppTextStyles.labelSmall),
                          const Text('4.2 miles', style: AppTextStyles.heading3),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: () => _completeTrip(context),
                      child: const Text('Arrived at Garage - Complete'),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
