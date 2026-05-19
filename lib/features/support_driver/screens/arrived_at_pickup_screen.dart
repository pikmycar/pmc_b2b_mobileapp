import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ArrivedAtPickupScreen extends StatefulWidget {
  const ArrivedAtPickupScreen({super.key});

  @override
  State<ArrivedAtPickupScreen> createState() => _ArrivedAtPickupScreenState();
}

class _ArrivedAtPickupScreenState extends State<ArrivedAtPickupScreen> {
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
          title: Text(
            'Arrived at Pickup',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            children: [
              // Center Illustration (Pin)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.location_on, color: AppColors.error, size: 50),
                ),
              ),
              const SizedBox(height: 32),
              
              // Arrival Header
              Text(
                "You've Arrived!",
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Dubai Marina, Tower B",
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Locate the customer and begin inspection",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Customer Contact Card
              _buildContactCard(context),
              
              const SizedBox(height: 32),

              // Secondary Actions (Call/SMS)
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryButton(
                      context, 
                      "Call", 
                      Icons.phone_in_talk, 
                      AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSecondaryButton(
                      context, 
                      "SMS", 
                      Icons.textsms_rounded, 
                      colorScheme.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Primary Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/support_driver_inspection');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search, size: 22),
                      SizedBox(width: 8),
                      Text("Start Car Inspection"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CUSTOMER CONTACT", 
            style: textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.5), letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person, color: colorScheme.primary, size: 28),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ahmed Al-Rashid",
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Text(
                    "Contact person on-site",
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone_android, color: AppColors.error, size: 26),
              const SizedBox(width: 16),
              Text(
                "+971 50 123 4567",
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String label, IconData icon, Color iconColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${label}ing Ahmed Al-Rashid..."),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
