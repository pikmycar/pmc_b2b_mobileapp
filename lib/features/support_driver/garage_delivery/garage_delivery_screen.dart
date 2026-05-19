import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverGarageDeliveryScreen extends StatefulWidget {
  const SupportDriverGarageDeliveryScreen({super.key});

  @override
  State<SupportDriverGarageDeliveryScreen> createState() => _SupportDriverGarageDeliveryScreenState();
}

class _SupportDriverGarageDeliveryScreenState extends State<SupportDriverGarageDeliveryScreen> {
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

  Future<bool> _onBackPressed(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Trip?"),
        content: const Text("Are you sure you want to cancel this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return true;
      Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Navigating to Garage'),
        ),
        body: Stack(
          children: [
            // Simulated Map Navigation Background
            Container(
              color: colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.navigation, size: 100, color: colorScheme.primary),
                     const SizedBox(height: 16),
                     Text(
                       'Turn-by-turn Navigation Simulation', 
                       style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                     ),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.turn_right, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In 500 ft', 
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Turn right onto Main St', 
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
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
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
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
                            Text(
                              'ETA', 
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                            ),
                            Text(
                              '15 mins', 
                              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Distance', 
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                            ),
                            Text(
                              '4.2 miles', 
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
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
      ),
    );
  }
}
