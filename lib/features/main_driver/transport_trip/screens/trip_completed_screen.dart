import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TripCompletedScreen extends StatelessWidget {
  const TripCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 80,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                "Trip Completed!",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Great job! You've successfully dropped off the support driver.",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
              
              const SizedBox(height: 48),
              
              // Summary Table
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _summaryRow(context, "Trip Earnings", "₹250", isPrimary: true),
                    Divider(height: 32, color: colorScheme.outlineVariant),
                    _summaryRow(context, "Distance", "4.8 km"),
                    const SizedBox(height: 12),
                    _summaryRow(context, "Time", "12 mins"),
                    const SizedBox(height: 12),
                    _summaryRow(context, "Support Driver", "John Doe"),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/driver_home', (route) => false);
                  },
                  child: const Text("BACK TO DASHBOARD"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool isPrimary = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontSize: isPrimary ? 20 : 16,
            fontWeight: isPrimary ? FontWeight.w900 : FontWeight.bold,
            color: isPrimary ? AppColors.success : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
