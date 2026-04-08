import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MainDriverTransportScreen extends StatefulWidget {
  const MainDriverTransportScreen({Key? key}) : super(key: key);

  @override
  State<MainDriverTransportScreen> createState() => _MainDriverTransportScreenState();
}

class _MainDriverTransportScreenState extends State<MainDriverTransportScreen> {
  bool _supportDriverPickedUp = false;

  void _completeTrip() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Transport Completed'),
        content: const Text('Support Driver has been successfully dropped off at the customer location.'),
        actions: [
          TextButton(
             onPressed: () {
              // Return to Dashboard and clear stack
              Navigator.of(context).pushNamedAndRemoveUntil('/main_driver_dashboard', (route) => false);
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
      appBar: AppBar(title: Text(_supportDriverPickedUp ? 'Navigating to Customer' : 'Navigating to Support Driver')),
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.directions, size: 100, color: AppColors.infoBlue),
                    const SizedBox(height: 16),
                    Text('Live Map Navigation Simulation', style: AppTextStyles.heading4.copyWith(color: AppColors.infoBlue)),
                ],
              ),
            ),
          ),
          
          // Trip Info Bottom Sheet
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
                    _supportDriverPickedUp ? 'Driving Support to Customer' : 'Picking up Support Driver',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alex (Support)', style: AppTextStyles.subtitle),
                            Text(_supportDriverPickedUp ? 'Destination: 789 Suburbia Lane' : 'Pickup: 456 Uptown Blvd', style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.infoBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.message, color: AppColors.infoBlue),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ETA', style: AppTextStyles.labelSmall),
                            Text(_supportDriverPickedUp ? '20 mins' : '5 mins', style: AppTextStyles.heading4),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Distance', style: AppTextStyles.labelSmall),
                            Text(_supportDriverPickedUp ? '7.0 miles' : '1.5 miles', style: AppTextStyles.heading4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _supportDriverPickedUp ? AppColors.success : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        if (!_supportDriverPickedUp) {
                          setState(() {
                            _supportDriverPickedUp = true;
                          });
                        } else {
                          _completeTrip();
                        }
                      },
                      child: Text(_supportDriverPickedUp ? 'Arrived at Drop-off - Complete Trip' : 'Support Driver Picked Up - Start Trip'),
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
