import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/mock_requests.dart';

class RoleBasedPopup extends StatelessWidget {
  final MockRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RoleBasedPopup({
    Key? key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon
          Center(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: Center(
                child: Icon(
                  request.title.contains('Alert') ? Icons.notification_important : Icons.person_pin_circle,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            request.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            request.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          
          // Request Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(request.imageUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(request.name, style: AppTextStyles.subtitle),
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
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      Icon(Icons.my_location, color: AppColors.infoBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'From: ${request.location}',
                          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'To: ${request.destination}',
                          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onDecline,
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: onAccept,
                  child: const Text('Accept'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
