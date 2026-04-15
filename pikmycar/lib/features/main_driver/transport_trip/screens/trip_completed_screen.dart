import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TripCompletedScreen extends StatelessWidget {
  const TripCompletedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              
              const Text(
                "Trip Completed!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Great job! You've successfully dropped off the support driver.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 16),
              ),
              
              const SizedBox(height: 48),
              
              // Summary Table
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _summaryRow("Trip Earnings", "₹250", isPrimary: true),
                    const Divider(height: 32),
                    _summaryRow("Distance", "4.8 km"),
                    const SizedBox(height: 12),
                    _summaryRow("Time", "12 mins"),
                    const SizedBox(height: 12),
                    _summaryRow("Support Driver", "John Doe"),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the home screen by removing all previous routes
                    Navigator.of(context).pushNamedAndRemoveUntil('/driver_home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "BACK TO DASHBOARD",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 20 : 16,
            fontWeight: isPrimary ? FontWeight.w900 : FontWeight.bold,
            color: isPrimary ? AppColors.success : Colors.black,
          ),
        ),
      ],
    );
  }
}
