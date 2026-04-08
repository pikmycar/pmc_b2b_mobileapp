import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MainDriverPickMeRequestScreen extends StatelessWidget {
  const MainDriverPickMeRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withValues(alpha: 0.87),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ]
                ),
                child: Center(
                  child: Icon(
                    Icons.person_pin_circle,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              Text(
                'New Pick Me Alert!',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textInversePrimary,
                ),
              ),
               const SizedBox(height: 8),
               const Text(
                'Support Driver needs a ride',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(height: 32),
              
              // Request Card Details
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                             backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text('Alex (Support)', style: AppTextStyles.subtitle),
                                 Row(
                                   children: [
                                     const Icon(Icons.star, color: AppColors.warning, size: 14),
                                     Text(' 4.8 Rating', style: AppTextStyles.labelSmall)
                                   ],
                                 )
                               ],
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          Icon(Icons.my_location, color: AppColors.infoBlue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Support Driver Location: 456 Uptown Blvd',
                              style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                       const SizedBox(height: 12),
                       Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.success),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Customer Destination: 789 Suburbia Lane',
                              style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
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
                              Text('Total Est. Time', style: AppTextStyles.labelSmall),
                              SizedBox(height: 4),
                              Text('25 mins', style: AppTextStyles.subtitle),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Distance', style: AppTextStyles.labelSmall),
                              SizedBox(height: 4),
                              Text('8.5 miles', style: AppTextStyles.subtitle),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.textInversePrimary),
                        foregroundColor: AppColors.textInversePrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.infoBlue,
                        foregroundColor: AppColors.textInversePrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main_driver_transport');
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
