import 'package:flutter/material.dart';

class ArrivedAtGarageScreen extends StatefulWidget {
  const ArrivedAtGarageScreen({super.key});

  @override
  State<ArrivedAtGarageScreen> createState() => _ArrivedAtGarageScreenState();
}

class _ArrivedAtGarageScreenState extends State<ArrivedAtGarageScreen> {
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
            'Arrived at Garage',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
          child: Column(
            children: [
              // Center Illustration (Trophy/Success)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.emoji_events, color: colorScheme.primary, size: 70),
                ),
              ),
              const SizedBox(height: 32),
              
              // Completion Header
              Text(
                "You've Arrived\nat the Garage!",
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Al Quoz Auto Service Center",
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),

              // Trip Summary Card
              _buildSummaryCard(context),
              
              const SizedBox(height: 48),

              // Primary Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/support_driver_garage_handover');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, size: 24),
                      SizedBox(width: 12),
                      Text("Handover to Garage"),
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

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            "JOURNEY SUMMARY",
            style: textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.5), letterSpacing: 1.2),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(context, Icons.route, "14.6 km", "Distance"),
              Container(height: 30, width: 1, color: colorScheme.outlineVariant),
              _buildSummaryItem(context, Icons.timer, "36 mins", "Duration"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, IconData icon, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 12),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
