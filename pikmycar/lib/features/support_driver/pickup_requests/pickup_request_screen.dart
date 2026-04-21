import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverPickupRequestScreen extends StatelessWidget {
  const SupportDriverPickupRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary.withOpacity(0.9), // Dark overlay feel for incoming requests
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ringing Icon Animation placeholder
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ]
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              Text(
                'New Pickup Alert!',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              
              // Request Card Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '123 Downtown Ave, Metro City',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Est. Time', 
                                style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '12 minutes', 
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
                              const SizedBox(height: 4),
                              Text(
                                '4.5 miles', 
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.onPrimary),
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/support_driver_waiting');
                      },
                      child: const Text('Accept Trip'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
