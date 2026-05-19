import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/mock_requests.dart';

class RoleBasedPopup extends StatelessWidget {
  final MockRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RoleBasedPopup({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
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
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: Center(
                child: Icon(
                  request.title.contains('Alert') ? Icons.notification_important : Icons.person_pin_circle,
                  size: 50,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            request.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            request.subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
          ),
          const SizedBox(height: 32),
          
          // Request Card
          Card(
            color: colorScheme.surface,
            margin: EdgeInsets.zero,
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
                            Text(request.name, style: textTheme.titleMedium),
                            Row(
                              children: [
                                Icon(Icons.star, color: colorScheme.secondary, size: 14),
                                const SizedBox(width: 4),
                                Text('4.8 Rating', style: textTheme.labelSmall),
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
                      Icon(Icons.my_location, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'From: ${request.location}',
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'To: ${request.destination}',
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
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
                    side: BorderSide(color: colorScheme.onPrimary),
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: onDecline,
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
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

