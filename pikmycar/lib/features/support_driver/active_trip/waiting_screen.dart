import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverWaitingScreen extends StatelessWidget {
  const SupportDriverWaitingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip to Garage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.map, size: 100, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text('Live Map Tracking Simulation', style: AppTextStyles.heading4.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          
          // Driver Info Bottom Sheet
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
                  Text(
                    'Main Driver is on the way',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Doe', style: AppTextStyles.subtitle),
                            Text('Toyota Camry • ABC-1234', style: AppTextStyles.labelSmall),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                Text(' 4.9', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('ETA', style: AppTextStyles.labelSmall),
                          Text('5 mins', style: AppTextStyles.heading4),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Distance', style: AppTextStyles.labelSmall),
                          Text('1.2 miles', style: AppTextStyles.heading4),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Demo Flow: Main Driver arrived => Support Driver inspects car
                        Navigator.pushReplacementNamed(context, '/support_driver_inspection');
                      },
                      child: const Text('Simulate Driver Arrived / Inspect Car'),
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
