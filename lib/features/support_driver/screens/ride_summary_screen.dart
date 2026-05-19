import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RideSummaryScreen extends StatefulWidget {
  const RideSummaryScreen({super.key});

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _doneBadgeController;

  @override
  void initState() {
    super.initState();
    _doneBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _doneBadgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(
          'Ride Summary',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildDoneBadge(context),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Success Icon
            _buildSuccessIcon(context),
            const SizedBox(height: 32),
            
            // Completion Titles
            Text(
              "Ride\nCompleted!",
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Car delivered to garage.\nStatus: At Garage – Service In Progress",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 48),

            // Trip Summary Card
            _buildTripDetailsCard(context),
            
            const SizedBox(height: 32),
            
            // Availability Status
            _buildAvailabilityFooter(context),
            
            const SizedBox(height: 40),

            // Final Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 12),
                    Text("Back to Home"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1).animate(_doneBadgeController),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.onPrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              "DONE", 
              style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.check, color: AppColors.success, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: colorScheme.onPrimary, size: 60),
        ),
      ],
    );
  }

  Widget _buildTripDetailsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, "Trip #", "#PKM-2847", isBold: true),
          _buildDetailRow(context, "Customer", "Ahmed Al-Rashid"),
          _buildDetailRow(context, "Car", "BMW · M72528"),
          _buildDetailRow(context, "Distance", "12.4 km"),
          _buildDetailRow(context, "Duration", "38 mins"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: colorScheme.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Earnings", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              _buildAnimatedEarnings(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
          ),
          Text(
            value, 
            style: textTheme.bodyLarge?.copyWith(fontWeight: isBold ? FontWeight.w900 : FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEarnings(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 85),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          "AED ${value.toInt()}",
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        );
      },
    );
  }

  Widget _buildAvailabilityFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text(
            "Status: Now Available for next trip",
            style: textTheme.labelLarge?.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
